import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel item;
  const NotificationDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.image != null) {
      return Scaffold(
        backgroundColor: ZienaColors.white,
        body: CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.black26,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: ZienaColors.textPrimary),
              ),
            ),
            title: Text('notification_detail'.tr(),
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: item.image!, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: ZienaColors.bg3),
                errorWidget: (_, __, ___) => Container(
                    color: ZienaColors.bg3,
                    child: const Icon(Icons.campaign_rounded,
                        color: ZienaColors.primary, size: 80)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: _NotificationContent(item: item, large: true),
            ),
          ),
        ]),
      );
    }

    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('notification_detail'.tr(),
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        child: _NotificationContent(item: item),
      ),
    );
  }
}

/// Title, body and time of a notification. Fills the full width and takes
/// its text direction from the notification's own content, so Arabic
/// notifications are right-aligned (RTL) even when the app is in English,
/// and vice versa.
class _NotificationContent extends StatelessWidget {
  final NotificationModel item;
  final bool large;
  const _NotificationContent({required this.item, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isRtl = Bidi.detectRtlDirectionality('${item.title} ${item.body}');
    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(item.title,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: large ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: large ? ZienaColors.primary : ZienaColors.textPrimary,
              )),
          SizedBox(height: large ? 14 : 12),
          Text(item.body,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                color: ZienaColors.textSecondary,
                height: 1.7,
              )),
          const SizedBox(height: 16),
          Text(item.createdAt,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 12, color: ZienaColors.textHint)),
        ],
      ),
    );
  }
}
