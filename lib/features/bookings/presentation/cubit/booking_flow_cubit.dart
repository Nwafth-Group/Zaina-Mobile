import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/booking_flow_model.dart';
abstract class BookingFlowState {}

class BookingFlowInitial extends BookingFlowState {}

class BookingFlowReady extends BookingFlowState {
  final BookingFlowData flow;
  BookingFlowReady(this.flow);
}

class BookingFlowShiftsLoading extends BookingFlowState {}

class BookingFlowShiftsLoaded extends BookingFlowState {
  final List<ShiftModel> shifts;
  BookingFlowShiftsLoaded(this.shifts);
}

class BookingFlowWorkersLoading extends BookingFlowState {}

class BookingFlowWorkersLoaded extends BookingFlowState {
  final AvailableWorkersResponse response;
  BookingFlowWorkersLoaded(this.response);
}

class BookingFlowSubmitting extends BookingFlowState {}

class BookingFlowSuccess extends BookingFlowState {
  final String bookingRef;
  BookingFlowSuccess(this.bookingRef);
}

class BookingFlowError extends BookingFlowState {
  final String message;
  BookingFlowError(this.message);
}


class BookingFlowCubit extends Cubit<BookingFlowState> {
  final ApiClient _api;
  late BookingFlowData _flow;

  BookingFlowCubit(this._api) : super(BookingFlowInitial());

  BookingFlowData get flow => _flow;

  void init(BookingFlowData data) {
    _flow = data;
    emit(BookingFlowReady(_flow));
  }

  void updateFlow(BookingFlowData updated) {
    _flow = updated;
    emit(BookingFlowReady(_flow));
  }

  // ── Fetch shifts for a date ────────────────────────────────────────────────
  Future<void> fetchShifts(String date) async {
    emit(BookingFlowShiftsLoading());
    try {
      final res = await _api.get(
        'customer/services/${_flow.serviceId}/shifts',
        queryParameters: {'date': date},
      );
      final shifts = List<ShiftModel>.from(
        res['data']['shifts'].map(
              (e) => ShiftModel.fromJson(e),
        ),
      );
      emit(BookingFlowShiftsLoaded(shifts));
    } on DioException catch (e) {
      emit(BookingFlowError(handleDioError(e).message));
    } catch (_) {
      emit(BookingFlowError('Failed to load shifts'));
    }
  }

  // ── Fetch available workers ────────────────────────────────────────────────
  Future<void> fetchWorkers({
    required String date,
    required String startTime,
    required int durationHours,
  }) async {
    emit(BookingFlowWorkersLoading());
    try {
      final res = await _api.get(
        'customer/services/${_flow.serviceId}/available-workers',
        queryParameters: {
          'date': date,
          'start_time': startTime,
          'duration': durationHours * 60,
        },
      );
      print("objecttt $res");
      final response = AvailableWorkersResponse.fromJson(res);
      emit(BookingFlowWorkersLoaded(response));
    } on DioException catch (e) {
      emit(BookingFlowError(handleDioError(e).message));
    } catch (_) {
      emit(BookingFlowError('Failed to load workers'));
    }
  }

  // ── Submit booking ─────────────────────────────────────────────────────────
  Future<void> submitBooking() async {
    if (_flow.selectedWorkerId == null ||
        _flow.selectedAddressId == null ||
        _flow.selectedDate == null ||
        _flow.selectedStartTime == null ||
        _flow.selectedEndTime == null) {
      emit(BookingFlowError('Please complete all required fields'));
      return;
    }
    emit(BookingFlowSubmitting());
    try {
      final res = await _api.post(
        'customer/bookings',
        data: {
          'service_id': _flow.serviceId.toString(),
          'worker_id': _flow.selectedWorkerId.toString(),
          'address_id': _flow.selectedAddressId.toString(),
          'date': _flow.selectedDate,
          'start_time': _flow.selectedStartTime,
          'end_time': _flow.selectedEndTime,
        },
      );
      emit(BookingFlowSuccess(
          res['data']?['booking_ref']?.toString() ?? ''));
    } on DioException catch (e) {
      emit(BookingFlowError(handleDioError(e).message));
    } catch (_) {
      emit(BookingFlowError('Booking failed. Please try again.'));
    }
  }
}