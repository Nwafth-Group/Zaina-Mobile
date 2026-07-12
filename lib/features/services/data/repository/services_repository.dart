import 'package:zeina/features/services/data/model/review_customer_model.dart';

import '../datasources/services_datasource.dart';
import '../model/booking_validation_model.dart';
import '../model/coverage_model.dart';
import '../model/service_detail_model.dart';
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
    // Configurable-hourly services (e.g. Hospitality Worker) require these
    // too — confirmed via a 422 response complaining about both when omitted.
    int? duration,
    String? workerGender,
  });

  /// POST /customer/bookings — creates the booking. Sends a JSON body
  /// (unlike /validate, which is form-data) per the confirmed API sample.
  ///
  /// Field set differs by service type:
  /// - Fixed-shift services (e.g. Domestic Helper): pass [visitType],
  ///   leave [duration]/[workerGender] null.
  /// - Configurable-hourly services (e.g. Hospitality Worker): pass
  ///   [duration]/[workerGender], leave [visitType] null — this service
  ///   type's payload has no `visit_type` field at all.
  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    int? addressId,
    VisitTypeEnum? visitType,
    required List<DateTime> dates,
    required String startTime,
    int? duration,
    String? workerGender,
    required List<int> workerIds,
    required String paymentMethod, // 'points' | 'wallet' | 'card'
    String? couponCode,
  });

  /// GET /customer/bookings/available-dates — used by "configurable hourly"
  /// services (e.g. Hospitality Worker) where the user picks start time,
  /// duration, worker gender, and worker count FIRST, then checks which
  /// dates are actually available for that combination.
  Future<List<DateTime>> fetchAvailableDates({
    required int serviceId,
    int? addressId,
    required String startTime,
    required int duration,
    required String workerGender,
    required int workersCount,
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
    int? duration,
    String? workerGender,
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
      if (duration != null) 'duration': '$duration',
      if (workerGender != null) 'worker_gender': workerGender,
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
    VisitTypeEnum? visitType,
    required List<DateTime> dates,
    required String startTime,
    int? duration,
    String? workerGender,
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
      if (visitType != null) 'visit_type': visitType.validateApiValue,
      'dates': dates.map(fmt).toList(),
      'start_time': startTime,
      if (duration != null) 'duration': duration,
      if (workerGender != null) 'worker_gender': workerGender,
      'worker_ids': workerIds,
      'payment_method': paymentMethod,
      'coupon_code': couponCode ?? '',
    };

    final res = await _ds.createBooking(body);
    return res['data'] as Map<String, dynamic>? ?? {};
  }

  @override
  Future<List<DateTime>> fetchAvailableDates({
    required int serviceId,
    int? addressId,
    required String startTime,
    required int duration,
    required String workerGender,
    required int workersCount,
  }) async {
    final query = <String, dynamic>{
      'service_id': serviceId,
      if (addressId != null) 'address_id': addressId,
      'start_time': startTime,
      'duration': duration,
      'worker_gender': workerGender,
      'workers_count': workersCount,
    };
    final res = await _ds.getAvailableDates(query);
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => DateTime.parse(e as String)).toList();
  }
}