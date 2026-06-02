import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';

class VerificationSubmittedScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const VerificationSubmittedScreen({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Spacer(),

              // Illustration
              ImageAsset(
                'assets/images/submitted.png',
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 28),

              Text(
                'verification_submitted'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'verification_submitted_desc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: ZienaColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ZienaColors.greyBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      size: 20,
                      color: ZienaColors.primary,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'verification_notify_hint'.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: ZienaColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZienaColors.primary,
                    elevation: 0,
                    minimumSize: const Size(
                      double.infinity,
                      56,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'continue'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}