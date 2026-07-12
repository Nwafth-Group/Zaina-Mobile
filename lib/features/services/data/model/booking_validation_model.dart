
class BookingPricingModel {
  final double pricePerPeriod;
  final int workersCount;
  final int visitsCount;
  final double subtotal;
  final double serviceDiscountAmount;
  final double couponDiscountAmount;
  final double discount;
  final double tax;
  final double total;
  final String currency;

  BookingPricingModel({
    required this.pricePerPeriod,
    required this.workersCount,
    required this.visitsCount,
    required this.subtotal,
    required this.serviceDiscountAmount,
    required this.couponDiscountAmount,
    required this.discount,
    required this.tax,
    required this.total,
    required this.currency,
  });

  factory BookingPricingModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
    return BookingPricingModel(
      pricePerPeriod: d(json['price_per_period']),
      workersCount: json['workers_count'] ?? 0,
      visitsCount: json['visits_count'] ?? 0,
      subtotal: d(json['subtotal']),
      serviceDiscountAmount: d(json['service_discount_amount']),
      couponDiscountAmount: d(json['coupon_discount_amount']),
      discount: d(json['discount']),
      tax: d(json['tax']),
      total: d(json['total']),
      currency: json['currency'] ?? '',
    );
  }
}

/// Result of a successful /customer/bookings/validate call.
/// Keep this alongside the user's [BookingSelectionData] and pass both into
/// the checkout screen.
class BookingValidationModel {
  final List<int> workerIds;
  final BookingPricingModel pricing;

  BookingValidationModel({required this.workerIds, required this.pricing});

  factory BookingValidationModel.fromJson(Map<String, dynamic> json) {
    return BookingValidationModel(
      workerIds: (json['worker_ids'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      pricing: BookingPricingModel.fromJson(
          json['pricing'] as Map<String, dynamic>? ?? {}),
    );
  }
}