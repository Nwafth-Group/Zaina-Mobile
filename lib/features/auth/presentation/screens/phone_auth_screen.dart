import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
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
  String _completePhone = '';
  bool _agreeTerms = false;

  void _onLogin() {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('err_agree_terms'.tr()),
          backgroundColor: ZienaColors.primaryDark,
        ),
      );
      return;
    }
    if (_completePhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('err_enter_phone'.tr()),
          backgroundColor: ZienaColors.primaryDark,
        ),
      );
      return;
    }
    context.read<AuthCubit>().sendOtp(_completePhone);
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
                  IntlPhoneField(
                    decoration: InputDecoration(
                      hintText: '10 1234 5678',
                      filled: true,
                      fillColor: ZienaColors.bg1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: ZienaColors.greyBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: ZienaColors.greyBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: ZienaColors.primary, width: 1.5),
                      ),
                      counterText: '',
                    ),
                    initialCountryCode: 'EG',
                    onChanged: (phone) {
                      // Build E.164 format: +{countryCode}{national number without leading 0}
                      // final national = phone.number.replaceFirst(RegExp(r'^0+'), '');
                      // _completePhone = '${phone.countryCode}$national';
                      _completePhone = phone.completeNumber;
                    },
                    flagsButtonPadding: const EdgeInsets.only(left: 12),
                    dropdownIconPosition: IconPosition.trailing,
                    dropdownIcon: const Icon(Icons.keyboard_arrow_down, color: ZienaColors.textSecondary),
                    style: const TextStyle(
                      
                      fontSize: 15,
                      color: ZienaColors.textPrimary,
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

