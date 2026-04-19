import 'package:dio/dio.dart';
import 'package:zeina_app/core/utils/shared_pref_helper.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/utils/constants.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> sendOtp(String mobileNumber);
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      final response = await _apiClient.post(
        AppConstants.sendOtp,
        data: {'mobile_number': mobileNumber},
      );
      return response;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await _apiClient.post(
        AppConstants.verifyOtp,
        data: {'mobile_number': mobileNumber, 'otp': otp},
      );
      SharedPrefHelper.saveToken(response['data']['token']);
      return response;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}
