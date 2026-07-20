import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_service.dart';

import '../models/models.dart';

class ClinicService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> ensureUserDoc() async {
    final user = FirebaseAuth.instance.currentUser!;
    await _db.collection('users').doc(user.uid).set({
      'name': user.displayName ?? user.email,
      'email': user.email,
    }, SetOptions(merge: true));
  }

  static Future<String> createClinic(String name) async {
    final user = FirebaseAuth.instance.currentUser!;
    final clinicRef = await _db.collection('clinics').add({
      'name': name.trim(),
      'ownerId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'plan': 'trial',
    });
    await clinicRef.collection('members').doc(user.uid).set({
      'name': user.displayName ?? user.email,
      'email': user.email,
      'role': StaffRole.admin.name,
      'status': 'active',
    });
    await _db.collection('users').doc(user.uid).set({
      'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
    }, SetOptions(merge: true));
    return clinicRef.id;
  }

  static Stream<List<Clinic>> myClinicsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection('users').doc(user.uid).snapshots().asyncMap((userDoc) async {
      final ids = List<String>.from(userDoc.data()?['clinicIds'] ?? []);
      if (ids.isEmpty) return <Clinic>[];
      final docs = await Future.wait(ids.map((id) => _db.collection('clinics').doc(id).get()));
      return docs.where((d) => d.exists).map((d) => Clinic.fromFirestore(d.data()!, d.id)).toList();
    });
  }

    static Future<void> inviteStaff(String clinicId, String email, StaffRole role) async {
    final inviter = FirebaseAuth.instance.currentUser!;

    await _db.collection('clinics').doc(clinicId).collection('invites').add({
      'email': email.trim().toLowerCase(),
      'role': role.name,
      'status': 'pending',
      'invitedBy': inviter.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final clinicDoc = await _db.collection('clinics').doc(clinicId).get();

    try {
      await EmailService.sendInviteEmail(
        toEmail: email.trim(),
        clinicName: clinicDoc.data()?['name'] ?? 'your clinic',
        role: role.label,
        inviterName: inviter.displayName ?? inviter.email ?? 'A colleague',
      );
    } catch (e) {
      // Don't fail the whole invite if email delivery has an issue —
      // the invite record still exists and will still auto-accept on signup.
      // ignore: avoid_print
      print('Invite email failed (invite still saved): $e');
    }
  }

  static Future<void> acceptPendingInvites() async {
    final user = FirebaseAuth.instance.currentUser!;
    final email = user.email?.toLowerCase();
    if (email == null) return;

    final invites = await _db
        .collectionGroup('invites')
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'pending')
        .get();

    for (final inviteDoc in invites.docs) {
      final clinicRef = inviteDoc.reference.parent.parent!;
      final role = inviteDoc.data()['role'] as String;

      await clinicRef.collection('members').doc(user.uid).set({
        'name': user.displayName ?? email,
        'email': email,
        'role': role,
        'status': 'active',
      });
      await inviteDoc.reference.update({'status': 'accepted'});
      await _db.collection('users').doc(user.uid).set({
        'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
      }, SetOptions(merge: true));
    }
  }

  static Stream<List<ClinicMember>> membersStream(String clinicId) {
    return _db.collection('clinics').doc(clinicId).collection('members').snapshots().map(
        (s) => s.docs.map((d) => ClinicMember.fromFirestore(d.data(), d.id)).toList());
  }

  static Stream<ClinicMember?> myMembershipStream(String clinicId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db
        .collection('clinics')
        .doc(clinicId)
        .collection('members')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.exists ? ClinicMember.fromFirestore(doc.data()!, doc.id) : null);
  }

  static Stream<List<ClinicInvite>> pendingInvitesStream(String clinicId) {
    return _db
        .collection('clinics')
        .doc(clinicId)
        .collection('invites')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.map((d) => ClinicInvite.fromFirestore(d.data(), d.id)).toList());
  }

  static Future<void> cancelInvite(String clinicId, String inviteId) async {
    await _db.collection('clinics').doc(clinicId).collection('invites').doc(inviteId).delete();
  }

  static Future<void> removeMember(String clinicId, String uid) async {
    await _db.collection('clinics').doc(clinicId).collection('members').doc(uid).delete();
  }
}