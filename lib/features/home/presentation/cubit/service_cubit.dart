import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/service_model.dart';
// ═══════════════════════════════════════════════════════
// SERVICE DETAIL CUBIT
// ═══════════════════════════════════════════════════════

class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final ApiClient _api;
  ServiceDetailCubit(this._api) : super(ServiceDetailInitial());

  Future<void> fetchServiceDetail(int serviceId) async {
    emit(ServiceDetailLoading());
    try {
      final res = await _api.get('customer/services/$serviceId');
      final model = ServiceDetailModel.fromJson(res);
      emit(ServiceDetailLoaded(model));
    } on DioException catch (e) {
      emit(ServiceDetailError(handleDioError(e).message));
    } catch (e) {
      print("eeeeeee $e");
      emit(ServiceDetailError('Something went wrong'));
    }
  }
}

// ═══════════════════════════════════════════════════════
// POPULAR SERVICES CUBIT
// ═══════════════════════════════════════════════════════
class PopularServicesCubit extends Cubit<PopularServicesState> {
  final ApiClient _api;
  PopularServicesCubit(this._api) : super(PopularServicesInitial());

  List<ServiceModel> _items = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  Future<void> fetchServices({bool refresh = false}) async {
    if (refresh) {
      _items = [];
      _currentPage = 1;
    }
    emit(PopularServicesLoading());
    try {
      final res = await _api.get(
        'customer/services',
        queryParameters: {'page': 1},
      );
      print("rrrrrr $res");
      final data = res['data'];
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? 1;
      _lastPage = meta['last_page'] ?? 1;
      _items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList();
      emit(PopularServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
        total: meta['total'] ?? 0,
      ));
    } on DioException catch (e) {
      print("eeeeee $e");
      emit(PopularServicesError(handleDioError(e).message));
    } catch (e) {
      print("eeeeee1 $e");

      emit(PopularServicesError('Something went wrong'));
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    _loadingMore = true;
    emit(PopularServicesLoadingMore(List.from(_items)));
    try {
      final res = await _api.get(
        'customer/services',
        queryParameters: {'page': _currentPage + 1},
      );
      final data = res;
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? _currentPage;
      _lastPage = meta['last_page'] ?? _lastPage;
      _items.addAll((data['items'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList());
      emit(PopularServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
        total: meta['total'] ?? _items.length,
      ));
    } on DioException {
      emit(PopularServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
        total: _items.length,
      ));
    } finally {
      _loadingMore = false;
    }
  }
}


// ── Service Detail States ─────────────────────────────────────────────────────
abstract class ServiceDetailState {}
class ServiceDetailInitial extends ServiceDetailState {}
class ServiceDetailLoading extends ServiceDetailState {}
class ServiceDetailLoaded extends ServiceDetailState {
  final ServiceDetailModel service;
  ServiceDetailLoaded(this.service);
}
class ServiceDetailError extends ServiceDetailState {
  final String message;
  ServiceDetailError(this.message);
}

// ── Popular Services States ───────────────────────────────────────────────────
abstract class PopularServicesState {}
class PopularServicesInitial extends PopularServicesState {}
class PopularServicesLoading extends PopularServicesState {}
class PopularServicesLoadingMore extends PopularServicesState {
  final List<ServiceModel> current;
  PopularServicesLoadingMore(this.current);
}
class PopularServicesLoaded extends PopularServicesState {
  final List<ServiceModel> services;
  final int currentPage;
  final int lastPage;
  final int total;
  bool get hasMore => currentPage < lastPage;
  PopularServicesLoaded({
    required this.services,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}
class PopularServicesError extends PopularServicesState {
  final String message;
  PopularServicesError(this.message);
}