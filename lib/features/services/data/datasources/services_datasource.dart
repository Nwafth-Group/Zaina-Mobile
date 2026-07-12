import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../model/booking_validation_exception.dart';

abstract class ServicesRemoteDataSource {
  Future<Map<String, dynamic>> getServices({
    required String type,
    int page = 1,
  });

  Future<Map<String, dynamic>> getAvailableVisitTypes(int serviceId);

  Future<Map<String, dynamic>> getCheckCoverage(int serviceId);

  Future<Map<String, dynamic>> getServiceDetail(int serviceId);

  Future<Map<String, dynamic>> getReviews(int serviceId, {int page = 1});

  Future<Map<String, dynamic>> validateBooking(Map<String, dynamic> fields);

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body);

  Future<Map<String, dynamic>> getAvailableDates(Map<String, dynamic> query);
}

class ServicesRemoteDataSourceImpl implements ServicesRemoteDataSource {
  final ApiClient _api;
  ServicesRemoteDataSourceImpl(this._api);

  @override
  Future<Map<String, dynamic>> getServices({
    required String type,
    int page = 1,
  }) {
    return _api.get(
      'customer/services',
      queryParameters: {'page': page, 'type': type},
    );
  }

  @override
  Future<Map<String, dynamic>> getAvailableVisitTypes(int serviceId) {
    return _api.get('customer/services/$serviceId/available-visit-types');
  }

  @override
  Future<Map<String, dynamic>> getCheckCoverage(int serviceId) {
    return _api.get('customer/services/$serviceId/check-coverage');
  }

  @override
  Future<Map<String, dynamic>> getServiceDetail(int serviceId) {
    return _api.get('customer/services/$serviceId');
  }

  @override
  Future<Map<String, dynamic>> getReviews(int serviceId, {int page = 1}) {
    return _api.get('customer/reviews/$serviceId', queryParameters: {'page': page});
  }

  @override
  Future<Map<String, dynamic>> validateBooking(Map<String, dynamic> fields) async {
    // Bypassing ApiClient.post() deliberately here: it swallows the
    // response's `params` (field-level validation reasons) and only
    // re-throws the generic top-level `message`. We need the specific
    // reason (e.g. "all selected dates must belong to the same calendar
    // week") to show a useful error dialog, so we call the underlying Dio
    // client directly and parse the 422 response ourselves.
    try {
      final response = await _api.dio.post(
        'customer/bookings/validate',
        data: FormData.fromMap(fields),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString() ?? 'Validation failed';
        final paramsRaw = data['params'];
        final params = <String, String>{};
        if (paramsRaw is Map) {
          paramsRaw.forEach((key, value) {
            params['$key'] = value.toString();
          });
        }
        throw BookingValidationException(message: message, params: params);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body) async {
    // JSON body here (not form-data) — confirmed from the /customer/bookings
    // sample payload, unlike /validate which uses form-data.
    try {
      final response = await _api.dio.post('customer/bookings', data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString() ?? 'Booking failed';
        final paramsRaw = data['params'];
        final params = <String, String>{};
        if (paramsRaw is Map) {
          paramsRaw.forEach((key, value) {
            params['$key'] = value.toString();
          });
        }
        throw BookingValidationException(message: message, params: params);
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAvailableDates(Map<String, dynamic> query) async {
    // Bypassing ApiClient.get() deliberately here too — it only re-throws a
    // generic string, not something our BookingValidationException catch
    // blocks recognize, so the real server message (e.g. "Selected hours
    // must be within the service window...") was getting swallowed in favor
    // of a generic fallback.
    try {
      final response = await _api.dio.get(
        'customer/bookings/available-dates',
        queryParameters: query,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString() ?? 'Failed to fetch available dates';
        final paramsRaw = data['params'];
        final params = <String, String>{};
        if (paramsRaw is Map) {
          paramsRaw.forEach((key, value) {
            params['$key'] = value.toString();
          });
        }
        throw BookingValidationException(message: message, params: params);
      }
      rethrow;
    }
  }
}