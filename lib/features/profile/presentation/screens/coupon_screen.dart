import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_icon.dart';
import '../../data/models/coupon_model.dart';

class CouponDetailScreen extends StatelessWidget {
  final CouponModel coupon;
  const CouponDetailScreen({super.key, required this.coupon});

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
        title: Text('coupon_details'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // ── Coupon banner ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ZienaColors.primary, ZienaColors.primaryDark],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coupon.expiresIn,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(coupon.displayValue,
                      style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text(coupon.isForAllServices
                      ? 'Valid for All Services'
                      : 'Valid for ${coupon.eligibleServices.first.name}',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.white70)),
                ],
              )),
              ImageAsset(
                'assets/images/cop.png',
                width: 55, height: 55,
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Details card ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
            ),
            child: Column(children: [
              _DetailRow(
                icon: Icons.circle,
                iconColor: ZienaColors.primary,
                text: 'Minimum Order: ${coupon.minBookingAmount?.toInt() ?? 0} EGP',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.circle,
                iconColor: ZienaColors.primary,
                text: 'Valid Until: ${coupon.validUntil}',
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.circle,
                iconColor: ZienaColors.primary,
                text: 'Applicable For: ${coupon.applicableFor}',
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // ── Code card ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ZienaColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('code'.tr(),
                    style: const TextStyle(
                        fontSize: 12, color: ZienaColors.textSecondary)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Text(coupon.code,
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w700,
                        color: ZienaColors.primary, letterSpacing: 1.5,
                      ))),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('code_copied'.tr()),
                        backgroundColor: ZienaColors.success,
                        duration: const Duration(seconds: 2),
                      ));
                    },
                    child: const Icon(Icons.copy_rounded,
                        color: ZienaColors.primary, size: 20),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 8, color: iconColor),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
          style: const TextStyle(
              fontSize: 13, color: ZienaColors.textPrimary))),
    ]);
  }
}