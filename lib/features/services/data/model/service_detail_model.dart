
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

  /// True for services where the user configures start time/duration/gender/
  /// worker count THEN checks availability (Hospitality Worker-style), as
  /// opposed to picking from fixed pre-set shifts (Domestic Helper-style).
  bool get isConfigurableHourly => workerGenderOptions.isNotEmpty;

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
    );
  }

  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;

  String localizedDescription(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;
}