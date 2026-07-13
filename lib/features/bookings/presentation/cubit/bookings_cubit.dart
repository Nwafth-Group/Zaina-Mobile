import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../../services/data/model/service_detail_model.dart' show ServiceFeatureModel;
import '../../../services/data/repository/services_repository.dart';
import '../../data/model/booking_detail_model.dart';
import '../../data/model/booking_model.dart';

class BookingsCubit extends Cubit<BookingsState> {
  final ApiClient _api;
  BookingsCubit(this._api) : super(BookingsInitial());

  List<BookingModel> _all = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;
  BookingStatusEnum _activeFilter = BookingStatusEnum.all;

  // ── Fetch bookings list ────────────────────────────────────────────────────
  Future<void> fetchBookings({
    BookingStatusEnum filter = BookingStatusEnum.all,
    bool refresh = false,
  }) async {
    _activeFilter = filter;
    if (refresh) { _all = []; _currentPage = 1; }
    emit(BookingsLoading());
    try {
      final params = <String, dynamic>{'page': 1};
      if (filter != BookingStatusEnum.all) {
        params['status'] = filter.apiValue;
      }
      final res = await _api.get('customer/bookings', queryParameters: params);
      final data = res['data'];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? 1;
      _lastPage = meta['last_page'] ?? 1;
      _all = (data['items'] as List<dynamic>? ?? [])
          .map((e) => BookingModel.fromJson(e))
          .toList();

      emit(BookingsLoaded(
        bookings: List.from(_all),
        currentPage: _currentPage,
        lastPage: _lastPage,
        activeFilter: _activeFilter,
      ));
    } on DioException catch (e) {
      emit(BookingsError(handleDioError(e).message));
    } catch (_) {
      emit(BookingsError('Something went wrong'));
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    _loadingMore = true;
    emit(BookingsLoadingMore(List.from(_all)));
    try {
      final params = <String, dynamic>{'page': _currentPage + 1};
      if (_activeFilter != BookingStatusEnum.all) {
        params['status'] = _activeFilter.apiValue;
      }
      final res = await _api.get('customer/bookings', queryParameters: params);
      final data = res['data'];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? _currentPage;
      _lastPage = meta['last_page'] ?? _lastPage;
      _all.addAll((data['items'] as List<dynamic>? ?? [])
          .map((e) => BookingModel.fromJson(e)));
      emit(BookingsLoaded(
        bookings: List.from(_all),
        currentPage: _currentPage,
        lastPage: _lastPage,
        activeFilter: _activeFilter,
      ));
    } on DioException {
      emit(BookingsLoaded(
        bookings: List.from(_all),
        currentPage: _currentPage,
        lastPage: _lastPage,
        activeFilter: _activeFilter,
      ));
    } finally {
      _loadingMore = false;
    }
  }
}

// ── Booking Detail Cubit ──────────────────────────────────────────────────────
class BookingDetailCubit extends Cubit<BookingDetailState> {
  final ApiClient _api;
  final ServicesRepository _servicesRepo;
  BookingDetailCubit(this._api, this._servicesRepo) : super(BookingDetailInitial());

  Future<void> fetchDetail(int bookingId) async {
    emit(BookingDetailLoading());
    try {
      final res = await _api.get('customer/bookings/$bookingId');
      final booking = BookingDetailModel.fromJson(res['data']);

      // "What's Included" isn't part of the booking response — it lives on
      // the service itself, so fetch that in parallel. Best-effort: if it
      // fails, still show the booking with an empty features list rather
      // than failing the whole screen over a secondary call.
      List<ServiceFeatureModel> features = [];
      try {
        final serviceDetail = await _servicesRepo.fetchServiceDetail(booking.serviceId);
        features = serviceDetail.features;
      } catch (_) {
        features = [];
      }

      emit(BookingDetailLoaded(booking: booking, features: features));
    } on DioException catch (e) {
      emit(BookingDetailError(handleDioError(e).message));
    } catch (_) {
      emit(BookingDetailError('Something went wrong'));
    }
  }

  // ── Reschedule ─────────────────────────────────────────────────────────────
  Future<void> reschedule({
    required int bookingId,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    emit(BookingActionLoading());
    try {
      await _api.post(
        'customer/bookings/$bookingId/reschedule',
        data: {
          'new_date': newDate,
          'new_start_time': newStartTime,
          'new_end_time': newEndTime,
        },
      );
      emit(BookingRescheduleSuccess());
    } on DioException catch (e) {
      emit(BookingDetailError(handleDioError(e).message));
    } catch (_) {
      emit(BookingDetailError('Something went wrong'));
    }
  }

  // ── Report ─────────────────────────────────────────────────────────────────
  /// Intentionally does NOT emit loading/success states through the shared
  /// BookingDetailState stream (same reasoning as sendCancelOtp/confirmCancel):
  /// doing so was leaving the main booking-detail screen's BlocBuilder with
  /// a non-BookingDetailLoaded state and no way back to it, rendering blank.
  /// The report sheet drives its own local loading/error UI around this call.
  Future<void> submitReport({
    required int bookingId,
    required String reason,
    String? description,
  }) async {
    await _api.post(
      'customer/bookings/$bookingId/report',
      data: {
        'reason': reason,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
  }

  // ── Cancel (OTP-gated) ───────────────────────────────────────────────────
  /// Just performs the call — intentionally does NOT emit loading/error
  /// states, since the screen drives its own step-by-step dialog/sheet flow
  /// and shows its own transient loading + error UI around each call.
  Future<void> sendCancelOtp(int bookingId) {
    return _api.post('customer/bookings/$bookingId/cancel/send-otp');
  }

  /// Only emits on success (so the screen can react and pop back); errors
  /// propagate to the caller to display inline without disturbing the
  /// cubit's main state.
  Future<void> confirmCancel({
    required int bookingId,
    required String cancellationReason,
    required String otp,
  }) async {
    await _api.put(
      'customer/bookings/$bookingId/cancel',
      data: {
        'cancellation_reason': cancellationReason,
        'otp': otp,
      },
    );
    emit(BookingCancelSuccess());
  }

  // ── Review ─────────────────────────────────────────────────────────────────
  /// Same reasoning as submitReport/sendCancelOtp/confirmCancel: does NOT
  /// emit through the shared BookingDetailState stream, since that left the
  /// main booking-detail screen's BlocBuilder stuck on a non-Loaded state
  /// with a blank screen. The review sheet drives its own local loading/
  /// error UI around this call.
  Future<void> submitReview({
    required int bookingId,
    required int serviceRating,
    required String serviceComment,
    required List<Map<String, dynamic>> workers,
  }) async {
    await _api.post(
      'customer/bookings/$bookingId/review',
      data: {
        'service_rating': serviceRating,
        'service_comment': serviceComment,
        'workers': workers,
      },
    );
  }
}

// ── Bookings List States ───────────────────────────────────────────────────────
abstract class BookingsState {}
class BookingsInitial extends BookingsState {}
class BookingsLoading extends BookingsState {}
class BookingsLoadingMore extends BookingsState {
  final List<BookingModel> current;
  BookingsLoadingMore(this.current);
}
class BookingsLoaded extends BookingsState {
  final List<BookingModel> bookings;
  final int currentPage;
  final int lastPage;
  final BookingStatusEnum activeFilter;
  bool get hasMore => currentPage < lastPage;
  BookingsLoaded({
    required this.bookings,
    required this.currentPage,
    required this.lastPage,
    required this.activeFilter,
  });
}
class BookingsError extends BookingsState {
  final String message;
  BookingsError(this.message);
}

// ── Booking Detail States ─────────────────────────────────────────────────────
abstract class BookingDetailState {}
class BookingDetailInitial extends BookingDetailState {}
class BookingDetailLoading extends BookingDetailState {}
class BookingDetailLoaded extends BookingDetailState {
  final BookingDetailModel booking;
  final List<ServiceFeatureModel> features;
  BookingDetailLoaded({required this.booking, required this.features});
}
class BookingActionLoading extends BookingDetailState {}
class BookingRescheduleSuccess extends BookingDetailState {}
class BookingReportSuccess extends BookingDetailState {}
class BookingReviewSuccess extends BookingDetailState {}
class BookingCancelSuccess extends BookingDetailState {}
class BookingDetailError extends BookingDetailState {
  final String message;
  BookingDetailError(this.message);
}