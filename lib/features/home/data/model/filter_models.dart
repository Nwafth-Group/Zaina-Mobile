class LocationItem {
  final int id;
  final String nameAr;
  final String nameEn;

  const LocationItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      id: json['id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? '',
    );
  }

  String localized(String lang) => lang == 'ar' ? nameAr : nameEn;
}

class TimeSlotOption {
  final String label;      // Display label e.g. "09:00 AM - 12:00 PM"
  final String startTime;  // 24h format e.g. "09:00"
  final String endTime;    // 24h format e.g. "12:00"

  const TimeSlotOption({
    required this.label,
    required this.startTime,
    required this.endTime,
  });
}

class FilterParams {
  final List<int> categoryIds;
  final int? cityId;
  final int? areaId;
  final double minPrice;
  final double maxPrice;
  final double? minRating;
  final String? date;       // yyyy-MM-dd (stored internally, sent as dd-MM-yyyy)
  final String? startTime;  // 24h format e.g. "09:00"
  final String? endTime;    // 24h format e.g. "12:00"

  const FilterParams({
    this.categoryIds = const [],
    this.cityId,
    this.areaId,
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.minRating,
    this.date,
    this.startTime,
    this.endTime,
  });

  FilterParams copyWith({
    List<int>? categoryIds,
    int? cityId,
    int? areaId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? date,
    String? startTime,
    String? endTime,
    bool clearCity = false,
    bool clearArea = false,
    bool clearRating = false,
    bool clearDate = false,
    bool clearTime = false,
  }) {
    return FilterParams(
      categoryIds: categoryIds ?? this.categoryIds,
      cityId:      clearCity   ? null : (cityId     ?? this.cityId),
      areaId:      clearArea   ? null : (areaId     ?? this.areaId),
      minPrice:    minPrice    ?? this.minPrice,
      maxPrice:    maxPrice    ?? this.maxPrice,
      minRating:   clearRating ? null : (minRating  ?? this.minRating),
      date:        clearDate   ? null : (date        ?? this.date),
      startTime:   clearTime   ? null : (startTime  ?? this.startTime),
      endTime:     clearTime   ? null : (endTime     ?? this.endTime),
    );
  }

  bool get isEmpty =>
      categoryIds.isEmpty &&
          cityId == null &&
          areaId == null &&
          minPrice == 0 &&
          maxPrice == 1000 &&
          minRating == null &&
          date == null;

  /// Build query params for GET customer/filter
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    for (int i = 0; i < categoryIds.length; i++) {
      params['categories[$i]'] = categoryIds[i];
    }
    if (cityId    != null) params['city_id']    = cityId;
    if (areaId    != null) params['area_id']    = areaId;
    if (minRating != null) params['min_rating'] = minRating;
    if (minPrice > 0)      params['min_price']  = minPrice.toInt();
    if (maxPrice < 1000)   params['max_price']  = maxPrice.toInt();
    if (date != null) {
      // API expects dd-MM-yyyy format
      final parts = date!.split('-');
      params['date'] = '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    if (startTime != null) params['start_time'] = startTime;
    if (endTime   != null) params['end_time']   = endTime;
    return params;
  }
}