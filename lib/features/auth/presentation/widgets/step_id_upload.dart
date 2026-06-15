import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import 'dotted_border.dart';

class StepIdUpload extends StatelessWidget {
  final File? frontId;
  final File? backId;
  final ValueChanged<File> onFrontPicked;
  final ValueChanged<File> onBackPicked;
  final VoidCallback? onNext;

  const StepIdUpload({
    super.key,
    required this.frontId,
    required this.backId,
    required this.onFrontPicked,
    required this.onBackPicked,
    required this.onNext,
  });

  Future<void> _pick(
      BuildContext context, ValueChanged<File> onPicked) async {
    final source = await _showSourceDialog(context);
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: source, imageQuality: 85);
    if (picked != null) onPicked(File(picked.path));
  }

  Future<ImageSource?> _showSourceDialog(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded,
                color: ZienaColors.primary),
            title: Text('camera'.tr(),
                style: const TextStyle(fontFamily: 'Poppins')),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded,
                color: ZienaColors.primary),
            title: Text('gallery'.tr(),
                style: const TextStyle(fontFamily: 'Poppins')),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title
        Center(
          child: Text('verify_your_identity'.tr(),
              style: const TextStyle(
                 fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text('upload_clear_id'.tr(),
              style: const TextStyle(
                 fontSize: 14,
                color: ZienaColors.textSecondary,
              )),
        ),
        const SizedBox(height: 28),

        // Front side
        Text('front_side'.tr(),
            style: const TextStyle(
               fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            )),
        const SizedBox(height: 10),
        _ImageUploadBox(
          file: frontId,
          onTap: () => _pick(context, onFrontPicked),
          label: 'upload_front_side'.tr(),
        ),
        const SizedBox(height: 20),

        // Back side
        Text('back_side'.tr(),
            style: const TextStyle(
               fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            )),
        const SizedBox(height: 10),
        _ImageUploadBox(
          file: backId,
          onTap: () => _pick(context, onBackPicked),
          label: 'upload_back_side'.tr(),
        ),
        const SizedBox(height: 16),

        // Hint
        Text('id_hint'.tr(),
            style: const TextStyle(
               fontSize: 11,
              color: ZienaColors.textHint,
            )),
        const SizedBox(height: 32),

        // Continue
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

// ── Upload box ────────────────────────────────────────────────────────────────
class _ImageUploadBox extends StatelessWidget {
  final File? file;
  final VoidCallback onTap;
  final String label;

  const _ImageUploadBox({
    required this.file,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: ZienaColors.primary,
          radius: 16,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: hasFile ? 180 : 120,
          decoration: BoxDecoration(
            color: hasFile ? ZienaColors.bg1 : ZienaColors.bg2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasFile
                  ? ZienaColors.primary
                  : ZienaColors.greyBorder,
              width: hasFile ? 1.5 : 1,
              style: hasFile ? BorderStyle.solid : BorderStyle.solid,
            ),
          ),
          child: hasFile
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  file!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              // Uploaded badge
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ZienaColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle_rounded,
                        color: ZienaColors.success, size: 14),
                    const SizedBox(width: 5),
                    Text('id_uploaded'.tr(),
                        style: const TextStyle(
                           fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ZienaColors.textPrimary,
                        )),
                  ]),
                ),
              ),
              // Re-upload icon
              Positioned(
                top: 10, right: 10,
                child: ImageAsset('assets/images/upload.png', height: 20, width: 20,)
              ),
            ],
          )
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                ImageAsset('assets/images/upload_id.png', height: 60, width: 60,),
                const SizedBox(width: 30),
                Text(label,
                    style: const TextStyle(
                       fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ZienaColors.textPrimary,
                    )),
                            ],
                          ),
              ),
        ),
      ),
    );
  }
}