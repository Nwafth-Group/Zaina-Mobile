
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// Shows a simple error dialog with an icon, message, and optional action
/// button (used for "add address" / "change location" follow-ups).
Future<void> showCoverageErrorDialog(
    BuildContext context, {
      required String message,
      String? actionLabel,
      VoidCallback? onAction,
    }) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined,
                  color: ZienaColors.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    onAction();
                  },
                  child: Text(actionLabel),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('cancel'.tr()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}