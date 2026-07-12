
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/theme/theme.dart';

/// A compact button variant — fixed 12px text and 14 border radius by
/// default (unlike ZienaButton/ZienaButton2, which use 15-16px text).
/// Use for secondary actions like booking-detail action bars where a
/// smaller, tighter button reads better than the full-size ones.
class ZienaSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final Widget? prefixIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;

  const ZienaSmallButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.prefixIcon,
    this.width,
    this.height = 40,
    this.borderRadius = 14,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: textColor ?? ZienaColors.primary,
          side: BorderSide(color: textColor ?? ZienaColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _buildChild(),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ZienaColors.primary,
          disabledBackgroundColor:
          disabledBackgroundColor ?? ZienaColors.greyBorder,
          foregroundColor: textColor ?? ZienaColors.white,
          disabledForegroundColor: disabledTextColor ?? ZienaColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    final fg = isOutlined
        ? (textColor ?? ZienaColors.primary)
        : (textColor ?? ZienaColors.white);

    if (isLoading) {
      return SpinKitThreeBounce(color: fg, size: 16);
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    );
  }
}