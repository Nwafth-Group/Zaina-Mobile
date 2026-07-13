class HourlyConfigResult {
  final String startTime; // "HH:mm"
  final int duration; // hours
  final String? workerGender; // null when the service has no gender choice
  final int workersCount;
  final List<DateTime> availableDates;

  /// Babysitter-style fields — null/empty for services without children.
  final int? numberOfChildren;
  final List<int>? childAgeGroupIds; // one entry per child
  final String? note;

  HourlyConfigResult({
    required this.startTime,
    required this.duration,
    this.workerGender,
    required this.workersCount,
    required this.availableDates,
    this.numberOfChildren,
    this.childAgeGroupIds,
    this.note,
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