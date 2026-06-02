import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/auth/data/models/verification_model.dart';
import 'package:zeina/features/auth/presentation/cubit/verification_cubit.dart';
import 'package:zeina/features/auth/presentation/screens/verification_flow_screen.dart';
import 'package:zeina/features/main_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_logo.dart';
import '../screens/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.elasticOut)),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), ()async {
        String? token = SharedPrefHelper.getToken();
        if (mounted) {
          if(token == null) {AppNavigator.pushAndRemoveUntil(LanguageSelectionScreen());}
          else{checkProfileStatus();}
        }
      });
    });
  }

  // In your splash screen
  void checkProfileStatus() async {
    try {
      final profile = await context.read<ProfileCubit>().fetchProfile();
      final status = profile?.verificationStatus; // Assuming profile has a 'status' field

      switch (status) {
        case VerificationStatus.verified:
        // User is verified, go to main screen
          AppNavigator.pushAndRemoveUntil(MainScreen());
          break;

        case VerificationStatus.pending:
        // User submitted verification, waiting for approval
          AppNavigator.pushAndRemoveUntil(
              VerificationFlowScreen(
                initialStatus: 'pending',
                onVerified: () {
                  AppNavigator.pushAndRemoveUntil(MainScreen());
                },
              )
          );
          break;

        case VerificationStatus.rejected:
        // User was rejected, need to re-verify
          AppNavigator.pushAndRemoveUntil(
              VerificationFlowScreen(
                initialStatus: 'rejected',
                onVerified: () {
                  // After re-submitting verification
                  AppNavigator.pushAndRemoveUntil(MainScreen());
                },
              )
          );
          break;

        case VerificationStatus.unverified:
        default:
        // New user, need to verify
          AppNavigator.pushAndRemoveUntil(
              VerificationFlowScreen(
                onVerified: () {
                  AppNavigator.pushAndRemoveUntil(MainScreen());
                },
              )
          );
          break;
      }
    } catch (e) {
      // Handle error - maybe show error screen or retry
      print('Error fetching profile: $e');
      // Default to verification flow
      AppNavigator.pushAndRemoveUntil(
          VerificationFlowScreen(
            onVerified: () {
              AppNavigator.pushAndRemoveUntil(MainScreen());
            },
          )
      );
    }
  }

  Future<void> _checkAndNavigateAfterVerification() async {
    // Wait a bit for the status to update
    await Future.delayed(const Duration(seconds: 2));

    try {
      final profile = await context.read<ProfileCubit>().fetchProfile();
      if (profile?.verificationStatus == VerificationStatus.approved) {
        AppNavigator.pushAndRemoveUntil(MainScreen());
      } else {
        // Still pending or other status, stay on verification screen
        // The VerificationFlowScreen will show appropriate message
      }
    } catch (e) {
      print('Error checking verification status: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ZienaColors.splashGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const ZienaLogo(
                  size: 120,
                  showText: true,
                  onDark: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
