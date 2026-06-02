import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/booking_flow_model.dart';

class BookingFlowState {
  final BookingFlowData? flow;
  final bool shiftsLoading;
  final bool workersLoading;
  final bool submitting;
  final List<ShiftModel> shifts;
  final AvailableWorkersResponse? workers;
  final String? bookingRef;
  final String? error;

  const BookingFlowState({
    this.flow,
    this.shiftsLoading = false,
    this.workersLoading = false,
    this.submitting = false,
    this.shifts = const [],
    this.workers,
    this.bookingRef,
    this.error,
  });

  BookingFlowState copyWith({
    BookingFlowData? flow,
    bool? shiftsLoading,
    bool? workersLoading,
    bool? submitting,
    List<ShiftModel>? shifts,
    AvailableWorkersResponse? workers,
    String? bookingRef,
    String? error,
  }) {
    return BookingFlowState(
      flow: flow ?? this.flow,
      shiftsLoading: shiftsLoading ?? this.shiftsLoading,
      workersLoading: workersLoading ?? this.workersLoading,
      submitting: submitting ?? this.submitting,
      shifts: shifts ?? this.shifts,
      workers: workers ?? this.workers,
      bookingRef: bookingRef ?? this.bookingRef,
      error: error,
    );
  }
}

class BookingFlowCubit extends Cubit<BookingFlowState> {
  final ApiClient _api;
  late BookingFlowData _flow;

  BookingFlowCubit(this._api) : super(const BookingFlowState());

  BookingFlowData get flow => _flow;

  void init(BookingFlowData data) {
    _flow = data;
    emit(state.copyWith(flow: data));
  }

  void updateFlow(BookingFlowData updated) {
    _flow = updated;
    emit(state.copyWith(flow: updated));
  }

  Future<void> fetchShifts(String date) async {
    emit(state.copyWith(shiftsLoading: true, error: null));
    try {
      print("654654555");
      final res = await _api.get(
        'customer/services/${_flow.serviceId}/shifts',
        queryParameters: {'date': date},
      );
      final shifts = List<ShiftModel>.from(
        (res['data']['shifts'] as List).map((e) => ShiftModel.fromJson(e)),
      );
      emit(state.copyWith(shiftsLoading: false, shifts: shifts));
    } on DioException catch (e) {
      print("333333 $e");
      emit(state.copyWith(
          shiftsLoading: false, error: handleDioError(e).message));
    } catch (e) {
      print("333333 $e");

      emit(state.copyWith(shiftsLoading: false, error: e.toString()));
    }
  }

  Future<void> fetchWorkers({
    required String date,
    required String startTime,
    required int durationHours,
  }) async {
    emit(state.copyWith(workersLoading: true, error: null));
    try {
      final res = await _api.get(
        'customer/services/${flow.serviceId}/available-workers',
        queryParameters: {
          'date': date,
          'start_time': startTime,
          'periods_count': 1,
        },
      );
      final workers = AvailableWorkersResponse.fromJson(res);
      emit(state.copyWith(workersLoading: false, workers: workers));
    } on DioException catch (e) {
      emit(state.copyWith(
          workersLoading: false, error: handleDioError(e).message));
    } catch (e) {
      emit(state.copyWith(workersLoading: false, error: e.toString()));
    }
  }

  // ── POST customer/bookings ─────────────────────────────────────────────────
  Future<void> submitBooking() async {
    final flow = state.flow;

    if (flow == null ||
        flow.selectedWorkerIds == null ||
        flow.selectedWorkerIds!.isEmpty ||
        flow.selectedAddressId == null ||
        flow.selectedDate == null ||
        flow.selectedStartTime == null ||
        flow.selectedEndTime == null) {
      emit(state.copyWith(error: 'Please complete all required fields'));
      return;
    }

    emit(state.copyWith(submitting: true, error: null));

    try {
      final res = await _api.post(
        'customer/bookings',
        data: {
          'service_id': flow.serviceId.toString(),
          'worker_ids': flow.selectedWorkerIds,
          'address_id': flow.selectedAddressId.toString(),
          'date': flow.selectedDate,
          'start_time': flow.selectedStartTime,
          'periods_count': 1,
        },
      );

      final ref = res['data']?['booking_ref']?.toString() ?? '';

      emit(state.copyWith(submitting: false, bookingRef: ref));
    } on DioException catch (e) {
      emit(state.copyWith(
        submitting: false,
        error: handleDioError(e).message,
      ));
    } catch (e) {
      emit(state.copyWith(
        submitting: false,
        error: 'Booking failed',
      ));
    }
  }
}