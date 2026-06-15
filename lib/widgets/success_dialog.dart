
// ── Reusable success dialog ───────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import 'ziena_button.dart';

import 'package:flutter/material.dart';
import '../core/theme/theme.dart';
import 'ziena_button.dart';

class SuccessDialog extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset; // Accepts a custom vector/image asset path
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonTap;

  const SuccessDialog({
    super.key,
    this.icon,
    this.imageAsset,
    required this.title,
    required this.message,
    this.buttonText = 'Done!',
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ZienaColors.bg1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamic Header Graphic: Image Asset vs Icon
            _buildHeaderGraphic(),
            const SizedBox(height: 28),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),

            // Message / Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF4A4A4A),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Styled Primary Button
            ZienaButton(
              text: buttonText,
              onTap: onButtonTap ?? () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderGraphic() {
    // 1. Exact Map/Asset Image variant layout match
    if (imageAsset != null) {
      return SizedBox(
        width: 220,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding around vector map
          child: Image.asset(
            imageAsset!,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // 2. Fallback Classic Icon Layout variant match
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        color: ZienaColors.bg2,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon ?? Icons.check_circle_outline_rounded, size: 55, color: ZienaColors.primary),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: ZienaColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}