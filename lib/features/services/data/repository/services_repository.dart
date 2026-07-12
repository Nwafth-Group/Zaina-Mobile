import 'package:zeina/features/services/data/model/review_customer_model.dart';
import 'package:zeina/features/services/data/model/service_feature_model.dart';

import '../datasources/services_datasource.dart';
import '../model/booking_validation_model.dart';
import '../model/coverage_model.dart';
import '../model/service_model.dart';
import '../model/visit_type_model.dart';

abstract class ServicesRepository {
  Future<List<ServiceModel>> fetchServices({
    required String type,
    int page = 1,
  });

  Future<List<VisitTypeModel>> fetchAvailableVisitTypes(int serviceId);

  Future<CoverageModel> checkCoverage(int serviceId);

  Future<ServiceDetailModel> fetchServiceDetail(int serviceId);

  Future<List<ReviewModel>> fetchReviews(int serviceId);

  Future<BookingValidationModel> validateBooking({
    required int serviceId,
    required VisitTypeEnum visitType,
    int? addressId,
    required List<DateTime> dates,
    required String startTime,
    required int workersCount,
    List<int>? preferredWorkerIds,
    String? couponCode,
  });

  /// POST /customer/bookings — creates the booking. Sends a JSON body
  /// (unlike /validate, which is form-data) per the confirmed API sample.
  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    int? addressId,
    required VisitTypeEnum visitType,
    required List<DateTime> dates,
    required String startTime,
    required List<int> workerIds,
    required String paymentMethod, // 'points' | 'wallet' | 'card'
    String? couponCode,
  });
}

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesRemoteDataSource _ds;
  ServicesRepositoryImpl(this._ds);

  @override
  Future<List<ServiceModel>> fetchServices({
    required String type,
    int page = 1,
  }) async {
    final res = await _ds.getServices(type: type, page: page);
    final data = res['data'];
    final items = (data?['items'] as List<dynamic>? ?? []);
    return items
        .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<VisitTypeModel>> fetchAvailableVisitTypes(int serviceId) async {
    final res = await _ds.getAvailableVisitTypes(serviceId);
    final data = (res['data'] as List<dynamic>? ?? []);
    return data
        .map((e) => VisitTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CoverageModel> checkCoverage(int serviceId) async {
    final res = await _ds.getCheckCoverage(serviceId);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return CoverageModel.fromJson(data);
  }

  @override
  Future<ServiceDetailModel> fetchServiceDetail(int serviceId) async {
    final res = await _ds.getServiceDetail(serviceId);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return ServiceDetailModel.fromJson(data);
  }

  @override
  Future<List<ReviewModel>> fetchReviews(int serviceId) async {
    final res = await _ds.getReviews(serviceId);
    final items = (res['data']?['items'] as List<dynamic>? ?? []);
    return items
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BookingValidationModel> validateBooking({
    required int serviceId,
    required VisitTypeEnum visitType,
    int? addressId,
    required List<DateTime> dates,
    required String startTime,
    required int workersCount,
    List<int>? preferredWorkerIds,
    String? couponCode,
  }) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final fields = <String, dynamic>{
      'service_id': '$serviceId',
      // NOTE: /bookings/validate uses "three_visits_per_week", not the
      // "3_days_per_week" spelling used by /available-visit-types.
      'visit_type': visitType.validateApiValue,
      if (addressId != null) 'address_id': '$addressId',
      'start_time': startTime,
      'workers_count': '$workersCount',
    };
    for (int i = 0; i < dates.length; i++) {
      fields['dates[$i]'] = fmt(dates[i]);
    }
    if (preferredWorkerIds != null) {
      for (int i = 0; i < preferredWorkerIds.length; i++) {
        fields['preferred_worker_ids[$i]'] = '${preferredWorkerIds[i]}';
      }
    }
    if (couponCode != null && couponCode.isNotEmpty) {
      fields['coupon_code'] = couponCode;
    }

    final res = await _ds.validateBooking(fields);
    final data = res['data'] as Map<String, dynamic>? ?? {};
    return BookingValidationModel.fromJson(data);
  }

  @override
  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    int? addressId,
    required VisitTypeEnum visitType,
    required List<DateTime> dates,
    required String startTime,
    required List<int> workerIds,
    required String paymentMethod,
    String? couponCode,
  }) async {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final body = <String, dynamic>{
      'service_id': serviceId,
      if (addressId != null) 'address_id': addressId,
      // NOTE: same "three_visits_per_week" spelling as /validate.
      'visit_type': visitType.validateApiValue,
      'dates': dates.map(fmt).toList(),
      'start_time': startTime,
      'worker_ids': workerIds,
      'payment_method': paymentMethod,
      'coupon_code': couponCode ?? '',
    };

    final res = await _ds.createBooking(body);
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}