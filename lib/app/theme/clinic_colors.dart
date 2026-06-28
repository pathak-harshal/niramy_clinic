import 'package:flutter/material.dart';

class ClinicColors extends ThemeExtension<ClinicColors> {
  final Color? confirmedStatus;
  final Color? pendingStatus;
  final Color? cancelledStatus;

  const ClinicColors({
    required this.confirmedStatus,
    required this.pendingStatus,
    required this.cancelledStatus,
  });

  @override
  ClinicColors copyWith({
    Color? confirmedStatus,
    Color? pendingStatus,
    Color? cancelledStatus,
  }) => ClinicColors(
    confirmedStatus: confirmedStatus ?? this.confirmedStatus,
    pendingStatus: pendingStatus ?? this.pendingStatus,
    cancelledStatus: cancelledStatus ?? this.cancelledStatus,
  );

  @override
  ClinicColors lerp(ThemeExtension<ClinicColors>? other, double t) {
    if (other is! ClinicColors) return this;
    return ClinicColors(
      confirmedStatus: Color.lerp(confirmedStatus, other.confirmedStatus, t),
      pendingStatus: Color.lerp(pendingStatus, other.pendingStatus, t),
      cancelledStatus: Color.lerp(cancelledStatus, other.cancelledStatus, t),
    );
  }
}
