import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/clinic_service.dart';

class InviteStaffScreen extends StatefulWidget {
  final String clinicId;
  const InviteStaffScreen({super.key, required this.clinicId});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _emailController = TextEditingController();
  StaffRole _role = StaffRole.reception;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() => _isSubmitting = true);
    try {
      await ClinicService.inviteStaff(widget.clinicId, email, _role);
      _emailController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite sent to $email'), backgroundColor: Theme.of(context).colorScheme.primary),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff & Invites')),
      body: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Invite Staff', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Staff Email', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<StaffRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: StaffRole.values
                    .where((r) => r != StaffRole.admin)
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.send_outlined),
                label: const Text('Send Invite'),
                onPressed: _isSubmitting ? null : _sendInvite,
              ),
              const Divider(height: 40),
              Text('Active Members', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              StreamBuilder<List<ClinicMember>>(
                stream: ClinicService.membersStream(widget.clinicId),
                builder: (context, snapshot) {
                  final members = snapshot.data ?? [];
                  if (members.isEmpty) return const Text('No members yet.');
                  return Column(
                    children: members
                        .map((m) => ListTile(
                              leading: CircleAvatar(child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?')),
                              title: Text(m.name),
                              subtitle: Text('${m.email} · ${m.role.label}'),
                              trailing: m.role == StaffRole.admin
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () => ClinicService.removeMember(widget.clinicId, m.uid),
                                    ),
                            ))
                        .toList(),
                  );
                },
              ),
              const Divider(height: 40),
              Text('Pending Invites', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              StreamBuilder<List<ClinicInvite>>(
                stream: ClinicService.pendingInvitesStream(widget.clinicId),
                builder: (context, snapshot) {
                  final invites = snapshot.data ?? [];
                  if (invites.isEmpty) return const Text('No pending invites.');
                  return Column(
                    children: invites
                        .map((inv) => ListTile(
                              leading: const Icon(Icons.hourglass_empty),
                              title: Text(inv.email),
                              subtitle: Text(inv.role.label),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, color: Colors.redAccent),
                                onPressed: () => ClinicService.cancelInvite(widget.clinicId, inv.id),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}