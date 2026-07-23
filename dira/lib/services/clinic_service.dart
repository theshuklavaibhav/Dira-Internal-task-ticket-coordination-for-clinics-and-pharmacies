// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'email_service.dart';

// import '../models/models.dart';

// class ClinicService {
//   static final _db = FirebaseFirestore.instance;

//   static Future<void> ensureUserDoc() async {
//     final user = FirebaseAuth.instance.currentUser!;
//     await _db.collection('users').doc(user.uid).set({
//       'name': user.displayName ?? user.email,
//       'email': user.email,
//     }, SetOptions(merge: true));
//   }

//   static Future<String> createClinic(String name) async {
//     final user = FirebaseAuth.instance.currentUser!;
//     final clinicRef = await _db.collection('clinics').add({
//       'name': name.trim(),
//       'ownerId': user.uid,
//       'createdAt': FieldValue.serverTimestamp(),
//       'plan': 'trial',
//     });
//     await clinicRef.collection('members').doc(user.uid).set({
//       'name': user.displayName ?? user.email,
//       'email': user.email,
//       'role': StaffRole.admin.name,
//       'status': 'active',
//     });
//     await _db.collection('users').doc(user.uid).set({
//       'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
//     }, SetOptions(merge: true));
//     return clinicRef.id;
//   }

//   static Stream<List<Clinic>> myClinicsStream() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return const Stream.empty();
//     return _db.collection('users').doc(user.uid).snapshots().asyncMap((userDoc) async {
//       final ids = List<String>.from(userDoc.data()?['clinicIds'] ?? []);
//       if (ids.isEmpty) return <Clinic>[];
//       final docs = await Future.wait(ids.map((id) => _db.collection('clinics').doc(id).get()));
//       return docs.where((d) => d.exists).map((d) => Clinic.fromFirestore(d.data()!, d.id)).toList();
//     });
//   }

//   //   static Future<void> inviteStaff(String clinicId, String email, StaffRole role) async {
//   //   final inviter = FirebaseAuth.instance.currentUser!;

//   //   await _db.collection('clinics').doc(clinicId).collection('invites').add({
//   //     'email': email.trim().toLowerCase(),
//   //     'role': role.name,
//   //     'status': 'pending',
//   //     'invitedBy': inviter.uid,
//   //     'createdAt': FieldValue.serverTimestamp(),
//   //   });

//   //   final clinicDoc = await _db.collection('clinics').doc(clinicId).get();

//   //   try {
//   //     await EmailService.sendInviteEmail(
//   //       toEmail: email.trim(),
//   //       clinicName: clinicDoc.data()?['name'] ?? 'your clinic',
//   //       role: role.label,
//   //       inviterName: inviter.displayName ?? inviter.email ?? 'A colleague',
//   //     );
//   //   } catch (e) {
//   //     // Don't fail the whole invite if email delivery has an issue —
//   //     // the invite record still exists and will still auto-accept on signup.
//   //     // ignore: avoid_print
//   //     print('Invite email failed (invite still saved): $e');
//   //   }
//   // }

//     static Future<void> inviteStaff(
//       String clinicId,
//       String contact,
//       StaffRole role, {
//       String method = 'email',
//     }) async {
//       final inviter = FirebaseAuth.instance.currentUser!;
//       final normalizedContact = method == 'email' ? contact.trim().toLowerCase() : contact.trim();

//       await _db.collection('clinics').doc(clinicId).collection('invites').add({
//         'contact': normalizedContact,
//         'method': method,
//         'role': role.name,
//         'status': 'pending',
//         'invitedBy': inviter.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       if (method == 'email') {
//         final clinicDoc = await _db.collection('clinics').doc(clinicId).get();
//         try {
//           await EmailService.sendInviteEmail(
//             toEmail: normalizedContact,
//             clinicName: clinicDoc.data()?['name'] ?? 'your clinic',
//             role: role.label,
//             inviterName: inviter.displayName ?? inviter.email ?? 'A colleague',
//           );
//         } catch (e) {
//           // ignore: avoid_print
//           print('Invite email failed (invite still saved): $e');
//         }
//       }
//       // Phone invites: no automated SMS sender wired up yet (would need a paid
//       // SMS API like Twilio/MSG91). The invite record still auto-accepts once
//       // that phone number signs in — just tell them manually to sign up for now.
//     }
  
//   //   static Future<void> acceptPendingInvites() async {
//   //     try {
//   //     final user = FirebaseAuth.instance.currentUser;
//   //     if (user == null) return;

//   //     // Force a fresh ID token so Firestore's auth context is guaranteed to be
//   //     // ready — avoids a race condition right after a brand-new sign-in.
//   //     await user.getIdToken(true);

//   //     final email = user.email?.toLowerCase();
//   //     final phone = user.phoneNumber;

//   //     final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
//   //     if (email != null && email.isNotEmpty) {
//   //       queries.add(_db
//   //           .collectionGroup('invites')
//   //           .where('contact', isEqualTo: email)
//   //           .where('status', isEqualTo: 'pending')
//   //           .get());
//   //     }
//   //     if (phone != null && phone.isNotEmpty) {
//   //       queries.add(_db
//   //           .collectionGroup('invites')
//   //           .where('contact', isEqualTo: phone)
//   //           .where('status', isEqualTo: 'pending')
//   //           .get());
//   //     }

//   //     final results = await Future.wait(queries);
//   //     for (final snapshot in results) {
//   //       for (final inviteDoc in snapshot.docs) {
//   //         final clinicRef = inviteDoc.reference.parent.parent!;
//   //         final role = inviteDoc.data()['role'] as String;
//   //         await clinicRef.collection('members').doc(user.uid).set({
//   //           'name': user.displayName ?? email ?? phone,
//   //           'email': email ?? '',
//   //           'role': role,
//   //           'status': 'active',
//   //         });
//   //         await inviteDoc.reference.update({'status': 'accepted'});
//   //         await _db.collection('users').doc(user.uid).set({
//   //           'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
//   //         }, SetOptions(merge: true));
//   //       }
//   //     }
//   //   } catch (e) {
//   //     // Don't crash the app if invite-acceptance fails — worst case, the user
//   //     // just doesn't auto-join, which they can be manually added to later.
//   //     // ignore: avoid_print
//   //     print('acceptPendingInvites failed (non-fatal): $e');
//   //   }
//   // }

//   static Future<void> acceptPendingInvites() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final email = user.email?.toLowerCase().trim();
//     final phone = user.phoneNumber;
//     final db = FirebaseFirestore.instance;

//     final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[];

//     // 1. Check for email invites (Note: querying the 'contact' field)
//     if (email != null && email.isNotEmpty) {
//       queries.add(db
//           .collectionGroup('invites')
//           .where('contact', isEqualTo: email)
//           .where('status', isEqualTo: 'pending')
//           .get());
//     }

//     // 2. Check for phone invites
//     if (phone != null && phone.isNotEmpty) {
//       queries.add(db
//           .collectionGroup('invites')
//           .where('contact', isEqualTo: phone)
//           .where('status', isEqualTo: 'pending')
//           .get());
//     }

//     if (queries.isEmpty) return;

//     final results = await Future.wait(queries);

//     for (final snapshot in results) {
//       for (final inviteDoc in snapshot.docs) {
//         final clinicRef = inviteDoc.reference.parent.parent;
//         if (clinicRef == null) continue;

//         final role = inviteDoc.data()['role'] as String? ?? 'reception';

//         // Step A: Grant access first (Create the Member document)
//         try {
//           await clinicRef.collection('members').doc(user.uid).set({
//             'uid': user.uid,
//             'name': user.displayName ?? email ?? phone ?? 'Staff Member',
//             'email': email ?? '',
//             'role': role,
//             'status': 'active',
//             'joinedAt': FieldValue.serverTimestamp(),
//           });
          
//           // Optional: If you maintain an array of clinicIds on the user document
//           await db.collection('users').doc(user.uid).set({
//             'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
//           }, SetOptions(merge: true));
//         } catch (e) {
//           print('Error creating member doc: $e');
//           continue; // Skip step B if we couldn't grant access
//         }

//         // Step B: Mark invite as accepted
//         try {
//           await inviteDoc.reference.update({
//             'status': 'accepted',
//             'acceptedAt': FieldValue.serverTimestamp(),
//           });
//         } catch (e) {
//           print('Error marking invite accepted: $e');
//         }
//       }
//     }
//   }

//   static Stream<List<ClinicMember>> membersStream(String clinicId) {
//     return _db.collection('clinics').doc(clinicId).collection('members').snapshots().map(
//         (s) => s.docs.map((d) => ClinicMember.fromFirestore(d.data(), d.id)).toList());
//   }

//   static Stream<ClinicMember?> myMembershipStream(String clinicId) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return const Stream.empty();
//     return _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('members')
//         .doc(user.uid)
//         .snapshots()
//         .map((doc) => doc.exists ? ClinicMember.fromFirestore(doc.data()!, doc.id) : null);
//   }

//   static Stream<List<ClinicInvite>> pendingInvitesStream(String clinicId) {
//     return _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('invites')
//         .where('status', isEqualTo: 'pending')
//         .snapshots()
//         .map((s) => s.docs.map((d) => ClinicInvite.fromFirestore(d.data(), d.id)).toList());
//   }

//   static Future<void> cancelInvite(String clinicId, String inviteId) async {
//     await _db.collection('clinics').doc(clinicId).collection('invites').doc(inviteId).delete();
//   }

//   static Future<void> removeMember(String clinicId, String uid) async {
//     await _db.collection('clinics').doc(clinicId).collection('members').doc(uid).delete();
//   }
// }

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

  //   static Future<void> inviteStaff(String clinicId, String email, StaffRole role) async {
  //   final inviter = FirebaseAuth.instance.currentUser!;

  //   await _db.collection('clinics').doc(clinicId).collection('invites').add({
  //     'email': email.trim().toLowerCase(),
  //     'role': role.name,
  //     'status': 'pending',
  //     'invitedBy': inviter.uid,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   });

  //   final clinicDoc = await _db.collection('clinics').doc(clinicId).get();

  //   try {
  //     await EmailService.sendInviteEmail(
  //       toEmail: email.trim(),
  //       clinicName: clinicDoc.data()?['name'] ?? 'your clinic',
  //       role: role.label,
  //       inviterName: inviter.displayName ?? inviter.email ?? 'A colleague',
  //     );
  //   } catch (e) {
  //     // Don't fail the whole invite if email delivery has an issue —
  //     // the invite record still exists and will still auto-accept on signup.
  //     // ignore: avoid_print
  //     print('Invite email failed (invite still saved): $e');
  //   }
  // }

    static Future<void> inviteStaff(
      String clinicId,
      String contact,
      StaffRole role, {
      String method = 'email',
    }) async {
      final inviter = FirebaseAuth.instance.currentUser!;
      final normalizedContact = method == 'email' ? contact.trim().toLowerCase() : contact.trim();

      await _db.collection('clinics').doc(clinicId).collection('invites').add({
        'contact': normalizedContact,
        'method': method,
        'role': role.name,
        'status': 'pending',
        'invitedBy': inviter.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (method == 'email') {
        final clinicDoc = await _db.collection('clinics').doc(clinicId).get();
        try {
          await EmailService.sendInviteEmail(
            toEmail: normalizedContact,
            clinicName: clinicDoc.data()?['name'] ?? 'your clinic',
            role: role.label,
            inviterName: inviter.displayName ?? inviter.email ?? 'A colleague',
          );
        } catch (e) {
          // ignore: avoid_print
          print('Invite email failed (invite still saved): $e');
        }
      }
      // Phone invites: no automated SMS sender wired up yet (would need a paid
      // SMS API like Twilio/MSG91). The invite record still auto-accepts once
      // that phone number signs in — just tell them manually to sign up for now.
    }
  
  //   static Future<void> acceptPendingInvites() async {
  //     try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) return;

  //     // Force a fresh ID token so Firestore's auth context is guaranteed to be
  //     // ready — avoids a race condition right after a brand-new sign-in.
  //     await user.getIdToken(true);

  //     final email = user.email?.toLowerCase();
  //     final phone = user.phoneNumber;

  //     final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
  //     if (email != null && email.isNotEmpty) {
  //       queries.add(_db
  //           .collectionGroup('invites')
  //           .where('contact', isEqualTo: email)
  //           .where('status', isEqualTo: 'pending')
  //           .get());
  //     }
  //     if (phone != null && phone.isNotEmpty) {
  //       queries.add(_db
  //           .collectionGroup('invites')
  //           .where('contact', isEqualTo: phone)
  //           .where('status', isEqualTo: 'pending')
  //           .get());
  //     }

  //     final results = await Future.wait(queries);
  //     for (final snapshot in results) {
  //       for (final inviteDoc in snapshot.docs) {
  //         final clinicRef = inviteDoc.reference.parent.parent!;
  //         final role = inviteDoc.data()['role'] as String;
  //         await clinicRef.collection('members').doc(user.uid).set({
  //           'name': user.displayName ?? email ?? phone,
  //           'email': email ?? '',
  //           'role': role,
  //           'status': 'active',
  //         });
  //         await inviteDoc.reference.update({'status': 'accepted'});
  //         await _db.collection('users').doc(user.uid).set({
  //           'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
  //         }, SetOptions(merge: true));
  //       }
  //     }
  //   } catch (e) {
  //     // Don't crash the app if invite-acceptance fails — worst case, the user
  //     // just doesn't auto-join, which they can be manually added to later.
  //     // ignore: avoid_print
  //     print('acceptPendingInvites failed (non-fatal): $e');
  //   }
  // }

  static Future<void> acceptPendingInvites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final email = user.email?.toLowerCase().trim();
    final phone = user.phoneNumber;
    final db = FirebaseFirestore.instance;

    final queries = <Future<QuerySnapshot<Map<String, dynamic>>>>[];

    // 1. Check for email invites (Note: querying the 'contact' field)
    if (email != null && email.isNotEmpty) {
      queries.add(db
          .collectionGroup('invites')
          .where('contact', isEqualTo: email)
          .where('status', isEqualTo: 'pending')
          .get());
    }

    // 2. Check for phone invites
    if (phone != null && phone.isNotEmpty) {
      queries.add(db
          .collectionGroup('invites')
          .where('contact', isEqualTo: phone)
          .where('status', isEqualTo: 'pending')
          .get());
    }

    if (queries.isEmpty) return;

    final results = await Future.wait(queries);

    for (final snapshot in results) {
      for (final inviteDoc in snapshot.docs) {
        final clinicRef = inviteDoc.reference.parent.parent;
        if (clinicRef == null) continue;

        final role = inviteDoc.data()['role'] as String? ?? 'reception';

        // Step A: Grant access first (Create the Member document)
        try {
          await clinicRef.collection('members').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? email ?? phone ?? 'Staff Member',
            'email': email ?? '',
            'role': role,
            'status': 'active',
            'joinedAt': FieldValue.serverTimestamp(),
          });
          
          // Optional: If you maintain an array of clinicIds on the user document
          await db.collection('users').doc(user.uid).set({
            'clinicIds': FieldValue.arrayUnion([clinicRef.id]),
          }, SetOptions(merge: true));
        } catch (e) {
          print('Error creating member doc: $e');
          continue; // Skip step B if we couldn't grant access
        }

        // Step B: Mark invite as accepted
        try {
          await inviteDoc.reference.update({
            'status': 'accepted',
            'acceptedAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error marking invite accepted: $e');
        }
      }
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