import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/network/failure.dart';
import '../../../../core/utils/shared_pref_helper.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  Future<void> sendOtp(String mobileNumber) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendOtp(mobileNumber);
      emit(OtpSentSuccess(mobileNumber));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  Future<void> verifyOtp(String mobileNumber, String otp) async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.verifyOtp(mobileNumber, otp);
      print("rrrrrrr $result");
      emit(OtpVerifySuccess(result));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Invalid code. Please try again.'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final result = await _authRepository.logout();
      await SharedPrefHelper.logout();
      emit(AuthLogoutSuccess(result));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Something went wrong. Please try again.'));
    }
  }

  void reset() => emit(AuthInitial());
}
