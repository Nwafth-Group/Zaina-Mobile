import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/shared_pref_helper.dart';

/// GET customer/notifications/unread-count
/// { unread_count, notifications_unread_count, announcements_unread_count, has_unread }
class UnreadCount {
  final int total;
  final int notifications;
  final int announcements;
  final bool hasUnread;

  const UnreadCount({
    this.total = 0,
    this.notifications = 0,
    this.announcements = 0,
    this.hasUnread = false,
  });

  static const zero = UnreadCount();

  static int _int(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  factory UnreadCount.fromJson(Map<String, dynamic> j) {
    final total = _int(j['unread_count']);
    return UnreadCount(
      total: total,
      notifications: _int(j['notifications_unread_count']),
      announcements: _int(j['announcements_unread_count']),
      hasUnread: j['has_unread'] == true || total > 0,
    );
  }
}

/// App-level cubit holding the unread notifications badge count.
/// State is always an [UnreadCount] (zero when logged out or on failure),
/// so the badge simply hides instead of showing an error.
class UnreadCountCubit extends Cubit<UnreadCount> {
  final ApiClient _api;
  UnreadCountCubit(this._api) : super(UnreadCount.zero);

  Future<void> fetch() async {
    if (!SharedPrefHelper.isLoggedIn()) {
      if (!isClosed) emit(UnreadCount.zero);
      return;
    }
    try {
      final res = await _api.get(AppConstants.notificationsUnreadCount);
      final data = res['data'];
      if (data is Map<String, dynamic> && !isClosed) {
        emit(UnreadCount.fromJson(data));
      }
    } catch (_) {
      // Keep the last known count — a failed refresh shouldn't hide the badge.
    }
  }

  void reset() => emit(UnreadCount.zero);
}
