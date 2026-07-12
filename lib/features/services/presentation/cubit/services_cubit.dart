import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/coverage_model.dart';
import '../../data/model/service_model.dart';
import '../../data/model/visit_type_model.dart';
import '../../data/repository/services_repository.dart';

// ── Services List Cubit ───────────────────────────────────────────────────────
class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _repo;
  ServicesCubit(this._repo) : super(ServicesInitial());

  Future<void> fetchServices(String type) async {
    emit(ServicesLoading());
    try {
      final services = await _repo.fetchServices(type: type);
      emit(ServicesLoaded(services));
    } on DioException catch (e) {
      emit(ServicesError(handleDioError(e).message));
    } catch (_) {
      emit(ServicesError('Something went wrong'));
    }
  }

  /// Pass-through call — does NOT touch [state], since it's a one-off check
  /// triggered by tapping a service tile, not a list-rebuilding action.
  /// Throws on network failure; callers should wrap in try/catch.
  Future<CoverageModel> checkCoverage(int serviceId) {
    return _repo.checkCoverage(serviceId);
  }

  /// Pass-through, same reasoning as [checkCoverage] — a one-off call
  /// triggered by tapping a tile, not a list-rebuilding action. Used to
  /// decide whether to skip the visit-type picker when a service only
  /// offers one option.
  Future<List<VisitTypeModel>> fetchVisitTypes(int serviceId) {
    return _repo.fetchAvailableVisitTypes(serviceId);
  }
}

abstract class ServicesState {}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<ServiceModel> services;
  ServicesLoaded(this.services);
}

class ServicesError extends ServicesState {
  final String message;
  ServicesError(this.message);
}

// ── Visit Types Cubit (bottom sheet) ──────────────────────────────────────────
class VisitTypesCubit extends Cubit<VisitTypesState> {
  final ServicesRepository _repo;
  VisitTypesCubit(this._repo) : super(VisitTypesInitial());

  Future<void> fetchVisitTypes(int serviceId) async {
    emit(VisitTypesLoading());
    try {
      final types = await _repo.fetchAvailableVisitTypes(serviceId);
      emit(VisitTypesLoaded(types));
    } on DioException catch (e) {
      emit(VisitTypesError(handleDioError(e).message));
    } catch (_) {
      emit(VisitTypesError('Something went wrong'));
    }
  }
}

abstract class VisitTypesState {}

class VisitTypesInitial extends VisitTypesState {}

class VisitTypesLoading extends VisitTypesState {}

class VisitTypesLoaded extends VisitTypesState {
  final List<VisitTypeModel> types;
  VisitTypesLoaded(this.types);
}

class VisitTypesError extends VisitTypesState {
  final String message;
  VisitTypesError(this.message);
}