import 'service_detail_model.dart';
import 'visit_type_model.dart';

class BookingSelectionData {
  final int serviceId;
  final VisitTypeModel visitType;
  final List<DateTime> selectedDates;
  final ServiceShiftModel shift;
  final int workerCount;

  /// IDs of specifically chosen preferred workers. Empty when the user
  /// didn't pick any (either no preferred workers existed for this service,
  /// or they left it to random assignment) — the backend assigns randomly
  /// in that case.
  final List<int> preferredWorkerIds;

  /// Only set for "configurable hourly" services (e.g. Hospitality Worker,
  /// Babysitter). When non-null, Checkout sends `duration`/other config
  /// fields to /customer/bookings INSTEAD of `visit_type` — those service
  /// types' create-booking payloads have no visit_type field at all.
  final int? duration;

  /// Only set for services with an actual gender choice (e.g. Hospitality
  /// Worker). Null for services like Babysitter, which only offer one
  /// gender option — that service's real payload has no worker_gender key.
  final String? workerGender;

  /// Babysitter-style fields — null/empty for services without children.
  final int? numberOfChildren;
  final List<int>? childAgeGroupIds;
  final String? note;

  /// Pedicure & Manicure-style field — how many persons this booking
  /// covers. Null for services without a number-of-persons concept.
  final int? numberOfPersons;

  BookingSelectionData({
    required this.serviceId,
    required this.visitType,
    required this.selectedDates,
    required this.shift,
    required this.workerCount,
    required this.preferredWorkerIds,
    this.duration,
    this.workerGender,
    this.numberOfChildren,
    this.childAgeGroupIds,
    this.note,
    this.numberOfPersons,
  });
}