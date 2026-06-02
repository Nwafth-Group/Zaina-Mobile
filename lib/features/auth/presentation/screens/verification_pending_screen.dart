import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/auth/data/models/verification_model.dart';
import 'package:zeina/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:zeina/widgets/custom_icon.dart';
import 'package:zeina/widgets/ziena_button.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/app_navigator.dart';
import '../../../../core/utils/shared_pref_helper.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/verification_cubit.dart';

class VerificationPendingScreen extends StatefulWidget {
  final Function(String status) onStatusChecked;

  const VerificationPendingScreen({
    super.key,
    required this.onStatusChecked,
  });

  @override
  State<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends State<VerificationPendingScreen> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 5 seconds to check status
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        await _checkStatus();
      }
      return mounted; // Continue while widget is mounted
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final profile = await context.read<ProfileCubit>().fetchProfile();
      if (profile?.verificationStatus == VerificationStatus.approved) {
        widget.onStatusChecked('approved');
      } else if (profile?.verificationStatus == VerificationStatus.rejected) {
        widget.onStatusChecked('rejected');
      }
    } catch (e) {
      print('Error checking status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hourglass/Clock animation
                ImageAsset(
                  'assets/images/under_review.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'verification_pending_title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'verification_pending_desc'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZienaColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

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
                    children: [Text(
                      'takes24'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: ZienaColors.textSecondary,
                      ),
                    )],
                  ),
                ),
                const SizedBox(height: 24),

                // Manual refresh button
                TextButton.icon(
                  onPressed: _checkStatus,
                  icon: Icon(
                    _isChecking ? Icons.hourglass_top : Icons.refresh,
                    color: ZienaColors.primary,
                    size: 18,
                  ),
                  label: Text(
                    'check_status_manually'.tr(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: ZienaColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                ZienaButton(text: 'logout'.tr(), onTap: () async {
                  await SharedPrefHelper.logout();
                  AppNavigator.pushAndRemoveUntil(PhoneAuthScreen());
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}