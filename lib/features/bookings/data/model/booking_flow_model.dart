class ShiftModel {
  final int id;
  final String dropdownLabel;
  final String startTime;
  final String endTime;
  final List<AvailableBlockModel> availableBlocks;

  const ShiftModel({
    required this.id,
    required this.dropdownLabel,
    required this.startTime,
    required this.endTime,
    required this.availableBlocks,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] ?? 0,
      dropdownLabel: json['dropdown_label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',

      availableBlocks:
      (json['available_blocks'] as List<dynamic>? ?? [])
          .map(
            (e) => AvailableBlockModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class AvailableBlockModel {
  final String startTime;
  final String endTime;
  final String label;

  const AvailableBlockModel({
    required this.startTime,
    required this.endTime,
    required this.label,
  });

  factory AvailableBlockModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AvailableBlockModel(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'label': label,
    };
  }
}

class WorkerModel {
  final int id;
  final String name;
  final String? nationality;
  final double? rating;
  final String? avatar;
  final String status;

  const WorkerModel({
    required this.id,
    required this.name,
    this.nationality,
    this.rating,
    this.avatar,
    required this.status,
  });

  factory WorkerModel.fromJson(Map<String, dynamic> json) {
    return WorkerModel(
      id: json['id'],
      name: json['name'] ?? '',
      nationality: json['nationality'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      avatar: json['avatar'],
      status: json['status'] ?? 'active',
    );
  }
}

class AvailableWorkersResponse {
  final List<WorkerModel> preferredWorkers;
  final List<WorkerModel> otherWorkers;

  const AvailableWorkersResponse({
    required this.preferredWorkers,
    required this.otherWorkers,
  });

  factory AvailableWorkersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AvailableWorkersResponse(
      preferredWorkers: (data['preferred_workers'] as List<dynamic>? ?? [])
          .map((e) => WorkerModel.fromJson(e))
          .toList(),
      otherWorkers: (data['other_workers'] as List<dynamic>? ?? [])
          .map((e) => WorkerModel.fromJson(e))
          .toList(),
    );
  }
}

// ── Booking summary passed between steps ──────────────────────────────────────
class BookingFlowData {
  final int serviceId;
  final String serviceName;       // nameAr
  final String? serviceNameEn;
  final String? serviceImage;
  final String? categoryNameAr;
  final String? categoryNameEn;
  final double avgRating;
  final double pricePerHour;
  final String currency;
  final String type; // hourly | moqema | both
  final List<int> allowedDurations;

  // Step selections
  String? selectedDate;        // yyyy-MM-dd
  String? selectedStartTime;   // HH:mm
  String? selectedEndTime;     // HH:mm
  int? selectedDurationHours;
  int? selectedWorkerCount;
  List<int>? selectedWorkerIds;
  int? selectedAddressId;
  String? selectedAddressLabel;
  String? paymentMethod;       // cash | wallet | card
  String? couponCode;
  double couponDiscount;
  String? selectedShiftLabel;

  String localizedName(String lang) => lang == 'ar' ? serviceName : (serviceNameEn ?? serviceName);
  String localizedCategory(String lang) => lang == 'ar' ? (categoryNameAr ?? '') : (categoryNameEn ?? '');

  BookingFlowData({
    required this.serviceId,
    required this.serviceName,
    this.serviceNameEn,
    this.serviceImage,
    this.categoryNameAr,
    this.categoryNameEn,
    this.avgRating = 0,
    required this.pricePerHour,
    required this.currency,
    required this.type,
    this.allowedDurations = const [2, 4, 6, 8],
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedDurationHours,
    this.selectedWorkerCount = 1,
    this.selectedWorkerIds,
    this.selectedAddressId,
    this.selectedAddressLabel,
    this.paymentMethod = 'cash',
    this.couponCode,
    this.couponDiscount = 0,
    this.selectedShiftLabel,
  });

  double get subtotal =>
      pricePerHour * (selectedDurationHours ?? 1) * (selectedWorkerCount ?? 1);
  double get total => subtotal - couponDiscount;

  BookingFlowData copyWith({
    String? selectedDate,
    String? selectedStartTime,
    String? selectedEndTime,
    int? selectedDurationHours,
    int? selectedWorkerCount,
    List<int>? selectedWorkerIds,
    int? selectedAddressId,
    String? selectedAddressLabel,
    String? paymentMethod,
    String? couponCode,
    double? couponDiscount,
    String? selectedShiftLabel,
  }) {
    return BookingFlowData(
      serviceId: serviceId,
      serviceName: serviceName,
      serviceNameEn: serviceNameEn,
      serviceImage: serviceImage,
      categoryNameAr: categoryNameAr,
      categoryNameEn: categoryNameEn,
      avgRating: avgRating,
      pricePerHour: pricePerHour,
      currency: currency,
      type: type,
      allowedDurations: allowedDurations,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedStartTime: selectedStartTime ?? this.selectedStartTime,
      selectedEndTime: selectedEndTime ?? this.selectedEndTime,
      selectedDurationHours:
      selectedDurationHours ?? this.selectedDurationHours,
      selectedWorkerCount: selectedWorkerCount ?? this.selectedWorkerCount,
      selectedWorkerIds: selectedWorkerIds ?? this.selectedWorkerIds,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
      selectedAddressLabel:
      selectedAddressLabel ?? this.selectedAddressLabel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      selectedShiftLabel: selectedShiftLabel ?? this.selectedShiftLabel,
    );
  }
}