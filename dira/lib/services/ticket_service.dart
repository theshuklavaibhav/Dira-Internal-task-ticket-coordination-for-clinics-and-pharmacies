import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'push_notification_service.dart';
import 'clinic_service.dart';
import '../models/models.dart';

class TicketService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _tickets(String clinicId) =>
      _db.collection('clinics').doc(clinicId).collection('tickets');

  static Stream<List<Ticket>> ticketsStream(String clinicId) {
    return _tickets(clinicId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Ticket.fromFirestore(d.data(), d.id)).toList());
  }

  static Stream<Ticket?> ticketStream(String clinicId, String ticketId) {
    return _tickets(clinicId)
        .doc(ticketId)
        .snapshots()
        .map((d) => d.exists ? Ticket.fromFirestore(d.data()!, d.id) : null);
  }

  static Future<void> createTicket(String clinicId, Ticket ticket) async {
    final docRef = await _tickets(clinicId).add(ticket.toJson());

    // if (ticket.assigneeId != null && ticket.assigneeId != ticket.createdBy) {
    if (ticket.assigneeId != null ) {
      await _db.collection('clinics').doc(clinicId).collection('notifications').add({
        'userId': ticket.assigneeId,
        'message': 'You were assigned to "${ticket.title}"',
        'ticketId': docRef.id,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await PushNotificationService.sendToUser(
        externalUserId: ticket.assigneeId!,
        title: 'New ticket assigned',
        message: 'You were assigned to "${ticket.title}"',
        data: {'clinicId': clinicId, 'ticketId': docRef.id},
      );
    }

    if (ticket.priority == TicketPriority.urgent) {
      final admins = await ClinicService.getAdmins(clinicId);
      for (final admin in admins) {
        if (admin.uid == ticket.createdBy) continue;
        await _db.collection('clinics').doc(clinicId).collection('notifications').add({
          'userId': admin.uid,
          'message': '🚨 Urgent ticket created: "${ticket.title}"',
          'ticketId': docRef.id,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await PushNotificationService.sendToUser(
          externalUserId: admin.uid,
          title: 'Urgent ticket',
          message: '🚨 Urgent ticket created: "${ticket.title}"',
          data: {'clinicId': clinicId, 'ticketId': docRef.id},
        );
      }
    }
  }

  static Future<void> updateStatus(String clinicId, String ticketId, TicketStatus status) async {
    await _tickets(clinicId).doc(ticketId).update({'status': status.name});

    if (status == TicketStatus.done) {
      final ticketDoc = await _tickets(clinicId).doc(ticketId).get();
      final data = ticketDoc.data();
      if (data == null) return;
      final creatorId = data['createdBy'] as String?;
      final currentUser = FirebaseAuth.instance.currentUser?.uid;

      // if (creatorId != null && creatorId != currentUser) {
      if (creatorId != null ) {
        await _db.collection('clinics').doc(clinicId).collection('notifications').add({
          'userId': creatorId,
          'message': '"${data['title']}" was marked as Done',
          'ticketId': ticketId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await PushNotificationService.sendToUser(
          externalUserId: creatorId,
          title: 'Ticket resolved',
          message: '"${data['title']}" was marked as Done',
          data: {'clinicId': clinicId, 'ticketId': ticketId},
        );
      }
    }
  }

  static Future<void> assign(String clinicId, String ticketId, String userId, String userName) async {
    await _tickets(clinicId).doc(ticketId).update({'assigneeId': userId, 'assigneeName': userName});
  }

  static Future<void> deleteTicket(String clinicId, String ticketId) async {
    await _tickets(clinicId).doc(ticketId).delete();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> commentsStream(String clinicId, String ticketId) {
    return _tickets(clinicId).doc(ticketId).collection('comments').orderBy('timestamp').snapshots();
  }

  static Future<void> addComment(String clinicId, String ticketId, String text) async {
    if (text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;

    await _tickets(clinicId).doc(ticketId).collection('comments').add({
      'text': text.trim(),
      'userId': user.uid,
      'userName': user.displayName ?? user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final ticketDoc = await _tickets(clinicId).doc(ticketId).get();
    final data = ticketDoc.data();
    if (data == null) return;

    final recipients = <String>{};
    if (data['assigneeId'] != null) recipients.add(data['assigneeId']);
    if (data['createdBy'] != null) recipients.add(data['createdBy']);
    recipients.remove(user.uid);

    for (final uid in recipients) {
      final commentMessage = '${user.displayName ?? user.email ?? 'Someone'} commented on "${data['title']}"';
      await _db.collection('clinics').doc(clinicId).collection('notifications').add({
        'userId': uid,
        'message': commentMessage,
        'ticketId': ticketId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await PushNotificationService.sendToUser(
        externalUserId: uid,
        title: 'New comment',
        message: commentMessage,
        data: {'clinicId': clinicId, 'ticketId': ticketId},
      );
    }
  }
}