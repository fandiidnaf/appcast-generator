class DateFormatter {
  DateFormatter._();

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Formats [dt] to RFC 822 / 2822 format (e.g. "Thu, 15 Jan 2026 00:00:00 +0000").
  static String toRfc822(DateTime dt) {
    final utc = dt.toUtc();
    final dayName = _days[utc.weekday - 1];
    final day = utc.day.toString().padLeft(2, '0');
    final monthName = _months[utc.month - 1];
    final year = utc.year.toString();
    final hour = utc.hour.toString().padLeft(2, '0');
    final min = utc.minute.toString().padLeft(2, '0');
    final sec = utc.second.toString().padLeft(2, '0');
    return '$dayName, $day $monthName $year $hour:$min:$sec +0000';
  }

  /// Parses RFC 822 / RFC 2822 or ISO-8601 strings into a [DateTime].
  static DateTime parseRfc822(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return DateTime.now();

    // Check ISO format first
    final iso = DateTime.tryParse(trimmed);
    if (iso != null) return iso;

    try {
      final sanitized = trimmed.replaceAll(',', '');
      final parts = sanitized.split(RegExp(r'\s+'));
      // Expecting [DayName, Day, Month, Year, Time, Timezone]
      if (parts.length >= 5) {
        final day = int.parse(parts[1]);
        final monthStr = parts[2];
        final monthIdx = _months.indexWhere((m) => m.toLowerCase() == monthStr.toLowerCase());
        final month = monthIdx != -1 ? monthIdx + 1 : 1;
        final year = int.parse(parts[3]);
        final timeParts = parts[4].split(':');
        final hour = int.parse(timeParts[0]);
        final min = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        final sec = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
        return DateTime.utc(year, month, day, hour, min, sec);
      }
    } catch (_) {
      // Fallback
    }
    return DateTime.now();
  }
}
