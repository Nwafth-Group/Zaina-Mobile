import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../cubit/verification_cubit.dart';

class StepReview extends StatelessWidget {
  final File? frontId;
  final File? backId;
  final File? selfie;
  final VoidCallback? onSubmit;

  const StepReview({
    super.key,
    required this.frontId,
    required this.backId,
    required this.selfie,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Title
        Center(
          child: Text('review_your_info'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                 fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('confirm_before_submit'.tr(),
              textAlign: TextAlign.center,
          
              style: const TextStyle(
                 fontSize: 14,
                color: ZienaColors.textSecondary,
              )),
        ),
        const SizedBox(height: 28),

        // ID Information
        _sectionTitle('id_information'.tr()),
        const SizedBox(height: 12),
        _ReviewImageRow(
            label: 'front_side'.tr(), file: frontId),
        const SizedBox(height: 10),
        _ReviewImageRow(
            label: 'back_side'.tr(),  file: backId),
        const SizedBox(height: 24),

        // Selfie
        _sectionTitle('selfie'.tr()),
        const SizedBox(height: 12),
        if (selfie != null)
        _ReviewImageRow(
            label: 'selfie'.tr(), file: selfie),

        const SizedBox(height: 36),

        BlocBuilder<VerificationCubit, VerificationState>(
          builder: (_, state) {
            final loading = state is VerificationLoading;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZienaColors.primary,
                  disabledBackgroundColor:
                  ZienaColors.primary.withOpacity(0.35),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : Text('submit'.tr(),
                    style: const TextStyle(
                       fontSize: 16,
                      fontWeight: FontWeight.w600, color: Colors.white,
                    )),
              ),
            );
          },
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Row(
    children: [
      Text(t,
          style: const TextStyle(
             fontSize: 15,
            fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
          )),
    ],
  );
}

class _ReviewImageRow extends StatelessWidget {
  final String label;
  final File? file;
  const _ReviewImageRow({required this.label, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: file != null
              ? Image.file(file!,
              width: 72, height: 48, fit: BoxFit.cover)
              : Container(
              width: 72, height: 48,
              color: ZienaColors.bg3,
              child: const Icon(Icons.image_outlined,
                  color: ZienaColors.textHint, size: 24)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label,
            style: const TextStyle(
               fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ))),
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: ZienaColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check,
              color: ZienaColors.success, size: 16),
        ),
      ]),
    );
  }
}