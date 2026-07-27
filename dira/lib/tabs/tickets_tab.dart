import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/ticket_service.dart';
import '../../widgets/ticket_card.dart';
import '../screens/ticket_detail_screen.dart';

class TicketsTab extends StatefulWidget {
  final String clinicId;
  const TicketsTab({super.key, required this.clinicId});
  @override
  State<TicketsTab> createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  String _query = '';
  TicketStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search all tickets...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _statusChip(context, null, 'All'),
                ...TicketStatus.values.map((s) => _statusChip(context, s, s.label)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<Ticket>>(
            stream: TicketService.ticketsStream(widget.clinicId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var tickets = snapshot.data ?? [];
              if (_query.isNotEmpty) {
                tickets = tickets.where((t) => t.title.toLowerCase().contains(_query.toLowerCase())).toList();
              }
              if (_statusFilter != null) {
                tickets = tickets.where((t) => t.status == _statusFilter).toList();
              }
              if (tickets.isEmpty) {
                return Center(
                    child: Text('No tickets match.', style: Theme.of(context).textTheme.bodyMedium));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return TicketCard(
                    ticket: ticket,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TicketDetailScreen(clinicId: widget.clinicId, ticketId: ticket.id)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statusChip(BuildContext context, TicketStatus? status, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _statusFilter = status),
        selectedColor: scheme.primaryContainer.withOpacity(0.3),
        labelStyle: TextStyle(color: isSelected ? scheme.primary : scheme.onSurfaceVariant),
      ),
    );
  }
}