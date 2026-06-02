import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../main_screen.dart';

class SuccessScreen extends StatefulWidget {
  static const String routeName = '/success';
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 1, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Celebration illustration
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: ZienaColors.bg2,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset('assets/images/success.png', height: 180,),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'success_title'.tr(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: ZienaColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'success_message'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ZienaColors.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ZienaButton(
                text: 'done'.tr(),
                onTap: () {
                  // Navigate to home screen
                  AppNavigator.pushAndRemoveUntil(MainScreen());
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
