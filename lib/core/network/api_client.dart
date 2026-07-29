import 'package:dio/dio.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../utils/app_navigator.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/shared_pref_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';


class ApiClient {
  late Dio _dio;
  Dio get dio => _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': lng,
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = SharedPrefHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // Print request details
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        developer.log('📤 REQUEST', name: 'API');
        developer.log('URL: ${options.baseUrl}${options.path}', name: 'API');
        developer.log('Method: ${options.method}', name: 'API');
        developer.log('Headers: ${options.headers}', name: 'API');
        if (options.queryParameters.isNotEmpty) {
          developer.log('Query Parameters: ${options.queryParameters}', name: 'API');
        }
        if (options.data != null) {
          developer.log('Body: ${_describeBody(options.data)}', name: 'API');
        }
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Print response details
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        developer.log('📥 RESPONSE', name: 'API');
        developer.log('URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}', name: 'API');
        developer.log('Status Code: ${response.statusCode}', name: 'API');
        developer.log('Response Data: ${response.data}', name: 'API');
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        return handler.next(response);
      },
      onError: (error, handler) async {
        // Print error details
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        developer.log('❌ ERROR', name: 'API');
        developer.log('URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}', name: 'API');
        developer.log('Method: ${error.requestOptions.method}', name: 'API');
        developer.log('Body: ${_describeBody(error.requestOptions.data)}', name: 'API');
        developer.log('Status Code: ${error.response?.statusCode}', name: 'API');
        developer.log('Error Type: ${error.type}', name: 'API');
        developer.log('Error Message: ${error.message}', name: 'API');
        if (error.response?.data != null) {
          developer.log('Error Response: ${error.response?.data}', name: 'API');
        }
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        final code = error.response?.statusCode;
        if (code == 401 || code == null) {
          developer.log('🚪 Logging out due to 401 Unauthorized', name: 'API');
          await SharedPrefHelper.clearAll();
          AppNavigator.pushAndRemoveUntil(const PhoneAuthScreen());
        }
        return handler.next(error);
      },
    ));
  }

  /// FormData has no useful toString() (it just prints "Instance of
  /// 'FormData'"), so build a readable representation of its fields/files
  /// for logging. Falls back to the raw value for JSON bodies (Map/List/etc).
  static String _describeBody(dynamic data) {
    if (data is FormData) {
      final fieldsStr = data.fields
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      final filesStr = data.files
          .map((e) => '${e.key}: <file:${e.value.filename}>')
          .join(', ');
      final parts = [
        if (fieldsStr.isNotEmpty) fieldsStr,
        if (filesStr.isNotEmpty) filesStr,
      ];
      return '{ ${parts.join(', ')} }';
    }
    return '$data';
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters, Map<String, dynamic>? data}) async {
    try {
      final token = SharedPrefHelper.getToken();

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.get(endpoint, queryParameters: queryParameters, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Like [get], but for endpoints that return a raw binary body — e.g.
  /// fetching an already-generated booking contract PDF by id
  /// (customer/bookings/{id}/contract). Same reasoning as [postBytes]:
  /// get()'s declared Map<String, dynamic> return type would throw a
  /// TypeError on binary data, and ResponseType.bytes avoids Dio trying to
  /// (and corrupting the file by) treating it as JSON or text.
  Future<Uint8List> getBytes(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final token = SharedPrefHelper.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.get<List<int>>(
        endpoint,
        queryParameters: queryParameters,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? []);
    } on DioException catch (e) {
      final message = _handleError(e);
      Helpers.showError(message.toString());
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final token =SharedPrefHelper.getToken();
      print("ttttt $token");
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      final message = _handleError(e);
      Helpers.showError(message.toString());
      throw _handleError(e);
    }
  }

  /// Like [post], but for endpoints that return a raw binary body — e.g.
  /// the contract-preview endpoint, which returns an actual PDF file
  /// (starts with the "%PDF-1.4" magic bytes), not the usual
  /// {status, message, data} JSON envelope. post()'s declared
  /// Map<String, dynamic> return type would throw a TypeError the moment
  /// Dio hands back binary data instead of a Map, and reading it as text
  /// (ResponseType.plain) corrupts the binary content since Dio would try
  /// to UTF-8-decode raw PDF bytes. ResponseType.bytes avoids both.
  Future<Uint8List> postBytes(String endpoint, {dynamic data}) async {
    try {
      final token = SharedPrefHelper.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.post<List<int>>(
        endpoint,
        data: data,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? []);
    } on DioException catch (e) {
      final message = _handleError(e);
      Helpers.showError(message.toString());
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, {dynamic data}) async {
    try {
      final token = SharedPrefHelper.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      developer.log('PUT Error: ${e.response}', name: 'API');
      final message = _handleError(e);
      Helpers.showError(message.toString());
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String endpoint, {dynamic data}) async {
    try {
      final token = SharedPrefHelper.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> postMultipart(
      String endpoint, {
        required FormData data,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      final token = SharedPrefHelper.getToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return await _dio.post(
        endpoint,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    String message = 'An error occurred';

    if (error.response != null) {
      message = error.response?.data['message'] ?? error.message ?? message;

      // Additional detailed error logging
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('🔍 ERROR DETAILS', name: 'API');
      developer.log('Status: ${error.response?.statusCode}', name: 'API');
      developer.log('Message: $message', name: 'API');
      developer.log('Full Response: ${error.response?.data}', name: 'API');
      if(error.response?.data['params'] != null){
        (error.response?.data['params'] as Map<String, dynamic>).forEach((key, val){
          Helpers.showError(val.toString());
        });
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
      developer.log('⏱️ Connection Timeout', name: 'API');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Receive timeout';
      developer.log('⏱️ Receive Timeout', name: 'API');
    } else {
      message = error.message ?? message;
      developer.log('❌ Generic Error: $message', name: 'API');
    }

    return message;
  }
}