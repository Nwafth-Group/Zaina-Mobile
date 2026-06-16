import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/notification_model.dart';

enum NotificationTabType { notification, announcement }

extension NotificationTabTypeX on NotificationTabType {
  String get apiValue =>
      this == NotificationTabType.notification ? 'notification' : 'announcement';
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final ApiClient _api;
  NotificationsCubit(this._api) : super(NotificationsInitial());

  Future<void> fetch(NotificationTabType type) async {
    emit(NotificationsLoading());
    try {
      final res = await _api.get(
        'customer/notifications/',
        queryParameters: {'type': type.apiValue},
      );
      final data = res['data'];
      final rawList = data is List
          ? data
          : (data['items'] as List<dynamic>? ?? []);
      final items = rawList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(NotificationsLoaded(items, type));
    } on DioException catch (e) {
      emit(NotificationsError(handleDioError(e).message));
    } catch (e) {
      emit(NotificationsError('Something went wrong'));
    }
  }

  Future<void> markAsRead(NotificationModel item) async {
    final current = state;
    if (current is NotificationsLoaded) {
      final updated = current.items
          .map((n) => n.id == item.id ? n.copyWith(isRead: true) : n)
          .toList();
      emit(NotificationsLoaded(updated, current.type));
    }
    try {
      await _api.post(
        'customer/notifications/${item.id}/read?type=${current is NotificationsLoaded ? current.type.apiValue : ''}',
      );
    } catch (_) {}
  }
}

// ── States ───────────────────────────────────────────────────────────────────
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> items;
  final NotificationTabType type;
  NotificationsLoaded(this.items, this.type);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}
