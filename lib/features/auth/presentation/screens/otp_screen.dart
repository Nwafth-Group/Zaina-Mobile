import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/features/auth/presentation/screens/verification_welcome_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../main_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/verification_cubit.dart';

class OtpScreen extends StatefulWidget {
  static const String routeName = '/otp';
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final PinInputController _otpController = PinInputController();
  String _otp = '';
  int _secondsRemaining = 57;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 57);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _timerText {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _onSubmit() {
    if (_otp.length == 6) {
      context.read<AuthCubit>().verifyOtp(widget.mobileNumber, _otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        print(state);
        // In otp_screen.dart BlocListener:
        if (state is OtpVerifySuccess) {

          if (state.needsVerification) {
            // Route to verification welcome
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => sl<VerificationCubit>(),
                  child: VerificationWelcomeScreen(
                    onVerified: () {
                      // After verification submitted → go to home
                      AppNavigator.pushAndRemoveUntil(MainScreen());

                    },
                  ),
                ),
              ),
                  (route) => false,
            );
          } else {
            AppNavigator.pushAndRemoveUntil(MainScreen());
          }
        }

      },
      child: Scaffold(
        
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'verification_code'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: '${'verification_code_hint'.tr()} ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                    children: [
                      TextSpan(
                        text: widget.mobileNumber,
                        style: const TextStyle(
                          color: ZienaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // PIN Code Fields
                PinInput(
                  length: 6,
                  pinController: _otpController,
                  onChanged: (val) => _otp = val,
                  onCompleted: (val) => _otp = val,
                  keyboardType: TextInputType.number, builder: (context, cells) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: cells.map((cell) {
                      return Container(
                        width: 45,
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: cell.isFocused ? ZienaColors.bg3 : Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            cell.character ?? '',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                ),
                const SizedBox(height: 16),
                // Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'code_sent'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    if (_secondsRemaining > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ZienaColors.bg2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _timerText,
                          style: const TextStyle(
                            
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZienaColors.primary,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          _startTimer();
                          context.read<AuthCubit>().sendOtp(widget.mobileNumber);
                        },
                        child: Text(
                          'resend'.tr(),
                          style: TextStyle(
                            
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ZienaColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => ZienaButton(
                    text: 'submit'.tr(),
                    onTap: _onSubmit,
                    isLoading: state is AuthLoading,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
