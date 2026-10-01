import 'service_detail_model.dart';
import 'visit_type_model.dart';

/// One chosen option + quantity for options-based services (Sofa Cleaning
/// etc.). Carries the display fields too so Checkout can list what was
/// picked without re-looking anything up; only { id, quantity } is sent to
/// the API.
class BookingOptionItem {
  final int id;
  final int quantity;
  final String nameAr;
  final String nameEn;
  final double unitPrice;

  BookingOptionItem({
    required this.id,
    required this.quantity,
    required this.nameAr,
    required this.nameEn,
    required this.unitPrice,
  });

  factory BookingOptionItem.fromOption(ServiceOptionModel option, int quantity) {
    return BookingOptionItem(
      id: option.id,
      quantity: quantity,
      nameAr: option.nameAr,
      nameEn: option.nameEn,
      unitPrice: option.unitPrice,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'quantity': quantity};

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}

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

  /// Options-based services (Sofa Cleaning-style) — the chosen options with
  /// quantities. Null for every other service type. When non-null, the
  /// /validate and /bookings payloads carry `options` and NO workers_count.
  final List<BookingOptionItem>? options;

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
    this.options,
  });
}