import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import '../../../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../../../widgets/ziena_button.dart';

import '../core/theme/theme.dart';
import '../core/utils/app_navigator.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';

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
            ZienaButton(
              text: 'log_in'.tr(),
              onTap: () {
                if(SharedPrefHelper.getToken() != null) {
                  context.read<AuthCubit>().logout();
                }
                AppNavigator.pushAndRemoveUntil(PhoneAuthScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
