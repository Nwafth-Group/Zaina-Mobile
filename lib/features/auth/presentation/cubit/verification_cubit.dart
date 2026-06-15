import '../../data/models/verification_model.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';

// ── Verification Cubit ────────────────────────────────────────────────────────
class VerificationCubit extends Cubit<VerificationState> {
  final ApiClient _api;
  VerificationCubit(this._api) : super(VerificationInitial());

  /// POST customer/auth/verify
  /// Files: [frontId, backId, selfie]
  Future<void> submitVerification({
    required File frontId,
    required File backId,
    required File selfie,
  }) async {
    emit(VerificationLoading());
    try {
      final formData = FormData.fromMap({
        'id_front': await MultipartFile.fromFile(
          frontId.path,
          filename: 'id_front.jpg',
        ),

        'id_back': await MultipartFile.fromFile(
          backId.path,
          filename: 'id_back.jpg',
        ),

        'selfie': await MultipartFile.fromFile(
          selfie.path,
          filename: 'selfie.jpg',
        ),
      });

      await _api.dio.post(
        'customer/auth/verify',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      emit(VerificationSuccess());
    } on DioException catch (e) {
      emit(VerificationError(handleDioError(e).message));
    } catch (_) {
      emit(VerificationError('Submission failed. Please try again.'));
    }
  }
}

// ── Profile Cubit ─────────────────────────────────────────────────────────────
class ProfileCubit extends Cubit<ProfileState> {
  final ApiClient _api;
  ProfileCubit(this._api) : super(ProfileInitial());

  UserProfile? _profile;
  UserProfile? get profile => _profile;

  Future<UserProfile?> fetchProfile() async {
    emit(ProfileLoading());
    try {
      final res = await _api.get('customer/profile/');
      _profile = UserProfile.fromJson(res['data']);
      emit(ProfileLoaded(_profile!));
      return profile;
    } on DioException catch (e) {
      emit(ProfileError(handleDioError(e).message));
      return profile;
    } catch (_) {
      emit(ProfileError('Failed to load profile'));
      return profile;
    }
  }

  // Add to ProfileCubit class:

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String gender,
    String? idNumber,
    File? image,
  }) async {
    emit(ProfileLoading());
    try {
      final fields = <String, dynamic>{
        'first_name':   firstName,
        'last_name':    lastName,
        'phone_number': phoneNumber,
        'email':        email,
        'gender':       gender,
        if (idNumber != null && idNumber.isNotEmpty) 'id_number': idNumber,
      };

      FormData formData;
      if (image != null) {
        formData = FormData.fromMap({
          ...fields,
          'files': await MultipartFile.fromFile(image.path, filename: 'profile.jpg'),
        });
      } else {
        formData = FormData.fromMap(fields);
      }

      final res = await _api.dio.put(
        'customer/profile/complete',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      _profile = UserProfile.fromJson(res.data['data']);
      emit(ProfileLoaded(_profile!));
      return true;
    } on DioException catch (e) {
      emit(ProfileError(handleDioError(e).message));
      // Restore previous profile
      if (_profile != null) emit(ProfileLoaded(_profile!));
      return false;
    } catch (_) {
      if (_profile != null) emit(ProfileLoaded(_profile!));
      return false;
    }
  }
}

abstract class VerificationState {}

class VerificationInitial  extends VerificationState {}
class VerificationLoading  extends VerificationState {}
class VerificationSuccess  extends VerificationState {}
class VerificationError    extends VerificationState {
  final String message;
  VerificationError(this.message);
}

// profile
abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded  extends ProfileState {
  final UserProfile profile;
  ProfileLoaded(this.profile);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}