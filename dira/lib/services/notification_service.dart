// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class NotificationService {
//   static final _db = FirebaseFirestore.instance;

//   static Stream<QuerySnapshot<Map<String, dynamic>>> myNotifications(String clinicId) {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     return _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notifications')
//         .where('userId', isEqualTo: uid)
//         .orderBy('createdAt', descending: true)
//         .limit(50)
//         .snapshots();
//   }

//   static Stream<int> unreadCount(String clinicId) {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return Stream.value(0);
//     return _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notifications')
//         .where('userId', isEqualTo: uid)
//         .where('read', isEqualTo: false)
//         .snapshots()
//         .map((s) => s.docs.length);
//   }

//   static Future<void> deleteNotification(String clinicId, String notifId) async {
//   await _db.collection('clinics').doc(clinicId).collection('notifications').doc(notifId).delete();
// }

//   static Future<void> clearAllRead(String clinicId) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;
//     final snapshot = await _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notifications')
//         .where('userId', isEqualTo: uid)
//         .where('read', isEqualTo: true)
//         .get();
//     for (final doc in snapshot.docs) {
//       await doc.reference.delete();
//     }
//   }

//   static Future<void> markRead(String clinicId, String notifId) async {
//     await _db.collection('clinics').doc(clinicId).collection('notifications').doc(notifId).update({'read': true});
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot<Map<String, dynamic>>> myNotifications(String clinicId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  static Stream<int> unreadCount(String clinicId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(0);
    return _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  static Future<void> deleteNotification(String clinicId, String notifId) async {
    await _db.collection('clinics').doc(clinicId).collection('notifications').doc(notifId).delete();
  }

  static Future<void> clearAllRead(String clinicId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snapshot = await _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: true)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> markRead(String clinicId, String notifId) async {
    await _db.collection('clinics').doc(clinicId).collection('notifications').doc(notifId).update({'read': true});
  }
}