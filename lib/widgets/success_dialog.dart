
// ── Reusable success dialog ───────────────────────────────────────────────────
import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import 'ziena_button.dart';

class SuccessDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const SuccessDialog({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ZienaColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 110, height: 110,
            decoration: const BoxDecoration(
                color: ZienaColors.bg2, shape: BoxShape.circle),
            child: Stack(alignment: Alignment.center, children: [
              Icon(icon, size: 55, color: ZienaColors.primary),
              Positioned(
                bottom: 10, right: 10,
                child: Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: ZienaColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle( fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle( fontSize: 13,
                color: ZienaColors.textSecondary, height: 1.5,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ZienaButton(
            text: 'Done!',
            onTap: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}