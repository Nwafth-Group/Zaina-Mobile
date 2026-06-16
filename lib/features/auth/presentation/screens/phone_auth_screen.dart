import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../../widgets/ziena_logo.dart';
import '../../../main_screen.dart';
import '../../../profile/presentation/screens/terms_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/verification_cubit.dart';
import 'otp_screen.dart';


class PhoneAuthScreen extends StatefulWidget {
  static const String routeName = '/phone-auth';
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  bool _agreeTerms = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('err_agree_terms'.tr()),
          backgroundColor: ZienaColors.primaryDark,
        ),
      );
      return;
    }
    final number = _phoneCtrl.text.trim();
    // Strip leading zero then prepend +20
    final digits =  number;
    // final digits = number.startsWith('0') ? number.substring(1) : number;
    final completePhone = '+20$digits';
    context.read<AuthCubit>().sendOtp(completePhone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSentSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<AuthCubit>()),
                  BlocProvider(create: (_) => sl<ProfileCubit>()),
                ],
                child: OtpScreen(mobileNumber: state.mobileNumber),
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: ZienaColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(child: ZienaLogo(size: 140)),
                  const SizedBox(height: 40),
                  Text(
                    'enter_phone'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'enter_phone_hint'.tr(),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'phone_number'.tr(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _phoneCtrl,
                    hintText: '10 1234 5678',
                    keyboardType: TextInputType.phone,
                    fillColor: ZienaColors.bg1,
                    borderColor: ZienaColors.primary,
                    borderRadius: 14,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'err_enter_phone'.tr();
                      final digits = v.trim().replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 7) return 'invalid_phone'.tr();
                      return null;
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                          ClipOval(
                            child: Image.asset('assets/images/eg.png', width: 24, height: 24, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 6),
                          const Text('+20',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: ZienaColors.textPrimary,
                              )),
                        ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Terms checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _agreeTerms ? ZienaColors.primary : Colors.transparent,
                            border: Border.all(
                              color: _agreeTerms ? ZienaColors.primary : ZienaColors.greyBorder,
                              width: 1.5,
                            ),
                          ),
                          child: _agreeTerms
                              ? const Icon(Icons.check, color: Colors.white, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TermsScreen()),
                            );
                          },
                          child: Text(
                            'agree_terms'.tr(),
                            style: const TextStyle(
                              
                              fontSize: 13,
                              color: ZienaColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return ZienaButton(
                        text: 'log_in'.tr(),
                        onTap: _onLogin,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Divider with text
                  Row(
                    children: [
                      const Expanded(child: Divider(color: ZienaColors.greyBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or_continue_with'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ),
                      const Expanded(child: Divider(color: ZienaColors.greyBorder)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Social buttons
                  ZienaButton2(
                    text: 'continue_google'.tr(),
                    isOutlined: true,
                    onTap: () {},
                    prefixIcon: SizedBox(
                      width: 18,
                      height: 18,
                      child: const ImageAsset('assets/images/google.png'),
                    ),
                  ),
                  if(Platform.isIOS)...[
                    const SizedBox(height: 12),
                    ZienaButton2(
                      text: 'continue_apple'.tr(),
                      isOutlined: true,
                      onTap: () {},
                      prefixIcon: const Icon(Icons.apple, size: 28, color: ZienaColors.textPrimary),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ZienaButton(
                    text: 'continue_guest'.tr(),
                    backgroundColor: ZienaColors.bg3,
                    textColor: ZienaColors.primaryDark,
                    onTap: () {
                      AppNavigator.pushAndRemoveUntil(MainScreen());
                    },
                    prefixIcon: SizedBox(
                      width: 22,
                      height: 22,
                      child: const ImageAsset('assets/images/guest.png'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

