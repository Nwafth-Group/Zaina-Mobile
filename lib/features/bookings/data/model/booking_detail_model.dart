import 'booking_model.dart' show VisitScheduleItem;

class BookingDetailAddress {
  final int id;
  final int serviceZoneId;
  final String serviceZoneName;
  final double latitude;
  final double longitude;
  final String formattedAddress;

  /// Already a single, server-localized string in this response — there's
  /// no `name_ar`/`name_en` split here like on other models, so no
  /// languageCode param is needed to read these.
  final String city;
  final String governorate;
  final String? country;

  final String label;
  final String street;
  final String buildingName;
  final String buildingNo;
  final String floor;
  final String apartmentNo;

  final String contactName;
  final String phoneNumber;
  final String? secondaryPhone;
  final String? notes;

  final bool isDefault;
  final bool isServiceable;

  BookingDetailAddress({
    required this.id,
    required this.serviceZoneId,
    required this.serviceZoneName,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.city,
    required this.governorate,
    this.country,
    required this.label,
    required this.street,
    required this.buildingName,
    required this.buildingNo,
    required this.floor,
    required this.apartmentNo,
    required this.contactName,
    required this.phoneNumber,
    this.secondaryPhone,
    this.notes,
    required this.isDefault,
    required this.isServiceable,
  });

  factory BookingDetailAddress.fromJson(Map<String, dynamic> json) {
    final serviceZone = json['service_zone'] as Map<String, dynamic>? ?? {};

    return BookingDetailAddress(
      id: json['id'] ?? 0,
      serviceZoneId: json['service_zone_id'] ?? 0,
      // Prefer the top-level `service_zone_name` (present directly on the
      // address), fall back to the nested object's `name`.
      serviceZoneName:
      json['service_zone_name'] ?? serviceZone['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      formattedAddress: json['formatted_address'] ?? '',
      city: json['city'] ?? '',
      governorate: json['governorate'] ?? '',
      country: json['country'],
      label: json['label'] ?? '',
      street: json['street'] ?? '',
      buildingName: json['building_name'] ?? '',
      buildingNo: json['building_no'] ?? '',
      // API sends both `floor` and `floor_no` with the same value; keep
      // reading `floor` but fall back to `floor_no` if `floor` is missing.
      floor: json['floor'] ?? json['floor_no'] ?? '',
      apartmentNo: json['apartment_no'] ?? '',
      contactName: json['contact_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      secondaryPhone: json['secondary_phone'],
      notes: json['notes'],
      isDefault: json['is_default'] ?? false,
      isServiceable: json['is_serviceable'] ?? false,
    );
  }

  /// "Governorate, City" — e.g. "القاهرة, مدينة نصر". Both are already
  /// server-localized single strings, so no languageCode param is needed.
  String get cityAreaLine =>
      [governorate, city].where((s) => s.isNotEmpty).join(', ');

  /// Falls back to building the line from parts if `formatted_address`
  /// isn't present for some reason.
  String get streetBuildingLine {
    if (formattedAddress.isNotEmpty) return formattedAddress;
    return [
      street,
      buildingName,
      'Bldg $buildingNo',
      'Floor $floor',
      'Apt $apartmentNo',
    ].where((s) => s.trim().isNotEmpty).join(', ');
  }
}

class BookingDetailWorker {
  final int id;
  final String name;
  final String? phoneNumber;
  final String nationality;
  final String gender;
  final double rating;
  final String status;
  final String image;

  BookingDetailWorker({
    required this.id,
    required this.name,
    this.phoneNumber,
    required this.nationality,
    required this.gender,
    required this.rating,
    required this.status,
    required this.image,
  });

  factory BookingDetailWorker.fromJson(Map<String, dynamic> json) {
    return BookingDetailWorker(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] as String?,
      nationality: json['nationality'] ?? '',
      gender: json['gender'] ?? '',
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      status: json['status'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class BookingPriceSummaryDetail {
  final double subtotal;
  final double tax;
  final double serviceDiscountAmount;
  final double couponDiscountAmount;
  final bool hasCoupon;
  final String? couponCode;
  final double discount;
  final double total;

  BookingPriceSummaryDetail({
    required this.subtotal,
    required this.tax,
    required this.serviceDiscountAmount,
    required this.couponDiscountAmount,
    required this.hasCoupon,
    this.couponCode,
    required this.discount,
    required this.total,
  });

  factory BookingPriceSummaryDetail.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return BookingPriceSummaryDetail(
      subtotal: d(json['subtotal']),
      tax: d(json['tax']),
      serviceDiscountAmount: d(json['service_discount_amount']),
      couponDiscountAmount: d(json['coupon_discount_amount']),
      hasCoupon: json['has_coupon'] ?? false,
      couponCode: json['coupon_code'] as String?,
      discount: d(json['discount']),
      total: d(json['total']),
    );
  }
}

class BookingServiceRulesBrief {
  final bool allowCancel;
  final int freeCancelCutoffHours;
  final bool allowReschedule;
  final int rescheduleCutoffHours;
  final int arrivalBufferMinutes;
  final int lateArrivalGraceMinutes;
  final bool allowSameDay;
  final int maxAdvanceBookingDays;

  BookingServiceRulesBrief({
    required this.allowCancel,
    required this.freeCancelCutoffHours,
    required this.allowReschedule,
    required this.rescheduleCutoffHours,
    required this.arrivalBufferMinutes,
    required this.lateArrivalGraceMinutes,
    required this.allowSameDay,
    required this.maxAdvanceBookingDays,
  });

  factory BookingServiceRulesBrief.fromJson(Map<String, dynamic> json) {
    return BookingServiceRulesBrief(
      allowCancel: json['allow_cancel'] ?? false,
      freeCancelCutoffHours: json['free_cancel_cutoff_hours'] ?? 0,
      allowReschedule: json['allow_reschedule'] ?? false,
      rescheduleCutoffHours: json['reschedule_cutoff_hours'] ?? 0,
      arrivalBufferMinutes: json['arrival_buffer_minutes'] ?? 0,
      lateArrivalGraceMinutes: json['late_arrival_grace_minutes'] ?? 0,
      allowSameDay: json['allow_same_day'] ?? false,
      maxAdvanceBookingDays: json['max_advance_booking_days'] ?? 0,
    );
  }
}

class BookingDetailModel {
  final int id;
  final String bookingReference;
  final int serviceId;
  final String serviceName;
  final String visitType; // "single_visit" | "three_visits_per_week"
  final List<VisitScheduleItem> visitSchedule;
  final String image;
  final String dateDay;
  final String dateMonth;
  final String fullDate;
  final String timeSlot;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final String currencyCode;
  final String? cancelledBy;
  final String? cancellationReason;
  final BookingServiceRulesBrief? serviceRules;
  final BookingDetailAddress? address;
  final String? cardDetailsAddressLine;
  final List<BookingDetailWorker> workers;
  final BookingPriceSummaryDetail? priceSummary;
  final List<String> importantNotes;
  final bool isReviewed;
  final bool isReported;

  BookingDetailModel({
    required this.id,
    required this.bookingReference,
    required this.serviceId,
    required this.serviceName,
    required this.visitType,
    required this.visitSchedule,
    required this.image,
    required this.dateDay,
    required this.dateMonth,
    required this.fullDate,
    required this.timeSlot,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.currencyCode,
    this.cancelledBy,
    this.cancellationReason,
    this.serviceRules,
    this.address,
    this.cardDetailsAddressLine,
    required this.workers,
    this.priceSummary,
    required this.importantNotes,
    this.isReviewed = false,
    this.isReported = false,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    final cardDetails = json['card_details'] as Map<String, dynamic>?;
    return BookingDetailModel(
      id: json['booking_id'] ?? 0,
      bookingReference: json['booking_reference'] ?? '',
      serviceId: json['service_id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      visitType: json['visit_type'] ?? 'single_visit',
      visitSchedule: (json['visit_schedule'] as List<dynamic>? ?? [])
          .map((e) => VisitScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      image: json['image'] ?? '',
      dateDay: json['date_day']?.toString() ?? '',
      dateMonth: json['date_month'] ?? '',
      fullDate: json['full_date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      bookingStatus: json['booking_status'] ?? 'Upcoming',
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      currencyCode: json['currency_code'] ?? '',
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      serviceRules: json['service_rules'] != null
          ? BookingServiceRulesBrief.fromJson(json['service_rules'] as Map<String, dynamic>)
          : null,
      address: json['address'] != null
          ? BookingDetailAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      cardDetailsAddressLine: cardDetails?['address'] as String?,
      workers: (json['workers'] as List<dynamic>? ?? [])
          .map((e) => BookingDetailWorker.fromJson(e as Map<String, dynamic>))
          .toList(),
      priceSummary: json['price_summary'] != null
          ? BookingPriceSummaryDetail.fromJson(json['price_summary'] as Map<String, dynamic>)
          : null,
      importantNotes: (json['important_notes'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      isReviewed: json['is_reviewed'] ?? false,
      isReported: json['is_reported'] ?? false,
    );
  }

  bool get isMultiVisit => visitType == 'three_visits_per_week';
  String get visitTypeLabelKey => isMultiVisit ? '3_days_per_week' : 'single_visit';

  bool get isCancelled =>
      bookingStatus.toLowerCase().replaceAll(' ', '') == 'cancelled';
  bool get isCompleted =>
      bookingStatus.toLowerCase().replaceAll(' ', '') == 'completed';
  bool get isInService =>
      bookingStatus.toLowerCase().replaceAll(' ', '') == 'inservice';
  bool get isUpcoming =>
      bookingStatus.toLowerCase().replaceAll(' ', '') == 'upcoming';

  /// "20 NOV, 2026" for single visit, "20 NOV To 25 NOV" for multi-visit.
  String get dateRangeLabel {
    if (isMultiVisit && visitSchedule.isNotEmpty) {
      final first = visitSchedule.first;
      final last = visitSchedule.last;
      return '${_shortDate(first.visitDate)} To ${_shortDate(last.visitDate)}';
    }
    return fullDate;
  }

  static String _shortDate(String yyyyMMdd) {
    final date = DateTime.tryParse(yyyyMMdd);
    if (date == null) return yyyyMMdd;
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}