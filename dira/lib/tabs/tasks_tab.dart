import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/create_ticket_sheet.dart';
import '../screens/ticket_detail_screen.dart';

class TasksTab extends StatefulWidget {
  final String clinicId;
  const TasksTab({super.key, required this.clinicId});
  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  static const _columns = [TicketStatus.open, TicketStatus.inProgress, TicketStatus.done];
  String _searchQuery = '';
  TicketType? _filterType;
  TicketPriority? _filterPriority;

  List<Ticket> _applyFilters(List<Ticket> tickets) {
    return tickets.where((t) {
      if (_searchQuery.isNotEmpty && !t.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      if (_filterType != null && t.type != _filterType) return false;
      if (_filterPriority != null && t.priority != _filterPriority) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search tickets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  isDense: true,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Ticket>>(
                stream: TicketService.ticketsStream(widget.clinicId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tickets = _applyFilters(snapshot.data ?? []);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _columns.map((status) {
                        final columnTickets = tickets.where((t) => t.status == status).toList();
                        return _KanbanColumn(
                          status: status,
                          tickets: columnTickets,
                          clinicId: widget.clinicId,
                          onTicketTap: (t) => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TicketDetailScreen(clinicId: widget.clinicId, ticketId: t.id)),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New Ticket'),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              builder: (_) => CreateTicketSheet(clinicId: widget.clinicId),
            ),
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final TicketStatus status;
  final List<Ticket> tickets;
  final String clinicId;
  final ValueChanged<Ticket> onTicketTap;
  const _KanbanColumn(
      {required this.status, required this.tickets, required this.clinicId, required this.onTicketTap});

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
      onAcceptWithDetails: (details) => TicketService.updateStatus(clinicId, details.data.id, status),
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
                width: isHovering ? 1.5 : 1),
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
                    decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
                    child: Text('${tickets.length}', style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Spacer(),
                  Icon(Icons.more_horiz, size: 18, color: colorScheme.onSurfaceVariant),
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
                                ?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.5))))
                    : ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return LongPressDraggable<Ticket>(
                            data: ticket,
                            feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(width: 280, child: TicketCard(ticket: ticket, onTap: () {}))),
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