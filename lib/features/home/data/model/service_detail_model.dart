import 'package:zeina_app/features/home/data/model/service_model.dart';


class ServiceDuration {
  final int id;
  final List<int> allowedDurations;
  final int minDurationHours;
  final List<int>? allowedContractDurations;
  final int? minContractMonths;

  const ServiceDuration({
    required this.id,
    required this.allowedDurations,
    required this.minDurationHours,
    this.allowedContractDurations,
    this.minContractMonths,
  });

  factory ServiceDuration.fromJson(Map<String, dynamic> json) {
    return ServiceDuration(
      id: json['id'],
      allowedDurations: (json['allowed_durations'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      minDurationHours: json['min_duration_hours'] ?? 1,
      allowedContractDurations:
      (json['allowed_contract_durations'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      minContractMonths: json['min_contract_months'],
    );
  }
}

class ServiceRules {
  final int id;
  final int freeCancelCutoffHours;
  final int rescheduleCutoffHours;
  final int leadTimeMinHours;
  final int leadTimeMaxDays;
  final String lateCancelAction;
  final String lateCancelFeeType;
  final double lateCancelFeeValue;
  final String noShowPolicy;
  final int maxChangesPerBooking;

  const ServiceRules({
    required this.id,
    required this.freeCancelCutoffHours,
    required this.rescheduleCutoffHours,
    required this.leadTimeMinHours,
    required this.leadTimeMaxDays,
    required this.lateCancelAction,
    required this.lateCancelFeeType,
    required this.lateCancelFeeValue,
    required this.noShowPolicy,
    required this.maxChangesPerBooking,
  });

  factory ServiceRules.fromJson(Map<String, dynamic> json) {
    return ServiceRules(
      id: json['id'],
      freeCancelCutoffHours: json['free_cancel_cutoff_hours'] ?? 0,
      rescheduleCutoffHours: json['reschedule_cutoff_hours'] ?? 0,
      leadTimeMinHours: json['lead_time_min_hours'] ?? 0,
      leadTimeMaxDays: json['lead_time_max_days'] ?? 0,
      lateCancelAction: json['late_cancel_action'] ?? '',
      lateCancelFeeType: json['late_cancel_fee_type'] ?? '',
      lateCancelFeeValue:
      double.tryParse(json['late_cancel_fee_value']?.toString() ?? '0') ??
          0,
      noShowPolicy: json['no_show_policy'] ?? '',
      maxChangesPerBooking: json['max_changes_per_booking'] ?? 0,
    );
  }
}

class ServiceCoverage {
  final int id;
  final String cityNameAr;
  final String cityNameEn;
  final String? areaNameAr;
  final String? areaNameEn;
  final String countryNameAr;
  final String countryNameEn;

  const ServiceCoverage({
    required this.id,
    required this.cityNameAr,
    required this.cityNameEn,
    this.areaNameAr,
    this.areaNameEn,
    required this.countryNameAr,
    required this.countryNameEn,
  });

  factory ServiceCoverage.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>? ?? {};
    final area = json['area'] as Map<String, dynamic>?;
    final country = city['country'] as Map<String, dynamic>? ?? {};
    return ServiceCoverage(
      id: json['id'],
      cityNameAr: city['name_ar'] ?? '',
      cityNameEn: city['name_en'] ?? '',
      areaNameAr: area?['name_ar'],
      areaNameEn: area?['name_en'],
      countryNameAr: country['name_ar'] ?? '',
      countryNameEn: country['name_en'] ?? '',
    );
  }

  String localizedCity(String lang) =>
      lang == 'ar' ? cityNameAr : cityNameEn;
  String localizedArea(String lang) =>
      lang == 'ar' ? (areaNameAr ?? '') : (areaNameEn ?? '');
}

class ServiceSchedule {
  final String day;
  final String startTime;
  final String endTime;
  final bool isActive;

  const ServiceSchedule({
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory ServiceSchedule.fromJson(Map<String, dynamic> json) {
    return ServiceSchedule(
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isActive: (json['is_active'] == 1 || json['is_active'] == true),
    );
  }

  String get formattedStart => startTime.substring(0, 5);
  String get formattedEnd => endTime.substring(0, 5);
}

class ServiceDetailModel {
  final int id;
  final ServiceCategory category;
  final String type;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final List<ServiceFeature> features;
  final String status;
  final double avgRating;
  final ServiceDuration? duration;
  final ServiceRules? rules;
  final List<ServiceCoverage> coverages;
  final String? image;
  final ServicePrice price;
  final List<ServiceSchedule> schedules;

  const ServiceDetailModel({
    required this.id,
    required this.category,
    required this.type,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.features,
    required this.status,
    required this.avgRating,
    this.duration,
    this.rules,
    required this.coverages,
    this.image,
    required this.price,
    required this.schedules,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    print("dddddd $data");
    return ServiceDetailModel(
      id: data['id'],
      category: ServiceCategory.fromJson(data['category']),
      type: data['type'] ?? 'hourly',
      nameAr: data['name_ar'] ?? '',
      nameEn: data['name_en'] ?? '',
      descriptionAr: data['description_ar'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      features: (data['features'] as List<dynamic>? ?? [])
          .map((f) => ServiceFeature.fromJson(f))
          .toList(),
      status: data['status'] ?? 'active',
      avgRating:
      double.tryParse(data['avg_rating']?.toString() ?? '0') ?? 0,
      duration: data['duration'] != null
          ? ServiceDuration.fromJson(data['duration'])
          : null,
      rules: data['rules'] != null
          ? ServiceRules.fromJson(data['rules'])
          : null,
      coverages: (data['coverages'] as List<dynamic>? ?? [])
          .map((c) => ServiceCoverage.fromJson(c))
          .toList(),
      image: data['image'],
      price: ServicePrice.fromJson(data['price_details']),
      schedules: (data['schedules'] as List<dynamic>? ?? [])
          .map((s) => ServiceSchedule.fromJson(s))
          .toList(),
    );
  }

  String localizedName(String lang) => lang == 'ar' ? nameAr : nameEn;
  String localizedDescription(String lang) =>
      lang == 'ar' ? descriptionAr : descriptionEn;
  String localizedCategory(String lang) =>
      lang == 'ar' ? category.nameAr : category.nameEn;
}