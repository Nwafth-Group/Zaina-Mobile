import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/features/auth/data/models/verification_model.dart';
import 'package:zeina/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:zeina/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:zeina/features/auth/presentation/screens/verification_submitted.dart';
import '../../../../core/theme/theme.dart';
import '../cubit/verification_cubit.dart';
import '../widgets/step_id_upload.dart';
import '../widgets/step_review.dart';
import '../widgets/step_selfie.dart';
import 'verification_pending_screen.dart';
import 'verification_rejected_screen.dart';

class VerificationFlowScreen extends StatefulWidget {
  final VoidCallback onVerified;
  final bool fromSplash;
  final String? initialStatus; // 'pending', 'rejected', or null for new

  const VerificationFlowScreen({
    super.key,
    required this.onVerified,
    this.initialStatus, this.fromSplash = true,
  });

  @override
  State<VerificationFlowScreen> createState() =>
      _VerificationFlowScreenState();
}

class _VerificationFlowScreenState extends State<VerificationFlowScreen> {
  final PageController _ctrl = PageController();
  int _step = 0;
  String? _currentStatus;

  // shared across steps
  File? _frontId;
  File? _backId;
  File? _selfie;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.initialStatus;
    if (_currentStatus == null) {
      // Add a small delay to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkCurrentStatus();
      });
    }
  }

  Future<void> _checkCurrentStatus() async {
    try {
      if (!mounted) return;

      final profileCubit = context.read<ProfileCubit>();
      final profile = await profileCubit.fetchProfile();

      if (!mounted) return;

      setState(() {
        _currentStatus = (profile?.verificationStatus ?? VerificationStatus.pending).name;
      });

      if (_currentStatus == 'approved' && mounted) {
        widget.onVerified();
      }
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  void _goNext() {
    if (_step < 2) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step++);
    }
  }

  void _goBack() {
    if(widget.fromSplash){
      context.read<AuthCubit>().logout();
      AppNavigator.pushAndRemoveUntil(PhoneAuthScreen());
    } else if (_step > 0) {
      _ctrl.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    if (_frontId == null || _backId == null || _selfie == null) return;
    context.read<VerificationCubit>().submitVerification(
      frontId: _frontId!,
      backId:  _backId!,
      selfie:  _selfie!,
    );
  }

  static const _stepLabels = ['ID Upload', 'Selfie', 'Review'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerificationCubit, VerificationState>(
      listener: (context, state) {
        if (state is VerificationSuccess) {
          AppNavigator.pushAndRemoveUntil(VerificationSubmittedScreen(onContinue: () {
            context.read<AuthCubit>().logout();
            AppNavigator.pushAndRemoveUntil(PhoneAuthScreen());
          },));
        }
        if (state is VerificationError) {
          setState(() {
            _errorMessage = state.message;
          });
          _showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: _getBodyWidget(),
        ),
      ),
    );
  }

  Widget _getBodyWidget() {
    if (_currentStatus == 'pending') {
      return VerificationPendingScreen(
        onStatusChecked: (status) {
          if (status == 'approved') {
            widget.onVerified();
          }
        },
      );
    }

    if (_currentStatus == 'rejected') {
      return VerificationRejectedScreen(
        fromSplash: widget.fromSplash,
        onRetry: () {
          setState(() {
            _currentStatus = null;
            _frontId = null;
            _backId = null;
            _selfie = null;
            _step = 0;
          });
        },
      );
    }

    return _buildVerificationFlow();
  }

  Widget _buildVerificationFlow() {
    return Column(children: [
      // ── Top bar with step indicator ──────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          GestureDetector(
            onTap: _goBack,
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(child: _StepIndicator(
            currentStep: _step,
            labels: _stepLabels,
          )),
        ]),
      ),
      const SizedBox(height: 8),

      // ── Page content ─────────────────────────────────────────────
      Expanded(
        child: PageView(
          controller: _ctrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Step 0 — ID Upload
            StepIdUpload(
              frontId: _frontId,
              backId:  _backId,
              onFrontPicked: (f) => setState(() => _frontId = f),
              onBackPicked:  (f) => setState(() => _backId  = f),
              onNext: (_frontId != null && _backId != null)
                  ? _goNext
                  : null,
            ),
            // Step 1 — Selfie
            StepSelfie(
              selfie: _selfie,
              onSelfiePicked: (f) => setState(() => _selfie = f),
              onNext: _selfie != null ? _goNext : null,
            ),
            // Step 2 — Review
            StepReview(
              frontId: _frontId,
              backId:  _backId,
              selfie:  _selfie,
              onSubmit: (_frontId != null &&
                  _backId  != null &&
                  _selfie  != null)
                  ? _submit
                  : null,
            ),
          ],
        ),
      ),
    ]);
  }



  void _startPollingStatus() {
    int attempts = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      attempts++;
      await _checkCurrentStatus();
      return _currentStatus == 'pending' && attempts < 20; // Poll for up to 1 minute
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('verification_failed'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('try_again'.tr()),
          ),
        ],
      ),
    );
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;

  const _StepIndicator({
    required this.currentStep,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final done   = i < currentStep;
        final active = i == currentStep;
        final isLast = i == labels.length - 1;

        return Expanded(
          child: Row(children: [
            if (i > 0)
              Expanded(child: Container(
                height: 2,
                color: done || active
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
              )),
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active || done
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
              ),
            ),
            if (!isLast)
              Expanded(child: Container(
                height: 2,
                color: done
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
              )),
          ]),
        );
      }),
    );
  }
}