import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await _tickets(clinicId).add(ticket.toJson());
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

  static Future<void> addComment(String clinicId, String ticketId, String text) async {
    if (text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser!;
    await _tickets(clinicId).doc(ticketId).collection('comments').add({
      'text': text.trim(),
      'userId': user.uid,
      'userName': user.displayName ?? user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}