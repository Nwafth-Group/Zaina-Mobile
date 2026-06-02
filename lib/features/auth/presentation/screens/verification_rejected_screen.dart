import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/auth/presentation/cubit/verification_cubit.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_icon.dart';

class VerificationRejectedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final bool fromSplash;

  const VerificationRejectedScreen({
    super.key,
    required this.onRetry,
    this.fromSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            if(!fromSplash)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Error icon
                      ImageAsset(
                        'assets/images/rejected.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'verification_rejected_title'.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        'verification_rejected_desc'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ZienaColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Tips section (from Figma)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ZienaColors.bg1,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ZienaColors.greyBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'tips_for_better_photos'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ZienaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, state) {
                                return _buildTip(
                                  icon: Icons.high_quality,
                                  text: context.read<ProfileCubit>().profile?.rejectionReason??'',
                                );
                              }
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Try again button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZienaColors.primary,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'try_again'.tr(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: ZienaColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: ZienaColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}