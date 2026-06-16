import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/notification_model.dart';
import '../cubit/notifications_cubit.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationTabType _tab = NotificationTabType.notification;
  late NotificationsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<NotificationsCubit>();
    _cubit.fetch(_tab);
  }

  void _selectTab(NotificationTabType tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    _cubit.fetch(tab);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: ZienaColors.bg1,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: ZienaColors.bg1, elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('notification'.tr(),
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        body: Column(children: [
          _buildTabs(),
          Expanded(
            child: BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoading) {
                  return const Center(child: CircularProgressIndicator(
                      color: ZienaColors.primary));
                }
                if (state is NotificationsError) {
                  return Center(child: Text(state.message,
                      style: const TextStyle(
                          color: ZienaColors.textSecondary)));
                }
                if (state is NotificationsLoaded) {
                  if (state.items.isEmpty) return _buildEmpty();
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _NotificationCard(
                        item: item,
                        onTap: () {
                          _cubit.markAsRead(item);
                          Navigator.push(context, MaterialPageRoute(
                            builder: (_) =>
                                NotificationDetailScreen(item: item),
                          ));
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZienaColors.greyBorder.withOpacity(0.6)),
        ),
        child: Row(children: [
          _tabButton('notification'.tr(), NotificationTabType.notification),
          _tabButton('announcement'.tr(), NotificationTabType.announcement),
        ]),
      ),
    );
  }

  Widget _tabButton(String label, NotificationTabType type) {
    final selected = _tab == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTab(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? ZienaColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: selected ? ZienaColors.white : ZienaColors.textHint,
              )),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final screenSize = MediaQuery.of(context).size.width * 0.7;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_notifications.png',
            width: screenSize, height: screenSize,
          ),
          const SizedBox(height: 24),
          Text('no_notification_items'.tr(),
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationModel item;
  final VoidCallback onTap;
  const _NotificationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isRead ? ZienaColors.white : ZienaColors.bg2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: ZienaColors.greyBorder.withOpacity(0.5), width: 0.6),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ImageAsset(
            'assets/images/notification.png',
            width: 40, height: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTitle(item.title),
          ),
          const SizedBox(width: 8),
          Text(item.createdAt,
              style: const TextStyle(
                  fontSize: 11, color: ZienaColors.textHint)),
        ]),
      ),
    );
  }

  Widget _buildTitle(String title) {
    final firstSpace = title.indexOf(' ');
    final firstWord = firstSpace == -1 ? title : title.substring(0, firstSpace);
    final rest = firstSpace == -1 ? '' : title.substring(firstSpace);
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: firstWord,
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary, height: 1.4,
          ),
        ),
        TextSpan(
          text: rest,
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w400,
            color: ZienaColors.textPrimary, height: 1.4,
          ),
        ),
      ]),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
