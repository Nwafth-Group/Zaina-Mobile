import '../../../../core/network/failure.dart';
import '../datasources/auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> sendOtp(String mobileNumber);
  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp);
  Future<Map<String, dynamic>> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    try {
      return await _remoteDataSource.sendOtp(mobileNumber);
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
    String mobileNumber,
    String otp,
  ) async {
    try {
      return await _remoteDataSource.verifyOtp(mobileNumber, otp);
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> logout() async {
    try {
      return await _remoteDataSource.logout();
    } on Failure {
      rethrow;
    }
  }
}
