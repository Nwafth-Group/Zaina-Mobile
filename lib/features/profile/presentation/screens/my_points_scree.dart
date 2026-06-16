import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/points_model.dart';
import '../cubit/points_cubit.dart';
import 'all_earcn_points_screen.dart';
import 'all_history_scree.dart';

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PointsCubit>().fetchSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('my_points'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: BlocBuilder<PointsCubit, PointsState>(
        builder: (context, state) {
          if (state is PointsLoading) {
            return const Center(child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2));
          }
          if (state is PointsError) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message,
                    style: const TextStyle(color: ZienaColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<PointsCubit>().fetchSummary(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary, elevation: 0),
                  child: Text('retry'.tr(),
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ));
          }
          if (state is PointsLoaded) {
            return _buildContent(context, state.summary);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PointsSummary summary) {
    return RefreshIndicator(
      color: ZienaColors.primary,
      onRefresh: () => context.read<PointsCubit>().fetchSummary(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Total points card ──────────────────────────────────────────
            _TotalPointsCard(points: summary.totalPoints),
            const SizedBox(height: 16),

            // ── Progress card ──────────────────────────────────────────────
            _ProgressCard(progress: summary.progress),
            const SizedBox(height: 20),

            // ── Earn Points section ────────────────────────────────────────
            _SectionHeader(
              title: 'earn_points'.tr(),
              onSeeAll: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<PointsCubit>(),
                  child: const AllEarnPointsScreen(),
                ),
              )),
            ),
            const SizedBox(height: 12),
            ...summary.earnPoints.take(3).map(
                    (e) => EarnPointsTile(item: e)),

            const SizedBox(height: 20),

            // ── History section ────────────────────────────────────────────
            _SectionHeader(
              title: 'history'.tr(),
              onSeeAll: summary.history.isNotEmpty
                  ? () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<PointsCubit>(),
                  child: const AllHistoryScreen(),
                ),
              ))
                  : null,
            ),
            const SizedBox(height: 12),
            if (summary.history.isEmpty)
              _buildNoHistory()
            else
              ...summary.history.take(4).map(
                      (h) => HistoryTile(item: h)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(children: [
          const Icon(Icons.history_toggle_off_rounded,
              size: 60, color: ZienaColors.greyBorder),
          const SizedBox(height: 12),
          Text('no_history_yet'.tr(),
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 6),
          Text('no_history_desc'.tr(),
              style: const TextStyle(
                  fontSize: 13, color: ZienaColors.textSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Total points card ─────────────────────────────────────────────────────────
class _TotalPointsCard extends StatelessWidget {
  final int points;
  const _TotalPointsCard({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ZienaColors.primary, ZienaColors.primaryLight],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: ZienaColors.primary.withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('total_points'.tr(),
                style: const TextStyle(
                  fontSize: 13, color: Colors.white70,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 6),
            Text('$points ${"Pts".tr()}',
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ],
        )),
        ImageAsset('assets/images/points.png',
          width: 54, height: 54,
        ),
      ]),
    );
  }
}

// ── Progress card ─────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final PointsProgress progress;
  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(progress.title,
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                ))),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ZienaColors.bg2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('+${progress.rewardPoints} Pts',
                    style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: ZienaColors.primary,
                    )),
                const SizedBox(width: 4),
                Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                      color: ZienaColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.star, color: Colors.white, size: 10),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 6),
          Text('${progress.currentStep} / ${progress.targetStep} completed',
              style: const TextStyle(
                  fontSize: 12, color: ZienaColors.textSecondary)),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.progress,
              backgroundColor: ZienaColors.bg3,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  ZienaColors.primary),
              minHeight: 8,
            ),
          ),
          if (progress.currentStep < progress.targetStep) ...[
            const SizedBox(height: 8),
            Text(progress.footerText,
                style: const TextStyle(
                    fontSize: 11, color: ZienaColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ── Earn points tile ──────────────────────────────────────────────────────────
class EarnPointsTile extends StatelessWidget {
  final EarnPointsItem item;
  const EarnPointsTile({required this.item});

  IconData _icon() {
    switch (item.actionType) {
      case 'url':
        if (item.title.toLowerCase().contains('facebook')) {
          return Icons.facebook;
        }
        return Icons.camera_alt_outlined;
      case 'invite_friend': return Icons.person_add_outlined;
      case 'rate_service':  return Icons.star_outline_rounded;
      default:              return Icons.wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
      ),
      child: Row(children: [
        // Icon circle
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: ZienaColors.bg2, shape: BoxShape.circle),
          child: Icon(_icon(), color: ZienaColors.primary, size: 20),
        ),
        const SizedBox(width: 12),

        // Text
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Points badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ZienaColors.bg2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(item.points,
                    style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: ZienaColors.primary,
                    )),
                const SizedBox(width: 3),
                Container(
                  width: 12, height: 12,
                  decoration: const BoxDecoration(
                      color: ZienaColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.star,
                      color: Colors.white, size: 7),
                ),
              ]),
            ),
            const SizedBox(height: 3),
            Text(item.title,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                )),
            Text(item.subtitle,
                style: const TextStyle(
                    fontSize: 11, color: ZienaColors.textSecondary)),
          ],
        )),
        const SizedBox(width: 8),

        // Action button
        ElevatedButton(
          onPressed: item.isCompleted ? null : () async {
            if (item.actionLink != null) {
              final uri = Uri.parse(item.actionLink!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
            if (context.mounted) {
              context.read<PointsCubit>().completeTask(item.id);
            }
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              item.isCompleted ? ZienaColors.greyBorder : ZienaColors.primary,
            ),
            foregroundColor: WidgetStateProperty.all(Colors.white),
            elevation: WidgetStateProperty.all(0),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            minimumSize: WidgetStateProperty.all(Size.zero),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            item.isCompleted ? 'done'.tr() : item.actionLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────
class HistoryTile extends StatelessWidget {
  final PointsHistoryItem item;
  const HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isEarn = item.isEarn;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isEarn
                ? ZienaColors.success.withOpacity(0.1)
                : ZienaColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEarn
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: isEarn ? ZienaColors.success : ZienaColors.error,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title,
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(item.date,
                style: const TextStyle(
                    fontSize: 11, color: ZienaColors.textHint)),
          ],
        )),
        Text(item.amount,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: isEarn ? ZienaColors.success : ZienaColors.error,
            )),
      ]),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text('see_all'.tr(),
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: ZienaColors.primary,
                )),
          ),
      ],
    );
  }
}