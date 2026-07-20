import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/clinic_service.dart';
import '../services/ticket_service.dart';

class CreateTicketSheet extends StatefulWidget {
  final String clinicId;
  const CreateTicketSheet({super.key, required this.clinicId});

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TicketType _type = TicketType.general;
  TicketPriority _priority = TicketPriority.medium;
  DateTime? _dueDate;
  ClinicMember? _assignee;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final ticket = Ticket(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: _type,
        status: TicketStatus.open,
        priority: _priority,
        assigneeId: _assignee?.uid,
        assigneeName: _assignee?.name,
        createdBy: FirebaseAuth.instance.currentUser!.uid,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
      );
      await TicketService.createTicket(widget.clinicId, ticket);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Ticket', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TicketType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TicketType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TicketPriority>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: TicketPriority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<ClinicMember>>(
                stream: ClinicService.membersStream(widget.clinicId),
                builder: (context, snapshot) {
                  final members = snapshot.data ?? [];
                  return DropdownButtonFormField<ClinicMember>(
                    value: _assignee,
                    decoration: const InputDecoration(labelText: 'Assign to (optional)'),
                    items: members
                        .map((m) => DropdownMenuItem(value: m, child: Text('${m.name} (${m.role.label})')))
                        .toList(),
                    onChanged: (v) => setState(() => _assignee = v),
                  );
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_outlined),
                title: Text(_dueDate == null
                    ? 'Set due date (optional)'
                    : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Text('Create Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}