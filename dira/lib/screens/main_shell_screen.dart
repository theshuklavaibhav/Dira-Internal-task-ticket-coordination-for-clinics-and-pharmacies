import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../services/clinic_service.dart';
import '../services/onesignal_notification_service.dart';
import '../screens/notifications_screen.dart';
import '../tabs/clinics_tab.dart';
import '../tabs/tasks_tab.dart';
import '../tabs/tickets_tab.dart';
import '../tabs/staff_tab.dart';


class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});
  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;
  Clinic? _selectedClinic;

  // void _selectClinic(Clinic clinic) {
  //   setState(() {
  //     _selectedClinic = clinic;
  //     _tabIndex = 1; // jump straight to Tasks once a clinic is picked
  //   });
  // }

  void _selectClinic(Clinic clinic) async {
    setState(() {
      _selectedClinic = clinic;
      _tabIndex = 1;
    });
    await ClinicService.ensureOwnerMembership(clinic.id); // self-heal
    final playerId = OneSignal.User.pushSubscription.id;
    if (playerId != null) {
      await ClinicService.updateMyPlayerId(clinic.id, playerId);
    }
  }

  void _clearSelectedClinic() {
    setState(() {
      _selectedClinic = null;
      _tabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clinic = _selectedClinic;

    final tabs = [
      ClinicsTab(selectedClinicId: clinic?.id, onSelect: _selectClinic),
      clinic == null ? const _NoClinicSelected(label: 'tasks') : TasksTab(clinicId: clinic.id),
      clinic == null ? const _NoClinicSelected(label: 'tickets') : TicketsTab(clinicId: clinic.id),
      // clinic == null ? const _NoClinicSelected(label: 'staff') : StaffTab(clinicId: clinic.id),
      clinic == null
      ? const _NoClinicSelected(label: 'staff')
      : StaffTab(clinicId: clinic.id, clinicName: clinic.name, onClinicDeleted: _clearSelectedClinic),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(clinic?.name ?? 'Dira'),
        actions: [
          if (clinic != null)
            StreamBuilder<int>(
              stream: NotificationService.unreadCount(clinic.id),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationsScreen(clinicId: clinic.id)),
                      ),
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
                          child: Text('$count',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                );
              },
            ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_hospital_outlined), label: 'Clinics'),
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Staff'),
        ],
      ),
    );
  }
}

class _NoClinicSelected extends StatelessWidget {
  final String label;
  const _NoClinicSelected({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_outlined, size: 48, color: scheme.onSurfaceVariant.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('Select a clinic first', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text('Pick a clinic from the Clinics tab to see its $label.',
                style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}