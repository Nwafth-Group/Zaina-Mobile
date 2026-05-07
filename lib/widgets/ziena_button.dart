import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../core/theme/theme.dart';

class ZienaButton extends StatelessWidget {
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

  const ZienaButton({
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
