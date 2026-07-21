// import 'package:flutter/material.dart';
// import '../models/models.dart';
// import '../services/clinic_service.dart';

// class InviteStaffScreen extends StatefulWidget {
//   final String clinicId;
//   const InviteStaffScreen({super.key, required this.clinicId});

//   @override
//   State<InviteStaffScreen> createState() => _InviteStaffScreenState();
// }

// class _InviteStaffScreenState extends State<InviteStaffScreen> {
//   final _emailController = TextEditingController();
//   StaffRole _role = StaffRole.reception;
//   bool _isSubmitting = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendInvite() async {
//     final email = _emailController.text.trim();
//     if (email.isEmpty || !email.contains('@')) return;
//     setState(() => _isSubmitting = true);
//     try {
//       await ClinicService.inviteStaff(widget.clinicId, email, _role);
//       _emailController.clear();
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invite sent to $email'), backgroundColor: Theme.of(context).colorScheme.primary),
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Staff & Invites')),
//       body: SingleChildScrollView(
//           child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text('Invite Staff', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(labelText: 'Staff Email', prefixIcon: Icon(Icons.email_outlined)),
//               ),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<StaffRole>(
//                 value: _role,
//                 decoration: const InputDecoration(labelText: 'Role'),
//                 items: StaffRole.values
//                     .where((r) => r != StaffRole.admin)
//                     .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _role = v!),
//               ),
//               const SizedBox(height: 12),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.send_outlined),
//                 label: const Text('Send Invite'),
//                 onPressed: _isSubmitting ? null : _sendInvite,
//               ),
//               const Divider(height: 40),
//               Text('Active Members', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 8),
//               StreamBuilder<List<ClinicMember>>(
//                 stream: ClinicService.membersStream(widget.clinicId),
//                 builder: (context, snapshot) {
//                   final members = snapshot.data ?? [];
//                   if (members.isEmpty) return const Text('No members yet.');
//                   return Column(
//                     children: members
//                         .map((m) => ListTile(
//                               leading: CircleAvatar(child: Text(m.name.isNotEmpty ? m.name[0].toUpperCase() : '?')),
//                               title: Text(m.name),
//                               subtitle: Text('${m.email} · ${m.role.label}'),
//                               trailing: m.role == StaffRole.admin
//                                   ? null
//                                   : IconButton(
//                                       icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
//                                       onPressed: () => ClinicService.removeMember(widget.clinicId, m.uid),
//                                     ),
//                             ))
//                         .toList(),
//                   );
//                 },
//               ),
//               const Divider(height: 40),
//               Text('Pending Invites', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 8),
//               StreamBuilder<List<ClinicInvite>>(
//                 stream: ClinicService.pendingInvitesStream(widget.clinicId),
//                 builder: (context, snapshot) {
//                   final invites = snapshot.data ?? [];
//                   if (invites.isEmpty) return const Text('No pending invites.');
//                   return Column(
//                     children: invites
//                         .map((inv) => ListTile(
//                               leading: const Icon(Icons.hourglass_empty),
//                               title: Text(inv.email),
//                               subtitle: Text(inv.role.label),
//                               trailing: IconButton(
//                                 icon: const Icon(Icons.close, color: Colors.redAccent),
//                                 onPressed: () => ClinicService.cancelInvite(widget.clinicId, inv.id),
//                               ),
//                             ))
//                         .toList(),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       )
//     );
//   }
// }

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
        SnackBar(
          content: Text('Invite sent to $contact'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _segmentedToggle<T>({
    required List<(T value, String label)> options,
    required T selected,
    required ValueChanged<T> onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.$1 == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? scheme.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4)]
                      : null,
                ),
                child: Text(
                  opt.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _statusChip(String status, ColorScheme scheme) {
    final isPending = status == 'pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isPending ? scheme.secondaryContainer : scheme.primaryContainer).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: (isPending ? scheme.secondaryContainer : scheme.primaryContainer).withOpacity(0.4)),
      ),
      child: Text(
        isPending ? 'Pending' : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isPending ? scheme.secondary : scheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Invite Staff')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  Text('Invite Method', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  _segmentedToggle<String>(
                    options: const [('email', 'Email'), ('phone', 'Phone')],
                    selected: _method,
                    onChanged: (v) => setState(() {
                      _method = v;
                      _contactController.clear();
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contactController,
                    keyboardType: _method == 'email' ? TextInputType.emailAddress : TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: _method == 'email' ? 'Staff Email' : 'Phone Number',
                      prefixIcon: Icon(_method == 'email' ? Icons.email_outlined : Icons.phone_outlined),
                      hintText: _method == 'email' ? 'colleague@clinic.com' : '+91 98765 43210',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Access Role', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  _segmentedToggle<StaffRole>(
                    options: StaffRole.values
                        .where((r) => r != StaffRole.admin)
                        .map((r) => (r, r.label))
                        .toList(),
                    selected: _role,
                    onChanged: (v) => setState(() => _role = v),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: Text(_isSubmitting ? 'Sending...' : 'Send Invite'),
                    onPressed: _isSubmitting ? null : _sendInvite,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                                      Text('${m.email} · ${m.role.label}',
                                          style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                if (m.role != StaffRole.admin)
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
            const SizedBox(height: 20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pending Invites', style: Theme.of(context).textTheme.titleLarge),
                      StreamBuilder<List<ClinicInvite>>(
                        stream: ClinicService.pendingInvitesStream(widget.clinicId),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$count Active',
                                style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.w600)),
                          );
                        },
                      ),
                    ],
                  ),
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    inv.method == 'email' ? Icons.mail_outline : Icons.phone_iphone_outlined,
                                    color: scheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(inv.contact, style: Theme.of(context).textTheme.bodyLarge),
                                      Text(inv.role.label, style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                                _statusChip(inv.status, scheme),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.close, size: 18, color: scheme.onSurfaceVariant),
                                  onPressed: () => ClinicService.cancelInvite(widget.clinicId, inv.id),
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
          ],
        ),
      ),
    );
  }
}