import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/app_toast.dart';
import '../../../../widgets/custom_icon.dart';

/// Shows an error to the user, picking the presentation by whether there's
/// something for them to do about it:
/// - With an action ([actionLabel] + [onAction], e.g. "Add address"): a
///   bottom sheet with the message, the action button and Cancel — same
///   style as the app's other bottom sheets.
/// - Without an action: a light, self-dismissing toast (per Figma), so the
///   user isn't forced to close a dialog manually.
Future<void> showCoverageErrorDialog(
    BuildContext context, {
      required String message,
      String? actionLabel,
      VoidCallback? onAction,
    }) async {
  if (actionLabel == null || onAction == null) {
    AppToast.showError(context, message);
    return;
  }

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        decoration: const BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ZienaColors.greyBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const AppIcon(
                HugeIcons.strokeRoundedLocationOffline01,
                color: ZienaColors.primary,
                size: 30,
                width: 1.5,
              ),
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
