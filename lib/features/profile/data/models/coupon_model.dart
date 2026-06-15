class EligibleService {
  final int id;
  final String name;
  const EligibleService({required this.id, required this.name});
  factory EligibleService.fromJson(Map<String, dynamic> j) =>
      EligibleService(id: j['id'], name: j['name'] ?? '');
}

class CouponModel {
  final int id;
  final String code;
  final String type; // fixed | percentage
  final double value;
  final double? maxDiscount;
  final double? minBookingAmount;
  final bool isForAllServices;
  final List<EligibleService> eligibleServices;
  final String startDate;
  final String endDate;
  final bool isExpired;

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.maxDiscount,
    this.minBookingAmount,
    required this.isForAllServices,
    required this.eligibleServices,
    required this.startDate,
    required this.endDate,
    required this.isExpired,
  });

  factory CouponModel.fromJson(Map<String, dynamic> j) => CouponModel(
    id: j['id'],
    code: j['code'] ?? '',
    type: j['type'] ?? 'fixed',
    value: (j['value'] as num?)?.toDouble() ?? 0,
    maxDiscount: (j['max_discount'] as num?)?.toDouble(),
    minBookingAmount: (j['min_booking_amount'] as num?)?.toDouble(),
    isForAllServices: j['is_for_all_services'] == true,
    eligibleServices: (j['eligible_services'] as List<dynamic>? ?? [])
        .map((e) => EligibleService.fromJson(e))
        .toList(),
    startDate: j['start_date'] ?? '',
    endDate: j['end_date'] ?? '',
    isExpired: j['is_expired'] == true,
  );

  String get displayValue =>
      type == 'fixed' ? '${value.toInt()} EGP OFF' : '${value.toInt()}% OFF';

  String get validUntil {
    try {
      final d = DateTime.parse(endDate);
      return 'Aug ${d.day}, ${d.year}';
    } catch (_) {
      return endDate;
    }
  }

  String get expiresIn {
    try {
      final d = DateTime.parse(endDate);
      final diff = d.difference(DateTime.now()).inDays;
      if (diff <= 0) return 'Expired';
      if (diff == 1) return 'Expires in 1 day';
      return 'Expires in $diff days';
    } catch (_) {
      return '';
    }
  }

  String get applicableFor => isForAllServices
      ? 'All Services'
      : eligibleServices.map((s) => s.name).join(', ');
}