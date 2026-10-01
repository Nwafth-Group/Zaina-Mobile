import 'package:zeina/features/services/data/model/review_customer_model.dart';

import '../datasources/services_datasource.dart';
import '../model/booking_selection_data.dart';
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
    // Null ONLY for options-based services (6-11) — their /validate payload
    // has no workers_count key at all (workers are team-assigned).
    int? workersCount,
    List<int>? preferredWorkerIds,
    String? couponCode,
    // Configurable-hourly services (e.g. Hospitality Worker) require these
    // too — confirmed via a 422 response complaining about both when omitted.
    int? duration,
    String? workerGender,
    // Babysitter-style services additionally require these.
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    // Pedicure & Manicure-style services additionally require this.
    // NOTE: not yet confirmed whether /validate needs it — currently only
    // confirmed on /bookings/available-dates. Wired through so it's ready
    // once confirmed; leave null until then.
    int? numberOfPersons,
    // Options-based services (6-11, e.g. Sofa Cleaning) require these.
    List<BookingOptionItem>? options,
    String? note,
  });

  /// POST /customer/bookings — creates the booking. Sends a JSON body
  /// (unlike /validate, which is form-data) per the confirmed API sample.
  ///
  /// Field set differs by service type:
  /// - Fixed-shift services (e.g. Domestic Helper, Deep Cleaning): pass
  ///   [visitType], leave [duration]/[workerGender]/[numberOfChildren]/
  ///   [childAgeGroupIds]/[numberOfPersons] null.
  /// - Configurable-hourly services (e.g. Hospitality Worker): pass
  ///   [duration]/[workerGender], leave [visitType] null — this service
  ///   type's payload has no `visit_type` field at all.
  /// - Babysitter-style services: pass [duration]/[numberOfChildren]/
  ///   [childAgeGroupIds]/[note], leave [visitType]/[workerGender] null —
  ///   confirmed the real payload has no worker_gender key at all.
  /// - Pedicure & Manicure-style services: pass [duration]/[numberOfPersons].
  ///   NOTE: not yet confirmed whether /bookings needs it — currently only
  ///   confirmed on /bookings/available-dates. Wired through so it's ready
  ///   once confirmed; leave null until then.
  /// - Options-based services (6-11, e.g. Sofa Cleaning): pass [visitType]/
  ///   [options]/[note], leave [duration]/[workerGender]/children/persons null.
  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    int? addressId,
    VisitTypeEnum? visitType,
    required List<DateTime> dates,
    required String startTime,
    int? duration,
    String? workerGender,
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    int? numberOfPersons,
    List<BookingOptionItem>? options,
    String? note,
    required List<int> workerIds,
    required String paymentMethod, // 'points' | 'wallet' | 'card'
    String? couponCode,
  });

  /// GET /customer/bookings/available-dates — used by "configurable"
  /// services (e.g. Hospitality Worker, Babysitter, Pedicure & Manicure)
  /// where the user picks start time, duration, [worker gender OR
  /// children/age-groups OR number of persons], and worker count FIRST,
  /// then checks which dates are actually available. Not used by
  /// fixed-shift services (Domestic Helper, Deep Cleaning) — see
  /// ServiceDetailModel.bookingFlow.
  /// Options-based services (6-11) also use this endpoint, but their payload
  /// is just { service_id, address_id, options, note } — no start_time/
  /// duration/workers_count — so those three are nullable and simply omitted
  /// when null.
  Future<List<DateTime>> fetchAvailableDates({
    required int serviceId,
    int? addressId,
    String? startTime,
    int? duration,
    String? workerGender,
    int? workersCount,
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    // Pedicure & Manicure (service 4) — confirmed required by that service's
    // /available-dates payload.
    int? numberOfPersons,
    // Options-based services (6-11, e.g. Sofa Cleaning).
    List<BookingOptionItem>? options,
    String? note,
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
    int? workersCount,
    List<int>? preferredWorkerIds,
    String? couponCode,
    int? duration,
    String? workerGender,
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    int? numberOfPersons,
    List<BookingOptionItem>? options,
    String? note,
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
      if (workersCount != null) 'workers_count': '$workersCount',
      if (duration != null) 'duration': '$duration',
      if (workerGender != null) 'worker_gender': workerGender,
      if (numberOfChildren != null) 'number_of_children': '$numberOfChildren',
      if (numberOfPersons != null) 'number_of_persons': '$numberOfPersons',
      if (note != null && note.isNotEmpty) 'note': note,
    };
    for (int i = 0; i < dates.length; i++) {
      fields['dates[$i]'] = fmt(dates[i]);
    }
    if (preferredWorkerIds != null) {
      for (int i = 0; i < preferredWorkerIds.length; i++) {
        fields['preferred_worker_ids[$i]'] = '${preferredWorkerIds[i]}';
      }
    }
    if (childAgeGroupIds != null) {
      for (int i = 0; i < childAgeGroupIds.length; i++) {
        fields['child_age_groups[$i]'] = '${childAgeGroupIds[i]}';
      }
    }
    if (options != null) {
      for (int i = 0; i < options.length; i++) {
        fields['options[$i][id]'] = '${options[i].id}';
        fields['options[$i][quantity]'] = '${options[i].quantity}';
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
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    int? numberOfPersons,
    List<BookingOptionItem>? options,
    String? note,
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
      if (numberOfChildren != null) 'number_of_children': numberOfChildren,
      if (childAgeGroupIds != null) 'child_age_groups': childAgeGroupIds,
      if (numberOfPersons != null) 'number_of_persons': numberOfPersons,
      if (options != null) 'options': options.map((o) => o.toJson()).toList(),
      if (note != null && note.isNotEmpty) 'note': note,
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
    String? startTime,
    int? duration,
    String? workerGender,
    int? workersCount,
    int? numberOfChildren,
    List<int>? childAgeGroupIds,
    int? numberOfPersons,
    List<BookingOptionItem>? options,
    String? note,
  }) async {
    final query = <String, dynamic>{
      'service_id': serviceId,
      if (addressId != null) 'address_id': addressId,
      if (startTime != null) 'start_time': startTime,
      if (duration != null) 'duration': duration,
      if (workerGender != null) 'worker_gender': workerGender,
      if (workersCount != null) 'workers_count': workersCount,
      if (numberOfChildren != null) 'number_of_children': numberOfChildren,
      if (childAgeGroupIds != null) 'child_age_groups': childAgeGroupIds,
      if (numberOfPersons != null) 'number_of_persons': numberOfPersons,
      // Dio serializes a List<Map> query value Laravel-style:
      // options[0][id]=1&options[0][quantity]=2&...
      if (options != null)
        'options': options.map((o) => o.toJson()).toList(),
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await _ds.getAvailableDates(query);
    final data = res['data'] as List<dynamic>? ?? [];
    return data.map((e) => DateTime.parse(e as String)).toList();
  }
}