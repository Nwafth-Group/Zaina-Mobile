import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/points_model.dart';
import '../cubit/points_cubit.dart';

class AllEarnPointsScreen extends StatelessWidget {
  const AllEarnPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EarnPointsCubit>()..fetch(),
      child: Scaffold(
        backgroundColor: ZienaColors.bg1,
        appBar: AppBar(
          backgroundColor: ZienaColors.bg1,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('earn_points'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        body: BlocBuilder<EarnPointsCubit, EarnPointsState>(
          builder: (context, state) {
            if (state is EarnPointsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ZienaColors.primary),
              );
            }
            if (state is EarnPointsError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(state.message,
                      style: const TextStyle(color: ZienaColors.textSecondary)),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<EarnPointsCubit>().fetch(),
                    child: Text('retry'.tr(),
                        style: const TextStyle(color: ZienaColors.primary)),
                  ),
                ]),
              );
            }
            if (state is EarnPointsLoaded) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text('no_tasks'.tr(),
                      style: const TextStyle(color: ZienaColors.textSecondary)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                itemBuilder: (ctx, i) => _EarnTile(item: state.items[i]),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _EarnTile extends StatelessWidget {
  final EarnPointsItem item;
  const _EarnTile({required this.item});

  IconData _icon() {
    if (item.actionType == 'invite_friend') return Icons.person_add_outlined;
    if (item.actionType == 'rate_service') return Icons.star_outline_rounded;
    if (item.title.toLowerCase().contains('facebook')) return Icons.facebook;
    return Icons.camera_alt_outlined;
  }

  Future<void> _onTap(BuildContext context) async {
    final cubit = context.read<EarnPointsCubit>();
    final pointsCubit = context.read<PointsCubit>();

    // Open the link
    if (item.actionLink != null) {
      final uri = Uri.parse(item.actionLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    // Mark complete locally + call API
    cubit.markCompleted(item.id);
    pointsCubit.completeTask(item.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isCompleted
            ? ZienaColors.bg1
            : ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isCompleted
              ? ZienaColors.greyBorder
              : ZienaColors.greyBorder,
          width: 0.5,
        ),
      ),
      child: Row(children: [
        // Icon circle
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: item.isCompleted
                ? ZienaColors.greyLight
                : ZienaColors.bg2,
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isCompleted ? Icons.check_circle_rounded : _icon(),
            color: item.isCompleted
                ? ZienaColors.success
                : ZienaColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isCompleted
                      ? ZienaColors.greyLight
                      : ZienaColors.bg2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(item.points,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.isCompleted
                            ? ZienaColors.textHint
                            : ZienaColors.primary,
                      )),
                  const SizedBox(width: 3),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.isCompleted
                          ? ZienaColors.textHint
                          : ZienaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Colors.white, size: 7),
                  ),
                ]),
              ),
              const SizedBox(height: 3),
              Text(item.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: item.isCompleted
                        ? ZienaColors.textSecondary
                        : ZienaColors.textPrimary,
                  )),
              Text(item.subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: ZienaColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Action button
        item.isCompleted
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ZienaColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('done'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.success,
                    )),
              )
            : ElevatedButton(
                onPressed: () => _onTap(context),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(ZienaColors.primary),
                  foregroundColor:
                      WidgetStateProperty.all(Colors.white),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8)),
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(item.actionLabel,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
      ]),
    );
  }
}
