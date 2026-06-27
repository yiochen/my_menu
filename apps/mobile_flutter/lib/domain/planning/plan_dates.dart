DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);

String monthShort(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[date.month - 1];
}

String weekdayShort(DateTime date) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return weekdays[date.weekday - 1];
}

String dayKeyForDate(DateTime date) {
  final DateTime normalized = startOfDay(date);
  final String month = normalized.month.toString().padLeft(2, '0');
  final String day = normalized.day.toString().padLeft(2, '0');
  return '${normalized.year}-$month-$day';
}

List<DateTime> remainingDaysInWeek([DateTime? now]) {
  final DateTime today = startOfDay(now ?? DateTime.now());
  return List<DateTime>.generate(
    DateTime.daysPerWeek - today.weekday + 1,
    (int index) => today.add(Duration(days: index)),
    growable: false,
  );
}
