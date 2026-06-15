import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';

class StepSelfie extends StatelessWidget {
  final File? selfie;
  final ValueChanged<File> onSelfiePicked;
  final VoidCallback? onNext;

  const StepSelfie({
    super.key,
    required this.selfie,
    required this.onSelfiePicked,
    required this.onNext,
  });

  Future<void> _takeSelfie(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 85);
    if (picked != null) onSelfiePicked(File(picked.path));
  }

  static const _tips = [
    'selfie_tip_face',
    'selfie_tip_lighting',
    'selfie_tip_no_glasses',
  ];

  @override
  Widget build(BuildContext context) {
    final hasSelfie = selfie != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        Center(
          child: Text('take_a_selfie'.tr(),
              style: const TextStyle(
                 fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('take_selfie_desc'.tr(),
              style: const TextStyle(
                 fontSize: 14,
                color: ZienaColors.textSecondary,
              )),
        ),
        const SizedBox(height: 32),

        // Selfie preview / placeholder
        Center(
          child: GestureDetector(
            onTap: () => _takeSelfie(context),
            child: hasSelfie
                ? ClipOval(
              child: Image.file(
                selfie!,
                width: 200, height: 200,
                fit: BoxFit.cover,
              ),
            )
                : ImageAsset('assets/images/selfie.png', height: 200, width: 200)
          ),
        ),

        if (hasSelfie) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => _takeSelfie(context),
              icon: const Icon(Icons.refresh_rounded,
                  color: ZienaColors.primary, size: 16),
              label: Text('retake'.tr(),
                  style: const TextStyle(
                     fontSize: 13,
                    color: ZienaColors.primary,
                    fontWeight: FontWeight.w500,
                  )),
            ),
          ),
        ],

        const SizedBox(height: 28),

        // Tips
        ..._tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ImageAsset('assets/images/point.png', height: 20, width: 20,),
            const SizedBox(width: 10),
            Expanded(child: Text(tip.tr(),
                style: const TextStyle(
                   fontSize: 13,
                  color: ZienaColors.textSecondary,
                ))),
          ]),
        )),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.primary,
              disabledBackgroundColor:
              ZienaColors.primary.withOpacity(0.35),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('continue'.tr(),
                style: const TextStyle(
                   fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white,
                )),
          ),
        ),
      ]),
    );
  }
}