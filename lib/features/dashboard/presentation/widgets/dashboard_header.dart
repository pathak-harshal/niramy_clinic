import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../utils/utils.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${getGreeting()}, Doctor 👋', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, dd MMMM yyyy').format(now),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
