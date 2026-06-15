import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/theme/theme.dart';

class ZienaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final Widget? prefixIcon;
  final double? width;
  final double height;
  final double borderRadius;

  const ZienaButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.prefixIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? ZienaColors.primary;
    final disabledBg = disabledBackgroundColor ?? ZienaColors.greyBorder;
    final fg = textColor ?? ZienaColors.white;
    final disabledFg = disabledTextColor ?? ZienaColors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? disabledBg : bg,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? disabledFg : fg,
          ),
          overlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
          elevation: WidgetStateProperty.all(0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        child: _buildChild(fg),
      ),
    );
  }

  Widget _buildChild(Color fg) {
    if (isLoading) {
      return SpinKitThreeBounce(color: fg, size: 20);
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor ?? ZienaColors.white,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? ZienaColors.white,
      ),
    );
  }
}

class ZienaSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? prefixIcon;
  final double? width;
  final double height;
  final double borderRadius;

  const ZienaSecondaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            backgroundColor ?? ZienaColors.bg3,
          ),
          foregroundColor: WidgetStateProperty.all(ZienaColors.primary),
          overlayColor: WidgetStateProperty.all(
            ZienaColors.primary.withValues(alpha: 0.06),
          ),
          elevation: WidgetStateProperty.all(0),
          side: WidgetStateProperty.all(
            const BorderSide(color: ZienaColors.primary),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SpinKitThreeBounce(color: ZienaColors.primary, size: 20);
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor ?? ZienaColors.primary,
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? ZienaColors.primary,
      ),
    );
  }
}

class ZienaButton2 extends StatelessWidget {
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

  const ZienaButton2({
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
    this.height = 52,
    this.borderRadius = 14,
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
          foregroundColor: textColor ?? ZienaColors.textPrimary,
          side: BorderSide(color: ZienaColors.greyBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: _buildChild(),
      )
          : ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? ZienaColors.primary,
          disabledBackgroundColor: disabledBackgroundColor ??
              (isOutlined ? Colors.transparent : ZienaColors.greyBorder),
          foregroundColor: textColor ?? ZienaColors.white,
          disabledForegroundColor: disabledTextColor ??
              (isOutlined ? ZienaColors.textPrimary : ZienaColors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: _buildChild(),
      ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return SpinKitThreeBounce(
        color: isOutlined ? ZienaColors.primary : ZienaColors.white,
        size: 20,
      );
    }
    if (prefixIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixIcon!,
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(

              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor ?? (isOutlined ? ZienaColors.textPrimary : ZienaColors.white),
            ),
          ),
        ],
      );
    }
    return Text(
      text,
      style: TextStyle(

        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? (isOutlined ? ZienaColors.textPrimary : ZienaColors.white),
      ),
    );
  }
}


