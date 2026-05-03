class ShiftModel {
  final int id;
  final String dropdownLabel;
  final String startTime;
  final String endTime;
  final List<String> availableHours;

  const ShiftModel({
    required this.id,
    required this.dropdownLabel,
    required this.startTime,
    required this.endTime,
    required this.availableHours,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'],
      dropdownLabel: json['dropdown_label'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      availableHours: (json['available_hours'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
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
  final String serviceName;
  final String? serviceImage;
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
  int? selectedWorkerId;
  int? selectedAddressId;
  String? selectedAddressLabel;
  String? paymentMethod;       // cash | wallet | card
  String? couponCode;
  double couponDiscount;
  String? selectedShiftLabel;

  BookingFlowData({
    required this.serviceId,
    required this.serviceName,
    this.serviceImage,
    required this.pricePerHour,
    required this.currency,
    required this.type,
    this.allowedDurations = const [2, 4, 6, 8],
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedDurationHours,
    this.selectedWorkerCount = 1,
    this.selectedWorkerId,
    this.selectedAddressId,
    this.selectedAddressLabel,
    this.paymentMethod = 'cash',
    this.couponCode,
    this.couponDiscount = 0,
    this.selectedShiftLabel,
  });

  double get subtotal =>
      pricePerHour * (selectedDurationHours ?? 1) * (selectedWorkerCount ?? 1);
  double get vat => subtotal * 0.1;
  double get total => subtotal + vat - couponDiscount;

  BookingFlowData copyWith({
    String? selectedDate,
    String? selectedStartTime,
    String? selectedEndTime,
    int? selectedDurationHours,
    int? selectedWorkerCount,
    int? selectedWorkerId,
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
      serviceImage: serviceImage,
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
      selectedWorkerId: selectedWorkerId ?? this.selectedWorkerId,
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