import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'ziena_button.dart';
import '../core/theme/theme.dart';

class EmptyDataWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final double imageWidth;
  final double imageHeight;

  const EmptyDataWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.showRetryButton = false,
    this.imageWidth = 160,
    this.imageHeight = 160,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Data Image
            Image.asset(
              'assets/images/empty_data.png',
              width: imageWidth,
              height: imageHeight,
            ),
            const SizedBox(height: 28),

            // Title
            if (title != null)
              Text(
                title!.tr(),
                style: const TextStyle(
                  
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            if (title != null) const SizedBox(height: 10),

            // Message
            if (message != null)
              Text(
                message!.tr(),
                style: const TextStyle(
                  
                  fontSize: 14,
                  color: ZienaColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            if (message != null) const SizedBox(height: 36),

            // Retry Button (optional)
            if (showRetryButton && onRetry != null)
              SizedBox(
                width: double.infinity,
                child: ZienaButton(
                  text: 'retry'.tr(),
                  onTap: onRetry,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
