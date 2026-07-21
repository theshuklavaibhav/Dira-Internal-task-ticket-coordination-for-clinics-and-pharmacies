// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';

// // /// A clinic-wide announcement. Kept intentionally simple — title, body,
// // /// priority, author, and a pin/view count for the Notice Board feed.
// // class Notice {
// //   final String id;
// //   final String title;
// //   final String body;
// //   final String priority; // 'urgent' | 'normal'
// //   final String authorName;
// //   final String authorRole;
// //   final DateTime createdAt;
// //   final int viewCount;
// //   final bool pinned;

// //   Notice({
// //     required this.id,
// //     required this.title,
// //     required this.body,
// //     required this.priority,
// //     required this.authorName,
// //     required this.authorRole,
// //     required this.createdAt,
// //     this.viewCount = 0,
// //     this.pinned = false,
// //   });

// //   factory Notice.fromFirestore(Map<String, dynamic> data, String id) => Notice(
// //         id: id,
// //         title: data['title'] as String? ?? '',
// //         body: data['body'] as String? ?? '',
// //         priority: data['priority'] as String? ?? 'normal',
// //         authorName: data['authorName'] as String? ?? 'Unknown',
// //         authorRole: data['authorRole'] as String? ?? '',
// //         createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
// //         viewCount: data['viewCount'] as int? ?? 0,
// //         pinned: data['pinned'] as bool? ?? false,
// //       );

// //   Map<String, dynamic> toJson() => {
// //         'title': title,
// //         'body': body,
// //         'priority': priority,
// //         'authorName': authorName,
// //         'authorRole': authorRole,
// //         'viewCount': viewCount,
// //         'pinned': pinned,
// //       };
// // }

// // class NoticeBoardService {
// //   static final _db = FirebaseFirestore.instance;

// //   static Stream<List<Notice>> noticesStream(String clinicId) {
// //     return _db
// //         .collection('clinics')
// //         .doc(clinicId)
// //         .collection('notices')
// //         .orderBy('pinned', descending: true)
// //         .orderBy('createdAt', descending: true)
// //         .snapshots()
// //         .map((snap) => snap.docs.map((d) => Notice.fromFirestore(d.data(), d.id)).toList());
// //   }

// //   static Future<void> postNotice(
// //     String clinicId, {
// //     required String title,
// //     required String body,
// //     required String priority,
// //     required String authorRole,
// //   }) async {
// //     final user = FirebaseAuth.instance.currentUser!;
// //     await _db.collection('clinics').doc(clinicId).collection('notices').add({
// //       'title': title,
// //       'body': body,
// //       'priority': priority,
// //       'authorName': user.displayName ?? user.email ?? 'Staff member',
// //       'authorRole': authorRole,
// //       'viewCount': 0,
// //       'pinned': false,
// //       'createdAt': FieldValue.serverTimestamp(),
// //     });
// //   }

// //   static Future<void> togglePin(String clinicId, String noticeId, bool pinned) async {
// //     await _db
// //         .collection('clinics')
// //         .doc(clinicId)
// //         .collection('notices')
// //         .doc(noticeId)
// //         .update({'pinned': !pinned});
// //   }

// //   static Future<void> incrementViews(String clinicId, String noticeId) async {
// //     await _db
// //         .collection('clinics')
// //         .doc(clinicId)
// //         .collection('notices')
// //         .doc(noticeId)
// //         .update({'viewCount': FieldValue.increment(1)});
// //   }

// //   static Future<void> deleteNotice(String clinicId, String noticeId) async {
// //     await _db.collection('clinics').doc(clinicId).collection('notices').doc(noticeId).delete();
// //   }
// // }

// // class NoticeBoardScreen extends StatelessWidget {
// //   final String clinicId;
// //   final String clinicName;
// //   const NoticeBoardScreen({super.key, required this.clinicId, required this.clinicName});

// //   @override
// //   Widget build(BuildContext context) {
// //     final scheme = Theme.of(context).colorScheme;
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Notice Board · $clinicName')),
// //       body: StreamBuilder<List<Notice>>(
// //         stream: NoticeBoardService.noticesStream(clinicId),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return const Center(child: CircularProgressIndicator());
// //           }
// //           final notices = snapshot.data ?? [];
// //           if (notices.isEmpty) {
// //             return Center(
// //               child: Padding(
// //                 padding: const EdgeInsets.all(32),
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Container(
// //                       width: 72,
// //                       height: 72,
// //                       decoration: BoxDecoration(
// //                         color: scheme.primaryContainer.withOpacity(0.15),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Icon(Icons.campaign_outlined, size: 34, color: scheme.primary),
// //                     ),
// //                     const SizedBox(height: 20),
// //                     Text('No notices yet', style: Theme.of(context).textTheme.titleLarge),
// //                     const SizedBox(height: 6),
// //                     Text('Post an announcement for your team.',
// //                         style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           }
// //           return ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: notices.length,
// //             itemBuilder: (context, index) => _NoticeCard(clinicId: clinicId, notice: notices[index]),
// //           );
// //         },
// //       ),
// //       floatingActionButton: FloatingActionButton.extended(
// //         icon: const Icon(Icons.add),
// //         label: const Text('Post Notice'),
// //         onPressed: () => _showComposeSheet(context, clinicId),
// //       ),
// //     );
// //   }

// //   void _showComposeSheet(BuildContext context, String clinicId) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => _ComposeNoticeSheet(clinicId: clinicId),
// //     );
// //   }
// // }

// // class _NoticeCard extends StatelessWidget {
// //   final String clinicId;
// //   final Notice notice;
// //   const _NoticeCard({required this.clinicId, required this.notice});

// //   @override
// //   Widget build(BuildContext context) {
// //     final scheme = Theme.of(context).colorScheme;
// //     final isUrgent = notice.priority == 'urgent';
// //     final accent = isUrgent ? scheme.secondary : scheme.primary;

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 14),
// //       decoration: BoxDecoration(
// //         color: scheme.surfaceContainerLowest,
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
// //       ),
// //       child: Stack(
// //         children: [
// //           Positioned(
// //             left: 0,
// //             top: 0,
// //             bottom: 0,
// //             child: Container(width: 4, decoration: BoxDecoration(color: accent)),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                       decoration: BoxDecoration(
// //                         color: accent.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(20),
// //                       ),
// //                       child: Text(
// //                         isUrgent ? 'Urgent' : 'Notice',
// //                         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 10),
// //                     Icon(Icons.schedule, size: 14, color: scheme.onSurfaceVariant),
// //                     const SizedBox(width: 4),
// //                     Text(_timeAgo(notice.createdAt), style: Theme.of(context).textTheme.bodySmall),
// //                     const Spacer(),
// //                     IconButton(
// //                       icon: Icon(
// //                         notice.pinned ? Icons.push_pin : Icons.push_pin_outlined,
// //                         size: 20,
// //                         color: notice.pinned ? scheme.secondary : scheme.onSurfaceVariant,
// //                       ),
// //                       onPressed: () => NoticeBoardService.togglePin(clinicId, notice.id, notice.pinned),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(notice.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
// //                 const SizedBox(height: 6),
// //                 Text(notice.body, style: Theme.of(context).textTheme.bodyMedium),
// //                 const SizedBox(height: 14),
// //                 Divider(color: scheme.outlineVariant.withOpacity(0.3)),
// //                 const SizedBox(height: 6),
// //                 Row(
// //                   children: [
// //                     CircleAvatar(
// //                       radius: 14,
// //                       backgroundColor: scheme.primaryContainer.withOpacity(0.2),
// //                       child: Text(
// //                         notice.authorName.isNotEmpty ? notice.authorName[0].toUpperCase() : '?',
// //                         style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 12),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(notice.authorName, style: Theme.of(context).textTheme.bodySmall),
// //                           if (notice.authorRole.isNotEmpty)
// //                             Text(notice.authorRole,
// //                                 style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
// //                         ],
// //                       ),
// //                     ),
// //                     Icon(Icons.visibility_outlined, size: 16, color: scheme.onSurfaceVariant),
// //                     const SizedBox(width: 4),
// //                     Text('${notice.viewCount}', style: Theme.of(context).textTheme.bodySmall),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   String _timeAgo(DateTime dt) {
// //     final diff = DateTime.now().difference(dt);
// //     if (diff.inMinutes < 1) return 'Just now';
// //     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
// //     if (diff.inHours < 24) return '${diff.inHours}h ago';
// //     return '${diff.inDays}d ago';
// //   }
// // }

// // class _ComposeNoticeSheet extends StatefulWidget {
// //   final String clinicId;
// //   const _ComposeNoticeSheet({required this.clinicId});

// //   @override
// //   State<_ComposeNoticeSheet> createState() => _ComposeNoticeSheetState();
// // }

// // class _ComposeNoticeSheetState extends State<_ComposeNoticeSheet> {
// //   final _titleController = TextEditingController();
// //   final _bodyController = TextEditingController();
// //   final _roleController = TextEditingController();
// //   String _priority = 'normal';
// //   bool _isSubmitting = false;

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _bodyController.dispose();
// //     _roleController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _submit() async {
// //     if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;
// //     setState(() => _isSubmitting = true);
// //     try {
// //       await NoticeBoardService.postNotice(
// //         widget.clinicId,
// //         title: _titleController.text.trim(),
// //         body: _bodyController.text.trim(),
// //         priority: _priority,
// //         authorRole: _roleController.text.trim().isEmpty ? 'Staff' : _roleController.text.trim(),
// //       );
// //       if (mounted) Navigator.pop(context);
// //     } finally {
// //       if (mounted) setState(() => _isSubmitting = false);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final scheme = Theme.of(context).colorScheme;
// //     return Padding(
// //       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
// //       child: Container(
// //         padding: const EdgeInsets.all(20),
// //         decoration: BoxDecoration(
// //           color: scheme.surfaceContainerLowest,
// //           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
// //         ),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               Center(
// //                 child: Container(
// //                   width: 40,
// //                   height: 4,
// //                   margin: const EdgeInsets.only(bottom: 16),
// //                   decoration: BoxDecoration(
// //                     color: scheme.outlineVariant,
// //                     borderRadius: BorderRadius.circular(2),
// //                   ),
// //                 ),
// //               ),
// //               Text('Post Notice', style: Theme.of(context).textTheme.titleLarge),
// //               const SizedBox(height: 16),
// //               TextField(
// //                 controller: _titleController,
// //                 decoration: const InputDecoration(labelText: 'Title'),
// //               ),
// //               const SizedBox(height: 12),
// //               TextField(
// //                 controller: _bodyController,
// //                 maxLines: 4,
// //                 decoration: const InputDecoration(labelText: 'Message'),
// //               ),
// //               const SizedBox(height: 12),
// //               TextField(
// //                 controller: _roleController,
// //                 decoration: const InputDecoration(labelText: 'Your role (e.g. Clinic Administrator)'),
// //               ),
// //               const SizedBox(height: 16),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: ChoiceChip(
// //                       label: const Text('Normal'),
// //                       selected: _priority == 'normal',
// //                       onSelected: (_) => setState(() => _priority = 'normal'),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: ChoiceChip(
// //                       label: const Text('Urgent'),
// //                       selected: _priority == 'urgent',
// //                       selectedColor: scheme.secondaryContainer.withOpacity(0.3),
// //                       onSelected: (_) => setState(() => _priority = 'urgent'),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _isSubmitting ? null : _submit,
// //                 child: _isSubmitting
// //                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
// //                     : const Text('Post to Board'),
// //               ),
// //               const SizedBox(height: 8),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// /// A clinic-wide announcement. Kept intentionally simple — title, body,
// /// priority, author, and a pin/view count for the Notice Board feed.
// class Notice {
//   final String id;
//   final String title;
//   final String body;
//   final String priority; // 'urgent' | 'normal'
//   final String authorName;
//   final String authorRole;
//   final DateTime createdAt;
//   final int viewCount;
//   final bool pinned;

//   Notice({
//     required this.id,
//     required this.title,
//     required this.body,
//     required this.priority,
//     required this.authorName,
//     required this.authorRole,
//     required this.createdAt,
//     this.viewCount = 0,
//     this.pinned = false,
//   });

//   factory Notice.fromFirestore(Map<String, dynamic> data, String id) => Notice(
//         id: id,
//         title: data['title'] as String? ?? '',
//         body: data['body'] as String? ?? '',
//         priority: data['priority'] as String? ?? 'normal',
//         authorName: data['authorName'] as String? ?? 'Unknown',
//         authorRole: data['authorRole'] as String? ?? '',
//         createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//         viewCount: data['viewCount'] as int? ?? 0,
//         pinned: data['pinned'] as bool? ?? false,
//       );

//   Map<String, dynamic> toJson() => {
//         'title': title,
//         'body': body,
//         'priority': priority,
//         'authorName': authorName,
//         'authorRole': authorRole,
//         'viewCount': viewCount,
//         'pinned': pinned,
//       };
// }

// class NoticeBoardService {
//   static final _db = FirebaseFirestore.instance;

//   static Stream<List<Notice>> noticesStream(String clinicId) {
//     return _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notices')
//         .orderBy('pinned', descending: true)
//         .orderBy('createdAt', descending: true)
//         .snapshots()
//         .map((snap) => snap.docs.map((d) => Notice.fromFirestore(d.data(), d.id)).toList());
//   }

//   static Future<void> postNotice(
//     String clinicId, {
//     required String title,
//     required String body,
//     required String priority,
//     required String authorRole,
//   }) async {
//     final user = FirebaseAuth.instance.currentUser!;
//     await _db.collection('clinics').doc(clinicId).collection('notices').add({
//       'title': title,
//       'body': body,
//       'priority': priority,
//       'authorName': user.displayName ?? user.email ?? 'Staff member',
//       'authorRole': authorRole,
//       'viewCount': 0,
//       'pinned': false,
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }

//   static Future<void> togglePin(String clinicId, String noticeId, bool pinned) async {
//     await _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notices')
//         .doc(noticeId)
//         .update({'pinned': !pinned});
//   }

//   static Future<void> incrementViews(String clinicId, String noticeId) async {
//     await _db
//         .collection('clinics')
//         .doc(clinicId)
//         .collection('notices')
//         .doc(noticeId)
//         .update({'viewCount': FieldValue.increment(1)});
//   }

//   static Future<void> deleteNotice(String clinicId, String noticeId) async {
//     await _db.collection('clinics').doc(clinicId).collection('notices').doc(noticeId).delete();
//   }
// }

// class NoticeBoardScreen extends StatelessWidget {
//   final String clinicId;
//   final String clinicName;
//   const NoticeBoardScreen({super.key, required this.clinicId, required this.clinicName});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Scaffold(
//       appBar: AppBar(title: Text('Notice Board · $clinicName')),
//       body: StreamBuilder<List<Notice>>(
//         stream: NoticeBoardService.noticesStream(clinicId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final notices = snapshot.data ?? [];
//           if (notices.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(32),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 72,
//                       height: 72,
//                       decoration: BoxDecoration(
//                         color: scheme.primaryContainer.withOpacity(0.15),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Icon(Icons.campaign_outlined, size: 34, color: scheme.primary),
//                     ),
//                     const SizedBox(height: 20),
//                     Text('No notices yet', style: Theme.of(context).textTheme.titleLarge),
//                     const SizedBox(height: 6),
//                     Text('Post an announcement for your team.',
//                         style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
//                   ],
//                 ),
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: notices.length,
//             itemBuilder: (context, index) => _NoticeCard(clinicId: clinicId, notice: notices[index]),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Icons.add),
//         label: const Text('Post Notice'),
//         onPressed: () => _showComposeSheet(context, clinicId),
//       ),
//     );
//   }

//   void _showComposeSheet(BuildContext context, String clinicId) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _ComposeNoticeSheet(clinicId: clinicId),
//     );
//   }
// }

// class _NoticeCard extends StatelessWidget {
//   final String clinicId;
//   final Notice notice;
//   const _NoticeCard({required this.clinicId, required this.notice});

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final isUrgent = notice.priority == 'urgent';
//     final accent = isUrgent ? scheme.secondary : scheme.primary;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: scheme.surfaceContainerLowest,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             left: 0,
//             top: 0,
//             bottom: 0,
//             child: Container(width: 4, decoration: BoxDecoration(color: accent)),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: accent.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         isUrgent ? 'Urgent' : 'Notice',
//                         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Icon(Icons.schedule, size: 14, color: scheme.onSurfaceVariant),
//                     const SizedBox(width: 4),
//                     Text(_timeAgo(notice.createdAt), style: Theme.of(context).textTheme.bodySmall),
//                     const Spacer(),
//                     IconButton(
//                       icon: Icon(
//                         notice.pinned ? Icons.push_pin : Icons.push_pin_outlined,
//                         size: 20,
//                         color: notice.pinned ? scheme.secondary : scheme.onSurfaceVariant,
//                       ),
//                       onPressed: () => NoticeBoardService.togglePin(clinicId, notice.id, notice.pinned),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(notice.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
//                 const SizedBox(height: 6),
//                 Text(notice.body, style: Theme.of(context).textTheme.bodyMedium),
//                 const SizedBox(height: 14),
//                 Divider(color: scheme.outlineVariant.withOpacity(0.3)),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 14,
//                       backgroundColor: scheme.primaryContainer.withOpacity(0.2),
//                       child: Text(
//                         notice.authorName.isNotEmpty ? notice.authorName[0].toUpperCase() : '?',
//                         style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 12),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(notice.authorName, style: Theme.of(context).textTheme.bodySmall),
//                           if (notice.authorRole.isNotEmpty)
//                             Text(notice.authorRole,
//                                 style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
//                         ],
//                       ),
//                     ),
//                     Icon(Icons.visibility_outlined, size: 16, color: scheme.onSurfaceVariant),
//                     const SizedBox(width: 4),
//                     Text('${notice.viewCount}', style: Theme.of(context).textTheme.bodySmall),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _timeAgo(DateTime dt) {
//     final diff = DateTime.now().difference(dt);
//     if (diff.inMinutes < 1) return 'Just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24) return '${diff.inHours}h ago';
//     return '${diff.inDays}d ago';
//   }
// }

// class _ComposeNoticeSheet extends StatefulWidget {
//   final String clinicId;
//   const _ComposeNoticeSheet({required this.clinicId});

//   @override
//   State<_ComposeNoticeSheet> createState() => _ComposeNoticeSheetState();
// }

// class _ComposeNoticeSheetState extends State<_ComposeNoticeSheet> {
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//   final _roleController = TextEditingController();
//   String _priority = 'normal';
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     _roleController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in both a title and a message.')),
//       );
//       return;
//     }
//     setState(() => _isSubmitting = true);
//     try {
//       await NoticeBoardService.postNotice(
//         widget.clinicId,
//         title: _titleController.text.trim(),
//         body: _bodyController.text.trim(),
//         priority: _priority,
//         authorRole: _roleController.text.trim().isEmpty ? 'Staff' : _roleController.text.trim(),
//       );
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to post notice: $e'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: scheme.surfaceContainerLowest,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: scheme.outlineVariant,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               Text('Post Notice', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _bodyController,
//                 maxLines: 4,
//                 decoration: const InputDecoration(labelText: 'Message'),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _roleController,
//                 decoration: const InputDecoration(labelText: 'Your role (e.g. Clinic Administrator)'),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text('Normal'),
//                       selected: _priority == 'normal',
//                       onSelected: (_) => setState(() => _priority = 'normal'),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: ChoiceChip(
//                       label: const Text('Urgent'),
//                       selected: _priority == 'urgent',
//                       selectedColor: scheme.secondaryContainer.withOpacity(0.3),
//                       onSelected: (_) => setState(() => _priority = 'urgent'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submit,
//                 child: _isSubmitting
//                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
//                     : const Text('Post to Board'),
//               ),
//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A clinic-wide announcement. Kept intentionally simple — title, body,
/// priority, author, and a pin/view count for the Notice Board feed.
class Notice {
  final String id;
  final String title;
  final String body;
  final String priority; // 'urgent' | 'normal'
  final String authorName;
  final String authorRole;
  final DateTime createdAt;
  final int viewCount;
  final bool pinned;

  Notice({
    required this.id,
    required this.title,
    required this.body,
    required this.priority,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    this.viewCount = 0,
    this.pinned = false,
  });

  factory Notice.fromFirestore(Map<String, dynamic> data, String id) => Notice(
        id: id,
        title: data['title'] as String? ?? '',
        body: data['body'] as String? ?? '',
        priority: data['priority'] as String? ?? 'normal',
        authorName: data['authorName'] as String? ?? 'Unknown',
        authorRole: data['authorRole'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        viewCount: data['viewCount'] as int? ?? 0,
        pinned: data['pinned'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'priority': priority,
        'authorName': authorName,
        'authorRole': authorRole,
        'viewCount': viewCount,
        'pinned': pinned,
      };
}

class NoticeBoardService {
  static final _db = FirebaseFirestore.instance;

  static Stream<List<Notice>> noticesStream(String clinicId) {
    return _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notices')
        .orderBy('pinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Notice.fromFirestore(d.data(), d.id)).toList());
  }

  static Future<void> postNotice(
    String clinicId, {
    required String title,
    required String body,
    required String priority,
    required String authorRole,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _db.collection('clinics').doc(clinicId).collection('notices').add({
      'title': title,
      'body': body,
      'priority': priority,
      'authorName': user.displayName ?? user.email ?? 'Staff member',
      'authorRole': authorRole,
      'viewCount': 0,
      'pinned': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> togglePin(String clinicId, String noticeId, bool pinned) async {
    await _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notices')
        .doc(noticeId)
        .update({'pinned': !pinned});
  }

  static Future<void> incrementViews(String clinicId, String noticeId) async {
    await _db
        .collection('clinics')
        .doc(clinicId)
        .collection('notices')
        .doc(noticeId)
        .update({'viewCount': FieldValue.increment(1)});
  }

  static Future<void> deleteNotice(String clinicId, String noticeId) async {
    await _db.collection('clinics').doc(clinicId).collection('notices').doc(noticeId).delete();
  }
}

class NoticeBoardScreen extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  const NoticeBoardScreen({super.key, required this.clinicId, required this.clinicName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Notice Board · $clinicName')),
      body: StreamBuilder<List<Notice>>(
        stream: NoticeBoardService.noticesStream(clinicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load notices:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
          final notices = snapshot.data ?? [];
          if (notices.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.campaign_outlined, size: 34, color: scheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('No notices yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('Post an announcement for your team.',
                        style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) => _NoticeCard(clinicId: clinicId, notice: notices[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Post Notice'),
        onPressed: () => _showComposeSheet(context, clinicId),
      ),
    );
  }

  void _showComposeSheet(BuildContext context, String clinicId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComposeNoticeSheet(clinicId: clinicId),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final String clinicId;
  final Notice notice;
  const _NoticeCard({required this.clinicId, required this.notice});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUrgent = notice.priority == 'urgent';
    final accent = isUrgent ? scheme.secondary : scheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, decoration: BoxDecoration(color: accent)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isUrgent ? 'Urgent' : 'Notice',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.schedule, size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(_timeAgo(notice.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        notice.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 20,
                        color: notice.pinned ? scheme.secondary : scheme.onSurfaceVariant,
                      ),
                      onPressed: () => NoticeBoardService.togglePin(clinicId, notice.id, notice.pinned),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(notice.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 6),
                Text(notice.body, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 14),
                Divider(color: scheme.outlineVariant.withOpacity(0.3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: scheme.primaryContainer.withOpacity(0.2),
                      child: Text(
                        notice.authorName.isNotEmpty ? notice.authorName[0].toUpperCase() : '?',
                        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notice.authorName, style: Theme.of(context).textTheme.bodySmall),
                          if (notice.authorRole.isNotEmpty)
                            Text(notice.authorRole,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
                        ],
                      ),
                    ),
                    Icon(Icons.visibility_outlined, size: 16, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${notice.viewCount}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ComposeNoticeSheet extends StatefulWidget {
  final String clinicId;
  const _ComposeNoticeSheet({required this.clinicId});

  @override
  State<_ComposeNoticeSheet> createState() => _ComposeNoticeSheetState();
}

class _ComposeNoticeSheetState extends State<_ComposeNoticeSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _roleController = TextEditingController();
  String _priority = 'normal';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both a title and a message.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await NoticeBoardService.postNotice(
        widget.clinicId,
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        priority: _priority,
        authorRole: _roleController.text.trim().isEmpty ? 'Staff' : _roleController.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post notice: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Post Notice', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Your role (e.g. Clinic Administrator)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Normal'),
                      selected: _priority == 'normal',
                      onSelected: (_) => setState(() => _priority = 'normal'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Urgent'),
                      selected: _priority == 'urgent',
                      selectedColor: scheme.secondaryContainer.withOpacity(0.3),
                      onSelected: (_) => setState(() => _priority = 'urgent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Post to Board'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}