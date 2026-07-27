import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/clinic_service.dart';

class StaffTab extends StatefulWidget {
  final String clinicId;
  const StaffTab({super.key, required this.clinicId});
  @override
  State<StaffTab> createState() => _StaffTabState();
}

class _StaffTabState extends State<StaffTab> {
  final _contactController = TextEditingController();
  String _method = 'email';
  StaffRole _role = StaffRole.reception;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) return;
    if (_method == 'email' && !contact.contains('@')) return;
    setState(() => _isSubmitting = true);
    try {
      await ClinicService.inviteStaff(widget.clinicId, contact, _role, method: _method);
      _contactController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invite sent to $contact'), backgroundColor: Theme.of(context).colorScheme.primary),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return StreamBuilder<ClinicMember?>(
      stream: ClinicService.myMembershipStream(widget.clinicId),
      builder: (context, meSnapshot) {
        final isAdmin = meSnapshot.data?.role == StaffRole.admin;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Invite Staff', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contactController,
                        keyboardType: _method == 'email' ? TextInputType.emailAddress : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: _method == 'email' ? 'Staff Email' : 'Phone Number',
                          prefixIcon: Icon(_method == 'email' ? Icons.email_outlined : Icons.phone_outlined),
                        ),
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: Text(_isSubmitting ? 'Sending...' : 'Send Invite'),
                        onPressed: _isSubmitting ? null : _sendInvite,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Active Members', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    StreamBuilder<List<ClinicMember>>(
                      stream: ClinicService.membersStream(widget.clinicId),
                      builder: (context, snapshot) {
                        final members = snapshot.data ?? [];
                        if (members.isEmpty) {
                          return Text('No members yet.', style: Theme.of(context).textTheme.bodyMedium);
                        }
                        return Column(
                          children: members.map((m) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: scheme.primaryContainer.withOpacity(0.2),
                                    child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                        style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.name, style: Theme.of(context).textTheme.bodyLarge),
                                        Text('${m.email} · ${m.role.label}', style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin && m.role != StaffRole.admin)
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: scheme.error, size: 20),
                                      onPressed: () => ClinicService.removeMember(widget.clinicId, m.uid),
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Pending Invites', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      StreamBuilder<List<ClinicInvite>>(
                        stream: ClinicService.pendingInvitesStream(widget.clinicId),
                        builder: (context, snapshot) {
                          final invites = snapshot.data ?? [];
                          if (invites.isEmpty) {
                            return Text('No pending invites.', style: Theme.of(context).textTheme.bodyMedium);
                          }
                          return Column(
                            children: invites.map((inv) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(inv.method == 'email' ? Icons.mail_outline : Icons.phone_iphone_outlined),
                                title: Text(inv.contact),
                                subtitle: Text(inv.role.label),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => ClinicService.cancelInvite(widget.clinicId, inv.id),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}