import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/models/points_model.dart';

abstract class PointsState {}
class PointsInitial extends PointsState {}
class PointsLoading extends PointsState {}
class PointsLoaded extends PointsState {
  final PointsSummary summary;
  PointsLoaded(this.summary);
}
class PointsError extends PointsState {
  final String message;
  PointsError(this.message);
}

// Earn-points sub-states (used in AllEarnPointsScreen)
abstract class EarnPointsState {}
class EarnPointsInitial extends EarnPointsState {}
class EarnPointsLoading extends EarnPointsState {}
class EarnPointsLoaded extends EarnPointsState {
  final List<EarnPointsItem> items;
  EarnPointsLoaded(this.items);
}
class EarnPointsError extends EarnPointsState {
  final String message;
  EarnPointsError(this.message);
}

class PointsCubit extends Cubit<PointsState> {
  final ApiClient _api;
  PointsCubit(this._api) : super(PointsInitial());

  Future<void> fetchSummary() async {
    emit(PointsLoading());
    try {
      final res = await _api.get('customer/points/summary');
      final summary = PointsSummary.fromJson(res);
      emit(PointsLoaded(summary));
    } on DioException catch (e) {
      emit(PointsError(handleDioError(e).message));
    } catch (_) {
      emit(PointsError('Failed to load points'));
    }
  }

  Future<void> completeTask(int taskId) async {
    try {
      await _api.post('customer/points/complete-task', data: {'task_id': taskId});
      // Refresh summary so points total updates
      fetchSummary();
    } on DioException catch (_) {
      // Silent — task completion failure shouldn't block the user
    } catch (_) {}
  }

  Future<List<PointsHistoryItem>> fetchHistory({
    String? filter,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (filter != null) params['filter'] = filter;
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;
      final res = await _api.get('customer/points/history',
          queryParameters: params);
      return (res['data'] as List<dynamic>? ?? [])
          .map((e) => PointsHistoryItem.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class EarnPointsCubit extends Cubit<EarnPointsState> {
  final ApiClient _api;
  EarnPointsCubit(this._api) : super(EarnPointsInitial());

  Future<void> fetch() async {
    emit(EarnPointsLoading());
    try {
      final res = await _api.get('customer/points/earn-points');
      final items = (res['data'] as List)
          .map((e) => EarnPointsItem.fromJson(e))
          .toList();
      emit(EarnPointsLoaded(items));
    } on DioException catch (e) {
      emit(EarnPointsError(handleDioError(e).message));
    } catch (_) {
      emit(EarnPointsError('Failed to load tasks'));
    }
  }

  void markCompleted(int taskId) {
    final current = state;
    if (current is! EarnPointsLoaded) return;
    final updated = current.items.map((item) {
      return item.id == taskId
          ? EarnPointsItem(
              id: item.id,
              title: item.title,
              subtitle: item.subtitle,
              points: item.points,
              actionType: item.actionType,
              actionLink: item.actionLink,
              isCompleted: true,
            )
          : item;
    }).toList();
    emit(EarnPointsLoaded(updated));
  }
}