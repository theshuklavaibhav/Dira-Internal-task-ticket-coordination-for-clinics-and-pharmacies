import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/clinic_service.dart';
import '../screens/billing_screen.dart';

class StaffTab extends StatefulWidget {
  final String clinicId;
  final String clinicName;
  final VoidCallback onClinicDeleted;
  const StaffTab({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.onClinicDeleted,
  });
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
      await ClinicService.inviteStaff(
        widget.clinicId,
        contact,
        _role,
        method: _method,
      );
      _contactController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite sent to $contact'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmDeleteClinic() async {
    final confirmController = TextEditingController();
    bool isDeleting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final scheme = Theme.of(dialogContext).colorScheme;
          return AlertDialog(
            title: const Text('Delete Clinic?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This permanently deletes "${widget.clinicName}" — all tickets, comments, notices, staff, and invites will be lost for everyone. This cannot be undone.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Type the clinic name to confirm:',
                  style: Theme.of(dialogContext).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(hintText: widget.clinicName),
                  onChanged: (_) => setDialogState(() {}),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: scheme.error),
                onPressed:
                    (isDeleting ||
                        confirmController.text.trim() != widget.clinicName)
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        try {
                          await ClinicService.deleteClinic(widget.clinicId);
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                          widget.onClinicDeleted();
                        } catch (e) {
                          setDialogState(() => isDeleting = false);
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: $e'),
                              backgroundColor: scheme.error,
                            ),
                          );
                        }
                      },
                child: isDeleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Delete Permanently'),
              ),
            ],
          );
        },
      ),
    );
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
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Invite Staff',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contactController,
                        keyboardType: _method == 'email'
                            ? TextInputType.emailAddress
                            : TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: _method == 'email'
                              ? 'Staff Email'
                              : 'Phone Number',
                          prefixIcon: Icon(
                            _method == 'email'
                                ? Icons.email_outlined
                                : Icons.phone_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<StaffRole>(
                        value: _role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: StaffRole.values
                            .where((r) => r != StaffRole.admin)
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send_outlined, size: 18),
                        label: Text(
                          _isSubmitting ? 'Sending...' : 'Send Invite',
                        ),
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
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Active Members',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<ClinicMember>>(
                      stream: ClinicService.membersStream(widget.clinicId),
                      builder: (context, snapshot) {
                        final members = snapshot.data ?? [];
                        if (members.isEmpty) {
                          return Text(
                            'No members yet.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                        return Column(
                          children: members.map((m) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: scheme.primaryContainer
                                        .withOpacity(0.2),
                                    child: Text(
                                      m.name.isNotEmpty
                                          ? m.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge,
                                        ),
                                        Text(
                                          '${m.email} · ${m.role.label}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdmin && m.role != StaffRole.admin)
                                    IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        color: scheme.error,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          ClinicService.removeMember(
                                            widget.clinicId,
                                            m.uid,
                                          ),
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
                ListTile(
                        leading: Icon(
                          Icons.workspace_premium_outlined,
                          color: scheme.primary,
                        ),
                        title: const Text('Manage Subscription'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BillingScreen(
                              clinicId: widget.clinicId,
                              clinicName: widget.clinicName,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.error.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: scheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Danger Zone',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: scheme.error),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Permanently delete this clinic and all of its data. This cannot be undone.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        icon: Icon(
                          Icons.delete_forever,
                          color: scheme.error,
                          size: 18,
                        ),
                        label: Text(
                          'Delete Clinic',
                          style: TextStyle(color: scheme.error),
                        ),
                        onPressed: _confirmDeleteClinic,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: scheme.error),
                        ),
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
