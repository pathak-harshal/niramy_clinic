String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return 'Good Morning';
  }

  if (hour < 17) {
    return 'Good Afternoon';
  }

  return 'Good Evening';
}

/// Returns a formatted age string:
/// - "X yrs" if >= 1 year
/// - "Y mos" if < 1 year but >= 1 month
/// - "Z days" if less than 1 month
/// If the input is empty or invalid, returns an empty string.
String formatAgeFromDob(String? dobIso) {
  if (dobIso == null || dobIso.isEmpty) return '';

  try {
    final dob = DateTime.parse(dobIso);
    final now = DateTime.now();

    if (dob.isAfter(now)) return '';

    // Years
    var years = now.year - dob.year;
    final hadBirthdayThisYear =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hadBirthdayThisYear) years--;

    if (years >= 1) {
      return '$years yrs';
    }

    // Months (calculate full months)
    var months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (now.day < dob.day) months--;
    if (months >= 1) {
      return '$months mos';
    }

    // Days fallback (less than a month)
    final difference = now.difference(dob).inDays;
    if (difference >= 0) {
      return '$difference days';
    }

    return '';
  } catch (e) {
    return '';
  }
}
