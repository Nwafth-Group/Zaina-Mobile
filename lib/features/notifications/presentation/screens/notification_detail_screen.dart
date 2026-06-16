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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700,
                        color: ZienaColors.primary,
                      )),
                  const SizedBox(height: 14),
                  Text(item.body,
                      style: const TextStyle(
                        fontSize: 14, color: ZienaColors.textSecondary,
                        height: 1.7,
                      )),
                  const SizedBox(height: 16),
                  Text(item.createdAt,
                      style: const TextStyle(
                          fontSize: 12, color: ZienaColors.textHint)),
                ],
              ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 12),
            Text(item.body,
                style: const TextStyle(
                  fontSize: 14, color: ZienaColors.textSecondary,
                  height: 1.7,
                )),
            const SizedBox(height: 16),
            Text(item.createdAt,
                style: const TextStyle(
                    fontSize: 12, color: ZienaColors.textHint)),
          ],
        ),
      ),
    );
  }
}
