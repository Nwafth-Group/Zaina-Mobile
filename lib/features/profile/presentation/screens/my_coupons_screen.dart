import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/coupon_model.dart';
import '../cubit/coupons_cubit.dart';
import 'coupon_screen.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CouponsCubit>().fetchCoupons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('my_coupons'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: BlocBuilder<CouponsCubit, CouponsState>(
        builder: (context, state) {
          if (state is CouponsLoading) {
            return const Center(child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2));
          }
          if (state is CouponsLoaded) {
            if (state.coupons.isEmpty) return _buildEmpty();
            final active = state.coupons.where((c) => !c.isExpired).toList();
            final used   = state.coupons.where((c) => c.isExpired).toList();
            return _buildList(context, active, used);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ImageAsset(
          'assets/images/cop_empty.png',
          width: 180, height: 180,
        ),
        const SizedBox(height: 8),
        Text('no_coupons_yet'.tr(),
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('no_coupons_desc'.tr(),
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center),
      ]),
    ));
  }

  Widget _buildList(BuildContext ctx,
      List<CouponModel> active, List<CouponModel> used) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ...active.map((c) => _CouponCard(
          coupon: c, isUsed: false,
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: ctx.read<CouponsCubit>(),
              child: CouponDetailScreen(coupon: c),
            ),
          )),
        )),
        if (used.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('used_coupons'.tr(),
              style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 10),
          ...used.map((c) => _CouponCard(
            coupon: c, isUsed: true,
            onTap: () => Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: ctx.read<CouponsCubit>(),
                child: CouponDetailScreen(coupon: c),
              ),
            )),
          )),
        ],
      ],
    );
  }
}

// ── Coupon card ───────────────────────────────────────────────────────────────
class _CouponCard extends StatelessWidget {
  final CouponModel coupon;
  final bool isUsed;
  final VoidCallback onTap;

  const _CouponCard({
    required this.coupon,
    required this.isUsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isUsed
              ? ZienaColors.primary.withOpacity(0.5)
              : ZienaColors.primary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: [
            // ── Top (pink) ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: isUsed
                  ? ZienaColors.primary.withOpacity(0.5)
                  : ZienaColors.primary,
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coupon.expiresIn,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(coupon.displayValue,
                        style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    Text(coupon.isForAllServices
                        ? 'Valid for All Services'
                        : 'Valid for ${coupon.eligibleServices.first.name}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ],
                )),
                // Ticket icon
                ImageAsset(
                  'assets/images/cop.png',
                  width: 48, height: 48,
                ),
              ]),
            ),

            // ── Dotted divider ────────────────────────────────────────────
            Container(
              height: 1,
              color: ZienaColors.bg1,
              child: Row(children: List.generate(30, (i) => Expanded(
                child: Container(
                  height: 1,
                  color: i % 2 == 0 ? ZienaColors.greyBorder : Colors.transparent,
                ),
              ))),
            ),

            // ── Bottom (code) ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              color: isUsed
                  ? ZienaColors.primary.withOpacity(0.5)
                  : ZienaColors.primary,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4)),
                ),
                child: Text(coupon.code,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 1.2,
                    )),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
