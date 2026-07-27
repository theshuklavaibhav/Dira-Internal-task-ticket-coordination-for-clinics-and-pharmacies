import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import 'ticket_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final String clinicId;
  const NotificationsScreen({super.key, required this.clinicId});

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: NotificationService.myNotifications(clinicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No notifications yet.', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final isRead = data['read'] == true;
              final ts = (data['createdAt'] as Timestamp?)?.toDate();

              return Container(
                decoration: BoxDecoration(
                  color: isRead ? scheme.surfaceContainerLowest : scheme.primaryContainer.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: Icon(
                    isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: isRead ? scheme.onSurfaceVariant : scheme.primary,
                  ),
                  title: Text(data['message'] ?? '',
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.w700)),
                  subtitle: ts != null ? Text(_relativeTime(ts)) : null,
                  onTap: () async {
                    await NotificationService.markRead(clinicId, doc.id);
                    if (!context.mounted) return;
                    final ticketId = data['ticketId'] as String?;
                    if (ticketId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailScreen(clinicId: clinicId, ticketId: ticketId),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}