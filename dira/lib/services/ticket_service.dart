import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './onesignal_notification_service.dart';

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

  // static Future<void> createTicket(String clinicId, Ticket ticket) async {
  //   await _tickets(clinicId).add(ticket.toJson());
  // }

  // static Future<void> createTicket(String clinicId, Ticket ticket) async {
  //   final docRef = await _tickets(clinicId).add(ticket.toJson());

  //   if (ticket.assigneeId != null && ticket.assigneeId != ticket.createdBy) {
  //     await _db.collection('clinics').doc(clinicId).collection('notifications').add({
  //       'userId': ticket.assigneeId,
  //       'message': 'You were assigned to "${ticket.title}"',
  //       'ticketId': docRef.id,
  //       'read': false,
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //   }
  // }

  // static Future<void> updateTicket(String clinicId, String ticketId, Map<String, dynamic> updates) async {
  //   final currentUser = FirebaseAuth.instance.currentUser?.uid;

  //   if (updates.containsKey('assigneeId')) {
  //     final existing = await _tickets(clinicId).doc(ticketId).get();
  //     final oldAssigneeId = existing.data()?['assigneeId'];
  //     final newAssigneeId = updates['assigneeId'];
  //     final title = updates['title'] ?? existing.data()?['title'] ?? 'a ticket';

  //     if (newAssigneeId != null && newAssigneeId != oldAssigneeId && newAssigneeId != currentUser) {
  //       await _db.collection('clinics').doc(clinicId).collection('notifications').add({
  //         'userId': newAssigneeId,
  //         'message': 'You were assigned to "$title"',
  //         'ticketId': ticketId,
  //         'read': false,
  //         'createdAt': FieldValue.serverTimestamp(),
  //       });
  //     }
  //   }

  //   await _tickets(clinicId).doc(ticketId).update(updates);
  // }

  static Future<void> createTicket(String clinicId, Ticket ticket) async {
    final docRef = await _tickets(clinicId).add(ticket.toJson());
  
    // if (ticket.assigneeId != null && ticket.assigneeId != ticket.createdBy) {
    if (ticket.assigneeId != null) {
      await _db.collection('clinics').doc(clinicId).collection('notifications').add({
        'userId': ticket.assigneeId,
        'message': 'You were assigned to "${ticket.title}"',
        'ticketId': docRef.id,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
  
      await OneSignalPushService.sendToUser(
        externalUserId: ticket.assigneeId!,
        title: 'New ticket assigned',
        message: 'You were assigned to "${ticket.title}"',
        data: {'clinicId': clinicId, 'ticketId': docRef.id},
      );
    }
  }
  
  // Replace updateTicket with:
  static Future<void> updateTicket(String clinicId, String ticketId, Map<String, dynamic> updates) async {
    final currentUser = FirebaseAuth.instance.currentUser?.uid;
  
    if (updates.containsKey('assigneeId')) {
      final existing = await _tickets(clinicId).doc(ticketId).get();
      final oldAssigneeId = existing.data()?['assigneeId'];
      final newAssigneeId = updates['assigneeId'];
      final title = updates['title'] ?? existing.data()?['title'] ?? 'a ticket';
  
      // if (newAssigneeId != null && newAssigneeId != oldAssigneeId && newAssigneeId != currentUser) {
      if (newAssigneeId != null && newAssigneeId != oldAssigneeId) {
        await _db.collection('clinics').doc(clinicId).collection('notifications').add({
          'userId': newAssigneeId,
          'message': 'You were assigned to "$title"',
          'ticketId': ticketId,
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
  
        await OneSignalPushService.sendToUser(
          externalUserId: newAssigneeId,
          title: 'New ticket assigned',
          message: 'You were assigned to "$title"',
          data: {'clinicId': clinicId, 'ticketId': ticketId},
        );
      }
    }
  
    await _tickets(clinicId).doc(ticketId).update(updates);
  }

  static Future<void> updateStatus(String clinicId, String ticketId, TicketStatus status) async {
    await _tickets(clinicId).doc(ticketId).update({'status': status.name});
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

  // static Future<void> addComment(String clinicId, String ticketId, String text) async {
  //   if (text.trim().isEmpty) return;
  //   final user = FirebaseAuth.instance.currentUser!;
  //   await _tickets(clinicId).doc(ticketId).collection('comments').add({
  //     'text': text.trim(),
  //     'userId': user.uid,
  //     'userName': user.displayName ?? user.email,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  // }

    static Future<void> addComment(String clinicId, String ticketId, String text) async {
    if (text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;

    await _tickets(clinicId).doc(ticketId).collection('comments').add({
      'text': text.trim(),
      'userId': user.uid,
      'userName': user.displayName ?? user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Notify the assignee and ticket creator (excluding whoever just commented).
    final ticketDoc = await _tickets(clinicId).doc(ticketId).get();
    final data = ticketDoc.data();
    if (data == null) return;

    final recipients = <String>{};
    if (data['assigneeId'] != null) recipients.add(data['assigneeId']);
    if (data['createdBy'] != null) recipients.add(data['createdBy']);
    recipients.remove(user.uid);

    for (final uid in recipients) {
      await _db.collection('clinics').doc(clinicId).collection('notifications').add({
        'userId': uid,
        'message': '${user.displayName ?? user.email ?? 'Someone'} commented on "${data['title']}"',
        'ticketId': ticketId,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

}