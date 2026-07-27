// // import 'package:flutter/material.dart';
// // import '../models/models.dart';

// // class TicketCard extends StatelessWidget {
// //   final Ticket ticket;
// //   final VoidCallback onTap;

// //   const TicketCard({super.key, required this.ticket, required this.onTap});

// //   Color _priorityColor() {
// //     switch (ticket.priority) {
// //       case TicketPriority.urgent:
// //         return Colors.redAccent;
// //       case TicketPriority.high:
// //         return Colors.orangeAccent;
// //       case TicketPriority.medium:
// //         return Colors.amber;
// //       case TicketPriority.low:
// //         return Colors.greenAccent.shade400;
// //     }
// //   }

// //   IconData _typeIcon() {
// //     switch (ticket.type) {
// //       case TicketType.itIssue:
// //         return Icons.build_outlined;
// //       case TicketType.restock:
// //         return Icons.inventory_2_outlined;
// //       case TicketType.staffRequest:
// //         return Icons.badge_outlined;
// //       case TicketType.patientCallback:
// //         return Icons.phone_outlined;
// //       case TicketType.general:
// //         return Icons.task_alt_outlined;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final colorScheme = Theme.of(context).colorScheme;
// //     final isOverdue = ticket.dueDate != null &&
// //         ticket.dueDate!.isBefore(DateTime.now()) &&
// //         ticket.status != TicketStatus.done;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6),
// //       clipBehavior: Clip.antiAlias,
// //       child: InkWell(
// //         onTap: onTap,
// //         child: Container(
// //           decoration: BoxDecoration(border: Border(left: BorderSide(color: _priorityColor(), width: 4))),
// //           padding: const EdgeInsets.all(12),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Row(
// //                 children: [
// //                   Icon(_typeIcon(), size: 16, color: colorScheme.onSurfaceVariant),
// //                   const SizedBox(width: 6),
// //                   Expanded(
// //                     child: Text(ticket.type.label,
// //                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 6),
// //               Text(ticket.title,
// //                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis),
// //               const SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   if (ticket.assigneeName != null) ...[
// //                     CircleAvatar(
// //                       radius: 10,
// //                       backgroundColor: colorScheme.primary.withOpacity(0.2),
// //                       child: Text(ticket.assigneeName!.isNotEmpty ? ticket.assigneeName![0].toUpperCase() : '?',
// //                           style: TextStyle(fontSize: 10, color: colorScheme.primary)),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Expanded(
// //                       child: Text(ticket.assigneeName!,
// //                           style: Theme.of(context).textTheme.bodySmall,
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis),
// //                     ),
// //                   ] else
// //                     Expanded(
// //                       child: Text('Unassigned',
// //                           style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
// //                     ),
// //                   if (ticket.dueDate != null)
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //                       decoration: BoxDecoration(
// //                         color: isOverdue ? Colors.redAccent.withOpacity(0.2) : colorScheme.surfaceContainerHighest,
// //                         borderRadius: BorderRadius.circular(6),
// //                       ),
// //                       child: Text('${ticket.dueDate!.day}/${ticket.dueDate!.month}',
// //                           style: TextStyle(
// //                               fontSize: 11, color: isOverdue ? Colors.redAccent : colorScheme.onSurfaceVariant)),
// //                     ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../models/models.dart';

// class TicketCard extends StatelessWidget {
//   final Ticket ticket;
//   final VoidCallback onTap;
//   const TicketCard({super.key, required this.ticket, required this.onTap});

//   Color _priorityColor(ColorScheme scheme) {
//     switch (ticket.priority) {
//       case TicketPriority.urgent:
//         return scheme.error;
//       case TicketPriority.high:
//         return scheme.secondary;
//       case TicketPriority.medium:
//         return scheme.tertiary;
//       case TicketPriority.low:
//         return scheme.primary.withOpacity(0.5);
//     }
//   }

//   IconData _typeIcon() {
//     switch (ticket.type) {
//       case TicketType.itIssue:
//         return Icons.build_outlined;
//       case TicketType.restock:
//         return Icons.inventory_2_outlined;
//       case TicketType.staffRequest:
//         return Icons.badge_outlined;
//       case TicketType.patientCallback:
//         return Icons.phone_outlined;
//       case TicketType.general:
//         return Icons.task_alt_outlined;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final isOverdue = ticket.dueDate != null &&
//         ticket.dueDate!.isBefore(DateTime.now()) &&
//         ticket.status != TicketStatus.done;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         color: scheme.surfaceContainerLowest,
//         borderRadius: BorderRadius.circular(12),
//         border: Border(left: BorderSide(color: _priorityColor(scheme), width: 4)),
//         boxShadow: [BoxShadow(color: scheme.primary.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: onTap,
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(_typeIcon(), size: 15, color: scheme.onSurfaceVariant),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(ticket.type.label,
//                           style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   ticket.title,
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     if (ticket.assigneeName != null) ...[
//                       CircleAvatar(
//                         radius: 11,
//                         backgroundColor: scheme.primaryContainer.withOpacity(0.2),
//                         child: Text(ticket.assigneeName![0].toUpperCase(),
//                             style: TextStyle(fontSize: 10, color: scheme.primary, fontWeight: FontWeight.w700)),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(ticket.assigneeName!,
//                             style: Theme.of(context).textTheme.bodySmall,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis),
//                       ),
//                     ] else
//                       Expanded(
//                         child: Text('Unassigned',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(fontStyle: FontStyle.italic)),
//                       ),
//                     if (ticket.dueDate != null)
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//                         decoration: BoxDecoration(
//                           color: isOverdue ? scheme.errorContainer.withOpacity(0.5) : scheme.surfaceContainerHigh,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Text('${ticket.dueDate!.day}/${ticket.dueDate!.month}',
//                             style: TextStyle(
//                                 fontSize: 11,
//                                 color: isOverdue ? scheme.error : scheme.onSurfaceVariant,
//                                 fontWeight: FontWeight.w600)),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/models.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color _priorityColor(ColorScheme scheme) {
    switch (ticket.priority) {
      case TicketPriority.urgent:
        return scheme.error;
      case TicketPriority.high:
        return scheme.secondary;
      case TicketPriority.medium:
        return scheme.tertiary;
      case TicketPriority.low:
        return scheme.onSurfaceVariant;
    }
  }

  String _priorityLabel() {
    switch (ticket.priority) {
      case TicketPriority.urgent:
        return 'Urgent';
      case TicketPriority.high:
        return 'High Priority';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.low:
        return 'Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final priorityColor = _priorityColor(scheme);
    final isOverdue = ticket.dueDate != null &&
        ticket.dueDate!.isBefore(DateTime.now()) &&
        ticket.status != TicketStatus.done;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority pill (or a subtle placeholder bar when low priority, matching the reference)
                if (ticket.priority == TicketPriority.low)
                  Container(
                    width: 70,
                    height: 20,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _priorityLabel(),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: priorityColor),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  ticket.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (ticket.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    ticket.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),
                Divider(color: scheme.outlineVariant.withOpacity(0.3), height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 15, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      ticket.dueDate == null
                          ? 'No due date'
                          : _friendlyDate(ticket.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isOverdue ? scheme.error : scheme.onSurfaceVariant,
                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.normal,
                          ),
                    ),
                    const Spacer(),
                    if (ticket.assigneeName != null)
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: scheme.primaryContainer.withOpacity(0.25),
                        child: Text(
                          ticket.assigneeName![0].toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.primary),
                        ),
                      )
                    else
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_outline, size: 15, color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today, ${_formatTime(date)}';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}