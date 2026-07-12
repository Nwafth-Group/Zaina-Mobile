enum VisitTypeEnum {
  singleVisit,
  threeDaysPerWeek,
  unknown;

  static VisitTypeEnum fromApi(String value) {
    switch (value) {
      case 'single_visit':
        return VisitTypeEnum.singleVisit;
      case '3_days_per_week':
        return VisitTypeEnum.threeDaysPerWeek;
      default:
        return VisitTypeEnum.unknown;
    }
  }

  /// Value sent back to the API (e.g. when creating a booking).
  String get apiValue {
    switch (this) {
      case VisitTypeEnum.singleVisit:
        return 'single_visit';
      case VisitTypeEnum.threeDaysPerWeek:
        return '3_days_per_week';
      case VisitTypeEnum.unknown:
        return '';
    }
  }

  /// Localization key — add these to en.json / ar.json:
  /// "single_visit": "Single Visit" / "زيارة واحدة"
  /// "3_days_per_week": "3 Visits Per Week" / "3 زيارات أسبوعياً"
  String get labelKey => apiValue.isEmpty ? 'other' : apiValue;

  /// The /customer/bookings/validate endpoint expects a DIFFERENT spelling
  /// than /available-visit-types ("three_visits_per_week", not
  /// "3_days_per_week") — confirmed from the Postman collection. Use this
  /// getter specifically when calling that endpoint.
  String get validateApiValue {
    switch (this) {
      case VisitTypeEnum.singleVisit:
        return 'single_visit';
      case VisitTypeEnum.threeDaysPerWeek:
        return 'three_visits_per_week';
      case VisitTypeEnum.unknown:
        return '';
    }
  }

  /// Asset icon path per your design.
  String get iconAsset {
    switch (this) {
      case VisitTypeEnum.singleVisit:
        return 'assets/images/calendar1.png';
      case VisitTypeEnum.threeDaysPerWeek:
        return 'assets/images/calendar3.png';
      case VisitTypeEnum.unknown:
        return 'assets/images/calendar1.png';
    }
  }
}

class VisitTypeModel {
  final VisitTypeEnum type;
  final int discount;

  VisitTypeModel({required this.type, required this.discount});

  factory VisitTypeModel.fromJson(Map<String, dynamic> json) {
    return VisitTypeModel(
      type: VisitTypeEnum.fromApi(json['type'] ?? ''),
      discount: json['discount'] ?? 0,
    );
  }

  bool get hasDiscount => discount > 0;
}