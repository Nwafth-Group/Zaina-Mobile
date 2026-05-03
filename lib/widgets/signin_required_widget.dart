import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina_app/core/utils/app_navigator.dart';
import '../../../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../../../injection_container.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/theme.dart';

class SignInRequiredWidget extends StatelessWidget {
  final String tabKey; // e.g. 'bookings', 'wallet', 'more'

  const SignInRequiredWidget({super.key, required this.tabKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Image.asset(
              'assets/images/signin_required.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 28),

            Text(
              'signin_required_title'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            Text(
              'signin_required_desc_$tabKey'.tr(),
              style: const TextStyle(
                fontSize: 14,
                color: ZienaColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // Sign In button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppNavigator.pushAndRemoveUntil(PhoneAuthScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZienaColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'log_in'.tr(),
                  style: const TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}