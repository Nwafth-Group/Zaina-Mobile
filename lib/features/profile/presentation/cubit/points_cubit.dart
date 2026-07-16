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

  /// [silent]: skips emitting PointsLoading (so the screen doesn't flash
  /// to a full loading spinner) and skips emitting PointsError on
  /// failure (so a transient background refresh can't wipe out an
  /// already-good PointsLoaded state). Used for refreshes triggered by
  /// background actions like generateReferralCode(); the initial screen
  /// load and pull-to-refresh should keep using the default (non-silent)
  /// behavior.
  Future<void> fetchSummary({bool silent = false}) async {
    if (!silent) emit(PointsLoading());
    try {
      final res = await _api.get('customer/points/summary');
      final summary = PointsSummary.fromJson(res);
      emit(PointsLoaded(summary));
    } on DioException catch (e) {
      if (!silent) emit(PointsError(handleDioError(e).message));
    } catch (_) {
      if (!silent) emit(PointsError('Failed to load points'));
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

  /// POST customer/points/generate-referral-code — mints a fresh
  /// referral code (with its own expiry), then re-fetches the whole
  /// summary (silently — no loading flash) so points total, progress
  /// cards, and everything else stay in sync too, not just the code.
  ///
  /// Returns a [ReferralCodeResult] rather than just a message, so the
  /// UI can tell "generation failed" apart from "generation failed
  /// *because the referral limit was reached*" — the latter needs to
  /// permanently disable the Invite button, not just show a one-off
  /// snackbar.
  Future<ReferralCodeResult> generateReferralCode() async {
    final current = state;
    if (current is! PointsLoaded) {
      return const ReferralCodeResult(success: false, limitReached: false);
    }
    try {
      final res = await _api.post('customer/points/generate-referral-code');
      final data = (res['data'] as Map<String, dynamic>?) ?? {};
      final newCode = data['referral_code'] as String?;
      if (newCode == null || newCode.isEmpty) {
        return ReferralCodeResult(
          success: false,
          limitReached: false,
          message: res['message'] as String?,
        );
      }

      // Re-fetch the full summary rather than just patching the code
      // locally via copyWith. If this silent refresh happens to fail,
      // it fails quietly and the previous PointsLoaded state is left
      // untouched — the generate call itself still succeeded server-side
      // even if we couldn't immediately confirm the new state here.
      await fetchSummary(silent: true);

      return ReferralCodeResult(
        success: true,
        limitReached: false,
        message: res['message'] as String?,
      );
    } on DioException catch (e) {
      final message = handleDioError(e).message;
      final statusCode = e.response?.statusCode;
      // Heuristic for "referral limit reached": 403/422 status, or the
      // message itself mentioning "limit". Adjust this once you confirm
      // the exact status/shape your backend actually returns for it.
      final limitReached = statusCode == 403 ||
          statusCode == 422 ||
          message.toLowerCase().contains('limit');
      return ReferralCodeResult(
        success: false,
        limitReached: limitReached,
        message: message,
      );
    } catch (_) {
      return const ReferralCodeResult(success: false, limitReached: false);
    }
  }
}

/// Result of a generate-referral-code attempt.
class ReferralCodeResult {
  final bool success;
  final bool limitReached;
  final String? message;

  const ReferralCodeResult({
    required this.success,
    required this.limitReached,
    this.message,
  });
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