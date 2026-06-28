import 'package:flutter/material.dart';

import '../../../../app/theme/clinic_colors.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final clinicColors = Theme.of(context).extension<ClinicColors>()!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: clinicColors.confirmedStatus,
          child: const Icon(Icons.person),
        ),
        title: const Text('Shreeyansh Pathak'),
        subtitle: const Text('10:30 AM • Fever Consultation'),
        trailing: Chip(
          label: const Text('Confirmed'),
          backgroundColor: clinicColors.confirmedStatus,
        ),
      ),
    );
  }
}
