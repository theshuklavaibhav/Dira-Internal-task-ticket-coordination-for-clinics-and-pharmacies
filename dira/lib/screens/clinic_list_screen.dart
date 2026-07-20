import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/clinic_service.dart';
import 'create_clinic_screen.dart';
import 'kanban_board_screen.dart';

class ClinicListScreen extends StatelessWidget {
  const ClinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Clinics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Clinic>>(
        stream: ClinicService.myClinicsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final clinics = snapshot.data ?? [];
          if (clinics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_hospital_outlined,
                      size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No clinics yet', style: Theme.of(context).textTheme.bodyLarge),
                  Text('Create one, or wait for a staff invite.',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.local_hospital_outlined),
                  title: Text(clinic.name),
                  subtitle: Text('Plan: ${clinic.plan}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KanbanBoardScreen(clinicId: clinic.id, clinicName: clinic.name),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Clinic'),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClinicScreen())),
      ),
    );
  }
}