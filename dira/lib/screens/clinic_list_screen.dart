// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../models/models.dart';
// import '../services/clinic_service.dart';
// import 'create_clinic_screen.dart';
// import 'kanban_board_screen.dart';

// class ClinicListScreen extends StatelessWidget {
//   const ClinicListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Clinics'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () => FirebaseAuth.instance.signOut(),
//           ),
//         ],
//       ),
//       body: StreamBuilder<List<Clinic>>(
//         stream: ClinicService.myClinicsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//           final clinics = snapshot.data ?? [];
//           if (clinics.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.local_hospital_outlined,
//                       size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
//                   const SizedBox(height: 16),
//                   Text('No clinics yet', style: Theme.of(context).textTheme.bodyLarge),
//                   Text('Create one, or wait for a staff invite.',
//                       style: Theme.of(context).textTheme.bodyMedium),
//                 ],
//               ),
//             );
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: clinics.length,
//             itemBuilder: (context, index) {
//               final clinic = clinics[index];
//               return Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.local_hospital_outlined),
//                   title: Text(clinic.name),
//                   subtitle: Text('Plan: ${clinic.plan}'),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => KanbanBoardScreen(clinicId: clinic.id, clinicName: clinic.name),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Icons.add),
//         label: const Text('New Clinic'),
//         onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClinicScreen())),
//       ),
//     );
//   }
// }


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
    final scheme = Theme.of(context).colorScheme;
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
          final clinics = snapshot.data ?? [];
          if (clinics.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.local_hospital_outlined, size: 34, color: scheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text('No clinics yet', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('Create one, or wait for a staff invite.',
                        style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KanbanBoardScreen(clinicId: clinic.id, clinicName: clinic.name),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.local_hospital_outlined, color: scheme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clinic.name, style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: scheme.secondaryContainer.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    clinic.plan.toUpperCase(),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.secondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                        ],
                      ),
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