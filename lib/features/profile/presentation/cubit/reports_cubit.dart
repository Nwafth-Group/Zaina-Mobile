import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/models/legal_model.dart';

abstract class ReportsState {}
class ReportsInitial extends ReportsState {}
class ReportsLoading extends ReportsState {}
class ReportsLoaded extends ReportsState {
  final List<ReportModel> reports;
  ReportsLoaded(this.reports);
}
class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

class ReportsCubit extends Cubit<ReportsState> {
  final ApiClient _api;
  ReportsCubit(this._api) : super(ReportsInitial());

  Future<void> fetchReports() async {
    emit(ReportsLoading());
    try {
      final res = await _api.get('customer/reports');
      final items = (res['data']['items'] as List)
          .map((e) => ReportModel.fromJson(e))
          .toList();
      emit(ReportsLoaded(items));
    } on DioException catch (e) {
      emit(ReportsError(handleDioError(e).message));
    } catch (_) {
      emit(ReportsError('Failed to load reports'));
    }
  }
}

// ── Report detail ──────────────────────────────────────────────────────
// Powers the report details screen via GET customer/reports/{id}. Kept
// separate from ReportsCubit (same pattern as PointsCubit/EarnPointsCubit)
// since the list and the detail view have independent loading states.
abstract class ReportDetailState {}
class ReportDetailInitial extends ReportDetailState {}
class ReportDetailLoading extends ReportDetailState {}
class ReportDetailLoaded extends ReportDetailState {
  final ReportModel report;
  ReportDetailLoaded(this.report);
}
class ReportDetailError extends ReportDetailState {
  final String message;
  ReportDetailError(this.message);
}

class ReportDetailCubit extends Cubit<ReportDetailState> {
  final ApiClient _api;
  ReportDetailCubit(this._api) : super(ReportDetailInitial());

  Future<void> fetchReportDetail(int id) async {
    emit(ReportDetailLoading());
    try {
      final res = await _api.get('customer/reports/$id');
      final report = ReportModel.fromJson(res['data']);
      emit(ReportDetailLoaded(report));
    } on DioException catch (e) {
      emit(ReportDetailError(handleDioError(e).message));
    } catch (_) {
      emit(ReportDetailError('Failed to load report details'));
    }
  }
}