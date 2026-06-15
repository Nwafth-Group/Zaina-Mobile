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
