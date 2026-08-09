import 'package:flutter/material.dart';
import '../services/clinic_service.dart';

class CreateClinicScreen extends StatefulWidget {
  const CreateClinicScreen({super.key});
  @override
  State<CreateClinicScreen> createState() => _CreateClinicScreenState();
}

class _CreateClinicScreenState extends State<CreateClinicScreen> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ClinicService.createClinic(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create clinic: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Clinic')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.outlineVariant.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.add_business_outlined, size: 32, color: scheme.primary),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Set up your clinic', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  "Give it a name — you'll be able to invite staff and manage tickets right after.",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Clinic / Pharmacy Name',
                    prefixIcon: Icon(Icons.local_hospital_outlined),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
                      : const Text('Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}