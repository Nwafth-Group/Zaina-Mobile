part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String mobileNumber;
  OtpSentSuccess(this.mobileNumber);
}

// In auth_state.dart — update OtpVerifySuccess:
class OtpVerifySuccess extends AuthState {
  final Map<String, dynamic> data;
  final bool isNewUser;
  final bool needsVerification;
  final String? token;

  OtpVerifySuccess(this.data)
      : isNewUser = data['is_new_user'] == true,
        needsVerification = data['user']?['verification_status'] == 'unverified',
        token = data['token'];
}

class AuthLogoutSuccess extends AuthState {
  final Map<String, dynamic> data;
  AuthLogoutSuccess(this.data);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
