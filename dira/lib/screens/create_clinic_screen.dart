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
        SnackBar(content: Text('Failed to create clinic: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Clinic')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Clinic / Pharmacy Name',
                prefixIcon: Icon(Icons.local_hospital_outlined),
              ),
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
    );
  }
}