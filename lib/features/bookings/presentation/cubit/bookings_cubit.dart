import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
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
  BookingDetailCubit(this._api) : super(BookingDetailInitial());

  Future<void> fetchDetail(int bookingId) async {
    emit(BookingDetailLoading());
    try {
      final res = await _api.get('customer/bookings/$bookingId');
      final model = BookingModel.fromJson(res['data']);
      emit(BookingDetailLoaded(model));
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
  Future<void> submitReport({
    required int bookingId,
    required String reason,
    String? description,
  }) async {
    emit(BookingActionLoading());
    try {
      await _api.post(
        'customer/bookings/$bookingId/report',
        data: {
          'reason': reason,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      emit(BookingReportSuccess());
    } on DioException catch (e) {
      emit(BookingDetailError(handleDioError(e).message));
    } catch (_) {
      emit(BookingDetailError('Something went wrong'));
    }
  }

  // ── Cancel ─────────────────────────────────────────────────────────────────
  Future<void> cancelBooking(int bookingId) async {
    emit(BookingActionLoading());
    try {
      await _api.put('customer/bookings/$bookingId/cancel');
      emit(BookingCancelSuccess());
    } on DioException catch (e) {
      emit(BookingDetailError(handleDioError(e).message));
    } catch (_) {
      emit(BookingDetailError('Something went wrong'));
    }
  }

  // ── Review ─────────────────────────────────────────────────────────────────
  Future<void> submitReview({
    required int bookingId,
    required int serviceRating,
    required String serviceComment,
    required List<Map<String, dynamic>> workers,
  }) async {
    emit(BookingActionLoading());
    try {
      await _api.post(
        'customer/bookings/$bookingId/review',
        data: {
          'service_rating': serviceRating,
          'service_comment': serviceComment,
          'workers': workers,
        },
      );
      emit(BookingReviewSuccess());
    } on DioException catch (e) {
      emit(BookingDetailError(handleDioError(e).message));
    } catch (_) {
      emit(BookingDetailError('Something went wrong'));
    }
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
  final BookingModel booking;
  BookingDetailLoaded(this.booking);
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