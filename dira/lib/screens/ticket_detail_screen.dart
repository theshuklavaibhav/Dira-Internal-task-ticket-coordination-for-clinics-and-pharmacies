import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/ticket_service.dart';

class TicketDetailScreen extends StatefulWidget {
  final String clinicId;
  final String ticketId;
  const TicketDetailScreen({super.key, required this.clinicId, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _commentController.text;
    if (text.trim().isEmpty) return;
    TicketService.addComment(widget.clinicId, widget.ticketId, text);
    _commentController.clear();
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              TicketService.deleteTicket(widget.clinicId, widget.ticketId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<Ticket?>(
      stream: TicketService.ticketStream(widget.clinicId, widget.ticketId),
      builder: (context, ticketSnapshot) {
        final ticket = ticketSnapshot.data;
        if (ticketSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (ticket == null) {
          return const Scaffold(body: Center(child: Text('Ticket not found.')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(ticket.title, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context)),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(ticket.type.label)),
                        Chip(label: Text(ticket.priority.name.toUpperCase())),
                        if (ticket.assigneeName != null) Chip(label: Text('Assigned: ${ticket.assigneeName}')),
                        if (ticket.dueDate != null)
                          Chip(label: Text('Due: ${DateFormat('MMM d').format(ticket.dueDate!)}')),
                      ],
                    ),
                    if (ticket.description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(ticket.description, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                    const SizedBox(height: 16),
                    SegmentedButton<TicketStatus>(
                      segments: TicketStatus.values
                          .map((s) => ButtonSegment(value: s, label: Text(s.label)))
                          .toList(),
                      selected: {ticket.status},
                      onSelectionChanged: (newSelection) {
                        TicketService.updateStatus(widget.clinicId, widget.ticketId, newSelection.first);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder(
                  stream: TicketService.commentsStream(widget.clinicId, widget.ticketId),
                  builder: (context, commentSnapshot) {
                    final docs = commentSnapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                          child: Text('No comments yet.', style: Theme.of(context).textTheme.bodyMedium));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final isMe = data['userId'] == currentUserId;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(data['userName'] ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontWeight: FontWeight.bold)),
                                Text(data['text'] ?? '',
                                    style: TextStyle(
                                        color: isMe ? colorScheme.onPrimary : colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.send_rounded), onPressed: _sendComment),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}