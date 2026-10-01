import 'booking_selection_data.dart';

/// Result of the options-based config sheet (Sofa Cleaning-style, services
/// 6-11): the chosen options + quantities, the optional note, and whatever
/// /bookings/available-dates returned for that selection — the date/shift
/// sheet renders those dates next.
class OptionsConfigResult {
  final List<BookingOptionItem> options;
  final String? note;
  final List<DateTime> availableDates;

  OptionsConfigResult({
    required this.options,
    this.note,
    required this.availableDates,
  });
}
