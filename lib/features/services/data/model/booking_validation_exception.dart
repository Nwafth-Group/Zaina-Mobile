
/// Thrown when /customer/bookings/validate returns a 422 (or similar)
/// validation failure. Carries both the generic top-level `message` and the
/// specific per-field reasons from `params` (e.g. { "dates": "..." }),
/// since the field-level messages are usually the actually useful part.
class BookingValidationException implements Exception {
  final String message;
  final Map<String, String> params;

  BookingValidationException({required this.message, required this.params});

  /// The most useful text to show a user: field-level reasons if present,
  /// otherwise the generic message.
  String get displayMessage {
    if (params.isNotEmpty) {
      return params.values.join('\n');
    }
    return message;
  }

  @override
  String toString() => displayMessage;
}