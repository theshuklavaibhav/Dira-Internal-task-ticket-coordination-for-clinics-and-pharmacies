import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/clinic_service.dart';
import '../services/ticket_service.dart';
import '../widgets/ticket_card.dart';
import '../widgets/create_ticket_sheet.dart';
import 'invite_staff_screen.dart';
import 'ticket_detail_screen.dart';

class KanbanBoardScreen extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  const KanbanBoardScreen({super.key, required this.clinicId, required this.clinicName});

  static const _columns = [TicketStatus.open, TicketStatus.inProgress, TicketStatus.done];

  void _showCreateTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CreateTicketSheet(clinicId: clinicId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clinicName),
        actions: [
          StreamBuilder<ClinicMember?>(
            stream: ClinicService.myMembershipStream(clinicId),
            builder: (context, snapshot) {
              if (snapshot.data?.role != StaffRole.admin) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.group_outlined),
                tooltip: 'Staff & Invites',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => InviteStaffScreen(clinicId: clinicId)),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: TicketService.ticketsStream(clinicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final tickets = snapshot.data ?? [];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _columns.map((status) {
                final columnTickets = tickets.where((t) => t.status == status).toList();
                return _KanbanColumn(
                  status: status,
                  tickets: columnTickets,
                  clinicId: clinicId,
                  onTicketTap: (t) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailScreen(clinicId: clinicId, ticketId: t.id),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final TicketStatus status;
  final List<Ticket> tickets;
  final String clinicId;
  final ValueChanged<Ticket> onTicketTap;

  const _KanbanColumn({
    required this.status,
    required this.tickets,
    required this.clinicId,
    required this.onTicketTap,
  });

  // Color _headerColor() {
  //   switch (status) {
  //     case TicketStatus.open:
  //       return Colors.blueAccent;
  //     case TicketStatus.inProgress:
  //       return Colors.orangeAccent;
  //     case TicketStatus.done:
  //       return Colors.greenAccent.shade400;
  //   }
  // }

  Color _headerColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case TicketStatus.open:
      return scheme.tertiary;
    case TicketStatus.inProgress:
      return scheme.secondary;
    case TicketStatus.done:
      return scheme.primary;
  }
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<Ticket>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        TicketService.updateStatus(clinicId, details.data.id, status);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isHovering ? colorScheme.primaryContainer.withOpacity(0.1) : colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHovering ? colorScheme.primary : colorScheme.outlineVariant.withOpacity(0.3),
              width: isHovering ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _headerColor(context), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(status.label, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration:
                        BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                    child: Text('${tickets.length}', style: Theme.of(context).textTheme.bodySmall),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Text('No tickets',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.5))),
                      )
                    : ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return LongPressDraggable<Ticket>(
                            data: ticket,
                            feedback: Material(
                              color: Colors.transparent,
                              child: SizedBox(width: 280, child: TicketCard(ticket: ticket, onTap: () {})),
                            ),
                            childWhenDragging: Opacity(opacity: 0.3, child: TicketCard(ticket: ticket, onTap: () {})),
                            child: TicketCard(ticket: ticket, onTap: () => onTicketTap(ticket)),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}