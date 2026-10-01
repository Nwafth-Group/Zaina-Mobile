import 'visit_type_model.dart';

class ServiceFeatureModel {
  final String ar;
  final String en;
  ServiceFeatureModel({required this.ar, required this.en});

  factory ServiceFeatureModel.fromJson(Map<String, dynamic> json) {
    return ServiceFeatureModel(ar: json['ar'] ?? '', en: json['en'] ?? '');
  }

  String localized(String languageCode) => languageCode == 'ar' ? ar : en;
}

class ServiceRulesModel {
  final int id;
  final int freeCancelCutoffHours;
  final int rescheduleCutoffHours;
  final bool allowCancel;
  final bool allowReschedule;
  final bool allowSameDay;
  final int maxAdvanceBookingDays;
  final int arrivalBufferMinutes;
  final int lateArrivalGraceMinutes;

  ServiceRulesModel({
    required this.id,
    required this.freeCancelCutoffHours,
    required this.rescheduleCutoffHours,
    required this.allowCancel,
    required this.allowReschedule,
    required this.allowSameDay,
    required this.maxAdvanceBookingDays,
    required this.arrivalBufferMinutes,
    required this.lateArrivalGraceMinutes,
  });

  factory ServiceRulesModel.fromJson(Map<String, dynamic> json) {
    return ServiceRulesModel(
      id: json['id'] ?? 0,
      freeCancelCutoffHours: json['free_cancel_cutoff_hours'] ?? 0,
      rescheduleCutoffHours: json['reschedule_cutoff_hours'] ?? 0,
      allowCancel: json['allow_cancel'] ?? false,
      allowReschedule: json['allow_reschedule'] ?? false,
      allowSameDay: json['allow_same_day'] ?? false,
      maxAdvanceBookingDays: json['max_advance_booking_days'] ?? 0,
      arrivalBufferMinutes: json['arrival_buffer_minutes'] ?? 0,
      lateArrivalGraceMinutes: json['late_arrival_grace_minutes'] ?? 0,
    );
  }
}

/// A bookable time slot, e.g. { start_time: "09:00", end_time: "11:00" }
class ServiceShiftModel {
  final String startTime; // "HH:mm" (may include seconds)
  final String endTime;

  ServiceShiftModel({required this.startTime, required this.endTime});

  factory ServiceShiftModel.fromJson(Map<String, dynamic> json) {
    return ServiceShiftModel(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }

  int get _startHour {
    final parts = startTime.split(':');
    return parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
  }

  bool get isMorning => _startHour < 12;

  /// "HH:mm" without seconds, for display.
  String get startLabel {
    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  /// "hh:mm a" (12-hour format), for display.
  String get startLabel12 {
    final parts = startTime.split(':');
    if (parts.length < 2) return startTime;

    final hour = int.tryParse(parts[0]);
    final minute = parts[1].padLeft(2, '0');

    if (hour == null) return startTime;

    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    return '${hour12.toString().padLeft(2, '0')}:$minute';
  }

  /// "HH:mm" without seconds, for display.
  String get endLabel {
    final parts = endTime.split(':');
    if (parts.length < 2) return endTime;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  /// Localization key — add 'morning' / 'evening' to en.json / ar.json.
  String get periodLabelKey => isMorning ? 'morning' : 'evening';
}

/// Matches the real /customer/services/{id} response:
/// { id, name, nationality, rating, status, image }
class PreferredWorkerModel {
  final int id;
  final String name;
  final String nationality;
  final double rating;
  final String status; // e.g. "active"
  final String? image;

  PreferredWorkerModel({
    required this.id,
    required this.name,
    required this.nationality,
    required this.rating,
    required this.status,
    required this.image,
  });

  factory PreferredWorkerModel.fromJson(Map<String, dynamic> json) {
    return PreferredWorkerModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nationality: json['nationality'] ?? '',
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      status: json['status'] ?? '',
      image: json['image'] as String?,
    );
  }

  bool get isActive => status == 'active';
}

/// One selectable age bracket for babysitting-style services, e.g.
/// { name: "Newborn to 2 Years", age_from: 0, age_to: 24, required_worker_count: 1 }
class ChildAgeGroupModel {
  final int id;
  final int serviceId;
  final String nameAr;
  final String nameEn;
  final int ageFrom;
  final int ageTo;
  final String calculationType;
  final int childrenCount;
  final int requiredWorkerCount;
  final String status;

  ChildAgeGroupModel({
    required this.id,
    required this.serviceId,
    required this.nameAr,
    required this.nameEn,
    required this.ageFrom,
    required this.ageTo,
    required this.calculationType,
    required this.childrenCount,
    required this.requiredWorkerCount,
    required this.status,
  });

  factory ChildAgeGroupModel.fromJson(Map<String, dynamic> json) {
    return ChildAgeGroupModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      ageFrom: json['age_from'] ?? 0,
      ageTo: json['age_to'] ?? 0,
      calculationType: json['calculation_type'] ?? '',
      childrenCount: json['children_count'] ?? 1,
      requiredWorkerCount: json['required_worker_count'] ?? 1,
      status: json['status'] ?? '',
    );
  }

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}

/// Points-based completion reward for a service, e.g.
/// { points: 30, required_booking_count: 1, frequency_type: "repeatable" }
class RewardRuleModel {
  final int id;
  final String titleAr;
  final String titleEn;
  final String subtitleAr;
  final String subtitleEn;
  final int points;
  final int requiredBookingCount;
  final String frequencyType; // e.g. "repeatable"

  RewardRuleModel({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.subtitleAr,
    required this.subtitleEn,
    required this.points,
    required this.requiredBookingCount,
    required this.frequencyType,
  });

  factory RewardRuleModel.fromJson(Map<String, dynamic> json) {
    return RewardRuleModel(
      id: json['id'] ?? 0,
      titleAr: json['title_ar'] ?? '',
      titleEn: json['title_en'] ?? '',
      subtitleAr: json['subtitle_ar'] ?? '',
      subtitleEn: json['subtitle_en'] ?? '',
      points: json['points'] ?? 0,
      requiredBookingCount: json['required_booking_count'] ?? 1,
      frequencyType: json['frequency_type'] ?? '',
    );
  }

  String localizedTitle(String languageCode) =>
      languageCode == 'ar' ? titleAr : titleEn;

  String localizedSubtitle(String languageCode) =>
      languageCode == 'ar' ? subtitleAr : subtitleEn;

  bool get isRepeatable => frequencyType == 'repeatable';
}

/// One selectable, priced item for options-based services (ids 6-11), e.g.
/// { name_en: "One-seat Sofa", unit_price: 50, min_qty: 1, max_qty: 10 }
class ServiceOptionModel {
  final int id;
  final int serviceId;
  final String nameAr;
  final String nameEn;
  final double unitPrice;
  final int minQty;
  final int maxQty;
  final String status; // e.g. "active"
  final int sortOrder;

  ServiceOptionModel({
    required this.id,
    required this.serviceId,
    required this.nameAr,
    required this.nameEn,
    required this.unitPrice,
    required this.minQty,
    required this.maxQty,
    required this.status,
    required this.sortOrder,
  });

  factory ServiceOptionModel.fromJson(Map<String, dynamic> json) {
    return ServiceOptionModel(
      id: json['id'] ?? 0,
      serviceId: json['service_id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      unitPrice: double.tryParse('${json['unit_price'] ?? 0}') ?? 0,
      minQty: json['min_qty'] ?? 1,
      maxQty: json['max_qty'] ?? 1,
      status: json['status'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
    );
  }

  bool get isActive => status == 'active';

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}

/// Which booking flow a service uses. Determined by service ID — the only
/// signal that's proven reliably static. Every JSON-derived field tried so
/// far (has_duration_range, worker_gender_options, pricing_type,
/// covered_persons_per_worker, available_shifts shape) fails to distinguish
/// cleanly: e.g. service 4 has has_duration_range: false like services 1 & 5,
/// but still needs the /available-dates check like services 2 & 3.
///
/// Confirmed mapping (ids are static, per product):
///   1 = Domestic Helper (Hourly)     -> fixedShift
///   2 = Hospitality Worker (Hourly)  -> configurableHourly
///   3 = Babysitter (Hourly)          -> configurableChildren
///   4 = Pedicure & Manicure Service  -> configurablePersons
///   5 = Deep Cleaning Service        -> fixedShift
///   6-11 = "Other" services (Sofa Cleaning etc.) -> optionsBased
///
/// The optionsBased case is the one exception to the id-only rule: those
/// services are the ones whose response carries a non-empty `options` list,
/// and any future service added the same way should behave identically, so
/// it's keyed off that list rather than hardcoding ids 6..11.
enum ServiceBookingFlow {
  /// Pick from pre-set shifts directly on a calendar. No /available-dates call.
  fixedShift,

  /// Configure start time/duration/gender/workers, THEN check availability.
  configurableHourly,

  /// Configure start time/duration/children+age-groups/workers, THEN check availability.
  configurableChildren,

  /// Configure start time/duration/workers/number_of_persons, THEN check availability.
  configurablePersons,

  /// Pick priced options + quantities (e.g. sofa sizes), THEN check
  /// availability, then pick a date + shift. Workers are team-assigned by
  /// the backend — no workers_count in any of this flow's payloads.
  optionsBased,
}

class ServiceDetailModel {
  final int id;
  final int? addressId;
  final String type;
  final String serviceCode;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final List<ServiceFeatureModel> features;
  final double avgRating;
  final List<VisitTypeModel> availableVisitTypes;
  final String startTime;
  final String endTime;
  final int defaultDuration;
  final bool hasDurationRange;
  final int minDuration;
  final int maxDuration;
  final int minWorkers;
  final int maxWorkers;
  final double basePrice;
  final ServiceRulesModel rules;
  final String? image;
  final List<PreferredWorkerModel> preferredWorkers;
  final List<DateTime> availableDates;
  final List<String> availableDays;
  final List<ServiceShiftModel> availableShifts;

  /// New (service 2+ style) fields — empty/default for services that don't
  /// send them, so this stays backward-compatible with service 1's response.
  final List<String> workerGenderOptions;
  final String pricingType; // e.g. "per_hour"
  final String status; // e.g. "active"

  /// Babysitter-style fields (service 3+) — 0/empty for services that don't
  /// have children involved at all.
  final int minChildren;
  final int maxChildren;
  final List<ChildAgeGroupModel> childAgeGroups;

  /// How many persons a single worker can cover in one booking (e.g. Pedicure
  /// & Manicure). Present on every service so far with value 1; kept as a
  /// plain field rather than a flow-distinguishing signal — see
  /// [ServiceBookingFlow] doc comment for why it doesn't reliably
  /// distinguish services on its own.
  final int coveredPersonsPerWorker;

  /// Completion reward shown on the service detail screen — null if the
  /// service has no reward configured.
  final RewardRuleModel? rewardRule;

  /// Options-based services (ids 6-11, e.g. Sofa Cleaning) — the priced,
  /// quantity-selectable items the user books. Empty for services 1-5.
  final List<ServiceOptionModel> options;

  /// Options-based services are fulfilled by backend-assigned teams rather
  /// than user-selected worker counts.
  final bool isTeamBased;

  /// Which booking flow this service uses — see [ServiceBookingFlow].
  ServiceBookingFlow get bookingFlow {
    switch (id) {
      case 2:
        return ServiceBookingFlow.configurableHourly;
      case 3:
        return ServiceBookingFlow.configurableChildren;
      case 4:
        return ServiceBookingFlow.configurablePersons;
      case 1:
      case 5:
        return ServiceBookingFlow.fixedShift;
      default:
        // Services 6-11 (and any future ones built the same way) carry a
        // non-empty priced `options` list — see ServiceBookingFlow docs.
        return options.isNotEmpty
            ? ServiceBookingFlow.optionsBased
            : ServiceBookingFlow.fixedShift;
    }
  }

  /// True only for the options-based flow (Sofa Cleaning-style, ids 6-11).
  bool get hasOptions => bookingFlow == ServiceBookingFlow.optionsBased;

  /// True for services where the user configures hourly-style settings first
  /// (start time/duration/gender-or-children-or-persons/worker count) THEN
  /// checks availability via /bookings/available-dates, as opposed to picking
  /// from fixed pre-set shifts directly (Domestic Helper-, Deep Cleaning-style)
  /// or the options-based flow (Sofa Cleaning-style), which has its own sheet.
  bool get isConfigurableHourly =>
      bookingFlow != ServiceBookingFlow.fixedShift &&
      bookingFlow != ServiceBookingFlow.optionsBased;

  /// True only for the Babysitter-style children/age-group flow.
  bool get hasChildren => bookingFlow == ServiceBookingFlow.configurableChildren;

  /// True only for the Pedicure & Manicure-style number-of-persons flow.
  bool get hasPersonsCount =>
      bookingFlow == ServiceBookingFlow.configurablePersons;

  /// Only show a gender picker when there's an actual choice to make —
  /// Babysitter/Pedicure only ever offer one gender option, so there's
  /// nothing to pick and the field is omitted entirely from requests
  /// (confirmed: the real /available-dates and /bookings payloads for those
  /// services have no worker_gender key at all).
  bool get hasGenderChoice => workerGenderOptions.length > 1;

  ServiceDetailModel({
    required this.id,
    required this.addressId,
    required this.type,
    required this.serviceCode,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.features,
    required this.avgRating,
    required this.availableVisitTypes,
    required this.startTime,
    required this.endTime,
    required this.defaultDuration,
    required this.hasDurationRange,
    required this.minDuration,
    required this.maxDuration,
    required this.minWorkers,
    required this.maxWorkers,
    required this.basePrice,
    required this.rules,
    required this.image,
    required this.preferredWorkers,
    required this.availableDates,
    required this.availableDays,
    required this.availableShifts,
    this.workerGenderOptions = const [],
    this.pricingType = '',
    this.status = '',
    this.minChildren = 0,
    this.maxChildren = 0,
    this.childAgeGroups = const [],
    this.coveredPersonsPerWorker = 1,
    this.rewardRule,
    this.options = const [],
    this.isTeamBased = false,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    return ServiceDetailModel(
      id: json['id'] as int,
      addressId: json['address_id'] as int?,
      type: json['type'] ?? '',
      serviceCode: json['service_code'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => ServiceFeatureModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      avgRating: double.tryParse('${json['avg_rating'] ?? 0}') ?? 0,
      availableVisitTypes: (json['available_visit_types'] as List<dynamic>? ?? [])
          .map((e) => VisitTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      defaultDuration: json['default_duration'] ?? 1,
      hasDurationRange: json['has_duration_range'] ?? false,
      minDuration: json['min_duration'] ?? 1,
      maxDuration: json['max_duration'] ?? 1,
      minWorkers: json['min_workers'] ?? 1,
      maxWorkers: json['max_workers'] ?? 1,
      basePrice: double.tryParse('${json['base_price'] ?? 0}') ?? 0,
      rules: ServiceRulesModel.fromJson(
          json['rules'] as Map<String, dynamic>? ?? {}),
      image: json['image'] as String?,
      preferredWorkers: (json['preferred_workers'] as List<dynamic>? ?? [])
          .map((e) => PreferredWorkerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableDates: (json['available_dates'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e as String))
          .toList(),
      availableDays: (json['available_days'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      availableShifts: (json['available_shifts'] as List<dynamic>? ?? [])
          .map((e) => ServiceShiftModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      workerGenderOptions: (json['worker_gender_options'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      pricingType: json['pricing_type'] ?? '',
      status: json['status'] ?? '',
      minChildren: json['min_children'] ?? 0,
      maxChildren: json['max_children'] ?? 0,
      childAgeGroups: (json['child_age_groups'] as List<dynamic>? ?? [])
          .map((e) => ChildAgeGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      coveredPersonsPerWorker: json['covered_persons_per_worker'] ?? 1,
      rewardRule: json['reward_rule'] != null
          ? RewardRuleModel.fromJson(json['reward_rule'] as Map<String, dynamic>)
          : null,
      options: _parseOptions(json['options']),
      isTeamBased: json['is_team_based'] ?? false,
    );
  }

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  String localizedDescription(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  /// Active options ordered by sort_order — stably, since the backend
  /// sometimes sends the same sort_order for every option (all 0), in which
  /// case the API's own ordering must be preserved (List.sort isn't stable).
  static List<ServiceOptionModel> _parseOptions(dynamic raw) {
    final parsed = (raw as List<dynamic>? ?? [])
        .map((e) => ServiceOptionModel.fromJson(e as Map<String, dynamic>))
        .where((o) => o.isActive)
        .toList();
    final indexed = parsed.asMap().entries.toList()
      ..sort((a, b) {
        final bySortOrder = a.value.sortOrder.compareTo(b.value.sortOrder);
        return bySortOrder != 0 ? bySortOrder : a.key.compareTo(b.key);
      });
    return indexed.map((e) => e.value).toList();
  }
}