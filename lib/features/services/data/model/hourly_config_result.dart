
class HourlyConfigResult {
  final String startTime; // "HH:mm"
  final int duration; // hours
  final String workerGender;
  final int workersCount;
  final List<DateTime> availableDates;

  HourlyConfigResult({
    required this.startTime,
    required this.duration,
    required this.workerGender,
    required this.workersCount,
    required this.availableDates,
  });

  /// "HH:mm" computed as startTime + duration hours (wraps past midnight).
  String get endTime {
    final parts = startTime.split(':');
    final startHour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? parts[1] : '00';
    final endHour = (startHour + duration) % 24;
    return '${endHour.toString().padLeft(2, '0')}:$minute';
  }
}