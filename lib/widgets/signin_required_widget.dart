import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
            // Icon container
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _tabIcon(tabKey),
                  size: 50,
                  color: ZienaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'signin_required_title'.tr(),
              style: const TextStyle(
                fontFamily: 'Poppins',
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
                fontFamily: 'Poppins',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<AuthCubit>(),
                        child: const PhoneAuthScreen(),
                      ),
                    ),
                  );
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
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Continue as guest
            TextButton(
              onPressed: () {},
              child: Text(
                'continue_guest'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ZienaColors.textSecondary,
                  decoration: TextDecoration.underline,
                  decorationColor: ZienaColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _tabIcon(String tab) {
    switch (tab) {
      case 'bookings':
        return Icons.calendar_month_rounded;
      case 'wallet':
        return Icons.wallet_rounded;
      case 'more':
        return Icons.grid_view_rounded;
      default:
        return Icons.lock_outline_rounded;
    }
  }
}