part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String mobileNumber;
  OtpSentSuccess(this.mobileNumber);
}

class OtpVerifySuccess extends AuthState {
  final Map<String, dynamic> data;
  OtpVerifySuccess(this.data);
}

class AuthLogoutSuccess extends AuthState {
  final Map<String, dynamic> data;
  AuthLogoutSuccess(this.data);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
