import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/auth/presentation/screens/verification_flow_screen.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../cubit/verification_cubit.dart';

class VerificationWelcomeScreen extends StatelessWidget {
  /// Called when user taps "Continue" after successful submission
  final VoidCallback onVerified;

  const VerificationWelcomeScreen({super.key, required this.onVerified});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // ── Illustration ───────────────────────────────────────────────
              SizedBox(
                height: 260,
                child: Stack(alignment: Alignment.center, children: [

                  // Shield icon
                  ImageAsset('assets/images/welcome.png', width:200, height: 200, fit: BoxFit.cover,)
                ]),
              ),

              const SizedBox(height: 36),

              Text('welcome_to_ziena'.tr(),
                  style: const TextStyle(
                     fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('verify_identity_desc'.tr(),
                  style: const TextStyle(
                     fontSize: 14,
                    color: ZienaColors.textSecondary, height: 1.6,
                  ),
                  textAlign: TextAlign.center),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VerificationFlowScreen(
                        fromSplash: false,
                          onVerified: onVerified),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZienaColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('start_verification'.tr(),
                      style: const TextStyle(
                         fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white,
                      )),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}