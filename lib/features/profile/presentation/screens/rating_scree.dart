import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/success_dialog.dart';
import '../../../../widgets/ziena_button.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _rating = 0;
  bool _submitting = false;

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
        title: Text('rating'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(children: [
          const Spacer(),

          // ── Illustration ─────────────────────────────────────────────────
          ImageAsset(
            'assets/images/rate.png',
            height: 220,
            width: 220,
          ),
          const SizedBox(height: 28),

          Text('opinion_matters'.tr(),
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('rate_app_desc'.tr(),
              style: const TextStyle(
                  fontSize: 14, color: ZienaColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),

          // ── Stars ─────────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 38,
                    color: filled
                        ? const Color(0xFFFFB800)
                        : ZienaColors.greyBorder,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 32),

          ZienaButton(
            text: 'submit'.tr(),
            isLoading: _submitting,
            onTap: _rating > 0
                ? () async {
              setState(() => _submitting = true);
              await Future.delayed(const Duration(milliseconds: 800));
              if (!mounted) return;
              setState(() => _submitting = false);
              showDialog(
                context: context,
                builder: (_) => SuccessDialog(
                  title: 'thank_you'.tr(),
                  message: 'rating_submitted'.tr(),
                  buttonText: 'done'.tr(),
                  onButtonTap: () {
                    Navigator.pop(context); // dialog
                    Navigator.pop(context); // screen
                  },
                ),
              );
            }
                : null,
          ),
          const Spacer(),
        ]),
      ),
    );
  }
}

