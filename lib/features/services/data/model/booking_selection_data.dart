import '../../data/model/service_detail_model.dart';
import '../../data/model/visit_type_model.dart';

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

  /// Only set for "configurable hourly" services (e.g. Hospitality Worker).
  /// When non-null, Checkout sends `duration`/`worker_gender` to
  /// /customer/bookings INSTEAD of `visit_type` — that service type's
  /// create-booking payload has no visit_type field at all.
  final int? duration;
  final String? workerGender;

  BookingSelectionData({
    required this.serviceId,
    required this.visitType,
    required this.selectedDates,
    required this.shift,
    required this.workerCount,
    required this.preferredWorkerIds,
    this.duration,
    this.workerGender,
  });
}