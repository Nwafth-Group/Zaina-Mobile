import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/booking_flow_model.dart';

// ── States ────────────────────────────────────────────────────────────────────
abstract class RescheduleShiftsState {}

class RescheduleShiftsInitial extends RescheduleShiftsState {}

class RescheduleShiftsLoading extends RescheduleShiftsState {}

class RescheduleShiftsLoaded extends RescheduleShiftsState {
  final List<ShiftModel> shifts;
  RescheduleShiftsLoaded(this.shifts);
}

class RescheduleShiftsError extends RescheduleShiftsState {
  final String message;
  RescheduleShiftsError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class RescheduleShiftsCubit extends Cubit<RescheduleShiftsState> {
  final ApiClient _api;

  RescheduleShiftsCubit(this._api) : super(RescheduleShiftsInitial());

  Future<void> fetchShifts(int bookingId, String date) async {
    emit(RescheduleShiftsLoading());
    try {
      final res = await _api.get(
        'customer/bookings/$bookingId/shifts/schedule',
        queryParameters: {'date': date},
      );
      final shifts = List<ShiftModel>.from(
        (res['data']['shifts'] as List).map((e) => ShiftModel.fromJson(e)),
      );
      emit(RescheduleShiftsLoaded(shifts));
    } on DioException catch (e) {
      emit(RescheduleShiftsError(handleDioError(e).message));
    } catch (e) {
      emit(RescheduleShiftsError(e.toString()));
    }
  }
}
