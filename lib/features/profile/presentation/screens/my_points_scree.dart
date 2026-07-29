import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/points_model.dart';
import '../cubit/points_cubit.dart';
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

  void _openHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PointsCubit>(),
          child: const AllHistoryScreen(),
        ),
      ),
    );
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _openHistory(context),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: ZienaColors.primary),
                  const SizedBox(width: 4),
                  Text('history'.tr(),
                      style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: ZienaColors.primary,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PointsCubit, PointsState>(
        builder: (context, state) {
          if (state is PointsLoading || state is PointsInitial) {
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

            // ── Progress card(s) ───────────────────────────────────────────
            // The API returns a *list* — could be an invite-friend
            // progress card, a complete-booking progress card, both,
            // or none. Rendered as a swipeable carousel with a dot
            // indicator when there's more than one.
            if (summary.progressCards.isNotEmpty) ...[
              _ProgressCardsCarousel(progressCards: summary.progressCards),
              const SizedBox(height: 20),
            ],

            // ── Invite Friends section ─────────────────────────────────────
            _SectionHeader(title: 'invite_friends'.tr()),
            const SizedBox(height: 12),
            _InviteFriendsCard(summary: summary),

            const SizedBox(height: 20),

            // ── Earn Points section ────────────────────────────────────────
            _SectionHeader(title: 'earn_points'.tr()),
            const SizedBox(height: 12),
            ...summary.earnPoints.map((e) => EarnPointsTile(item: e)),
          ],
        ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          Text(
              '${progress.currentStep} / ${progress.targetStep} ${'completed'.tr()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          if (progress.isCompleted) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.check_circle,
                  color: ZienaColors.success, size: 14),
              const SizedBox(width: 4),
              Text('completed'.tr(),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: ZienaColors.success)),
            ]),
          ] else if (progress.footerText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(progress.footerText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 11, color: ZienaColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

// ── Progress cards carousel ───────────────────────────────────────────────────
// Wraps whatever progress cards the API returns in a swipeable PageView
// with a smooth dot indicator. Uses the controller-based pattern from
// smooth_page_indicator, so the dots track the PageView automatically —
// no manual "current page" state needed.
class _ProgressCardsCarousel extends StatefulWidget {
  final List<PointsProgress> progressCards;
  const _ProgressCardsCarousel({required this.progressCards});

  @override
  State<_ProgressCardsCarousel> createState() => _ProgressCardsCarouselState();
}

class _ProgressCardsCarouselState extends State<_ProgressCardsCarousel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.progressCards;
    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cards.length,
            itemBuilder: (context, index) =>
                _ProgressCard(progress: cards[index]),
          ),
        ),
        if (cards.length > 1) ...[
          const SizedBox(height: 10),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: cards.length,
              effect: const WormEffect(
                dotHeight: 7,
                dotWidth: 7,
                spacing: 6,
                activeDotColor: ZienaColors.primary,
                dotColor: ZienaColors.greyBorder,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
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
              // Not gating on canLaunchUrl() — on Android 11+ it returns
              // false for https URLs unless the app's manifest declares
              // a <queries> block for the browser intent, which most
              // projects don't have. Launching directly (with a
              // try/catch) works regardless of that manifest entry.
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {
                // No app/browser available to handle the link — ignore
                // and still let the task complete below.
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
            item.isCompleted ? 'done'.tr() : item.actionLabel.tr(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

// ── Invite friends card ───────────────────────────────────────────────────────
class _InviteFriendsCard extends StatefulWidget {
  final PointsSummary summary;
  const _InviteFriendsCard({required this.summary});

  @override
  State<_InviteFriendsCard> createState() => _InviteFriendsCardState();
}

class _InviteFriendsCardState extends State<_InviteFriendsCard> {
  bool _generating = false;

  // Invite is enabled by default (you already have a usable code from
  // the summary) and only gets locked when a manual generate attempt
  // comes back with a confirmed limit signal from the API.
  bool _limitReached = false;
  String? _lockMessage;

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.summary.referralCode));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('code_copied'.tr())),
      );
    }
  }

  Future<void> _shareInvite(BuildContext context) async {
    final isArabic = context.locale.languageCode == 'ar';
    final message = isArabic
        ? widget.summary.shareMessageAr
        : widget.summary.shareMessageEn;
    if (message.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('err_generic'.tr())),
        );
      }
      return;
    }
    // Just shares the current code — generation is manual now, only
    // triggered by tapping "Generate Referral Code" / "Generate new
    // code" below, never automatically.
    await Share.share(message);
  }

  Future<void> _generateCode(BuildContext context) async {
    setState(() => _generating = true);
    final result = await context.read<PointsCubit>().generateReferralCode();
    if (!context.mounted) return;
    setState(() {
      _generating = false;
      if (result.limitReached) {
        _limitReached = true;
        _lockMessage = result.message;
      }
    });
    // Always a manual, explicit tap now — always show feedback.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message ?? 'err_generic'.tr())),
    );
  }

  /// "2026-07-18 14:08:20" -> "2026-07-18". Falls back to the raw
  /// string if the API ever changes the format.
  String _formatExpiry(String raw) => raw.split(' ').first;

  @override
  Widget build(BuildContext context) {
    final hasCode = widget.summary.referralCode.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('your_code_invite_friends'.tr(),
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 4),
          Text('copy_code_invite_friend'.tr(),
              style: const TextStyle(
                  fontSize: 12, color: ZienaColors.textSecondary)),
          const SizedBox(height: 14),
          if (!hasCode)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_generating || _limitReached)
                    ? null
                    : () => _generateCode(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _limitReached
                      ? ZienaColors.greyBorder
                      : ZienaColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _generating
                    ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text('generate_referral_code'.tr(),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: ZienaColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => _copyCode(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Text(
                          widget.summary.referralCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.primary,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    // Locked only on a confirmed limit-reached signal —
                    // not gated on the background pre-warm having
                    // succeeded, since that made a single unrelated
                    // network hiccup permanently disable Invite.
                    onPressed: (_limitReached || _generating)
                        ? null
                        : () => _shareInvite(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (_limitReached || _generating)
                          ? ZienaColors.greyBorder
                          : ZienaColors.primary,
                      foregroundColor: (_limitReached || _generating)
                          ? ZienaColors.textHint
                          : Colors.white,
                      elevation: 0,
                      // The app-wide ElevatedButtonTheme sets
                      // minimumSize: Size(double.infinity, 52), which is
                      // fine for full-width buttons but breaks any button
                      // placed inside a Row (unbounded width constraint
                      // crash). Override it here since this button sits
                      // next to an Expanded sibling.
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: _generating
                        ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          color: ZienaColors.textHint, strokeWidth: 2),
                    )
                        : Text('invite'.tr(),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_limitReached)
              Text(
                _lockMessage ?? 'referral_limit_reached'.tr(),
                style: const TextStyle(fontSize: 11, color: ZienaColors.error),
              )
            else
              Row(
                children: [
                  if (widget.summary.referralExpiresAt != null) ...[
                    Expanded(
                      child: Text(
                        '${'code_expires_on'.tr()} '
                            '${_formatExpiry(widget.summary.referralExpiresAt!)}',
                        style: const TextStyle(
                            fontSize: 11, color: ZienaColors.textHint),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  InkWell(
                    onTap: _generating ? null : () => _generateCode(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_generating)
                            const SizedBox(
                              width: 12, height: 12,
                              child: CircularProgressIndicator(
                                  color: ZienaColors.primary, strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.refresh,
                                size: 14, color: ZienaColors.primary),
                          const SizedBox(width: 4),
                          Text('generate_new_code'.tr(),
                              style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: ZienaColors.primary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

// ── History tile ──────────────────────────────────────────────────────────────
// Unchanged — still used by AllHistoryScreen. isEarn now comes from the
// amount's sign (see PointsHistoryItem), so this widget needed no edits.
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