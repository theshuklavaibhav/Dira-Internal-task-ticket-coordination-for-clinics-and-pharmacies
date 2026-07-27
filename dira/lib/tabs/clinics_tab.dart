import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/clinic_service.dart';
import '../screens/create_clinic_screen.dart';
import '../screens/notice_board_screen.dart';

class ClinicsTab extends StatelessWidget {
  final String? selectedClinicId;
  final ValueChanged<Clinic> onSelect;
  const ClinicsTab({super.key, this.selectedClinicId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        StreamBuilder<List<Clinic>>(
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: clinics.length,
              itemBuilder: (context, index) {
                final clinic = clinics[index];
                final isSelected = clinic.id == selectedClinicId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? scheme.primary : scheme.outlineVariant.withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onSelect(clinic),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [scheme.primary, scheme.tertiary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                clinic.name.isNotEmpty ? clinic.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
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
                                    child: Text(clinic.plan.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.w700, color: scheme.secondary)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.campaign_outlined, color: scheme.primary, size: 22),
                              tooltip: 'Notice Board',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NoticeBoardScreen(clinicId: clinic.id, clinicName: clinic.name),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: scheme.primary)
                            else
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
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: const Text('New Clinic'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClinicScreen())),
          ),
        ),
      ],
    );
  }
}