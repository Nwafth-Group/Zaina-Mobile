import 'package:flutter/material.dart';
import 'package:zeina_app/core/theme/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final double border;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final TextDirection? textDirection;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.border = 1,
    this.borderRadius = 50,
    this.fillColor,
    this.borderColor,
    this.contentPadding,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.textDirection,
    this.onChanged,
    this.onTap,
  }) : super(key: key);

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      textDirection: textDirection,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
        filled: true,
        fillColor: fillColor ?? Colors.white,
        // ✅ NORMAL
        enabledBorder: _border(borderColor ?? ZienaColors.primary, width: 0.5),

        // ✅ FOCUSED
        focusedBorder: _border(borderColor ?? ZienaColors.primary, width: border),

        // ✅ ERROR (keeps same radius)
        errorBorder: _border(Colors.red, width: border),

        // ✅ FOCUSED + ERROR (important)
        focusedErrorBorder: _border(Colors.red, width: border),
        labelStyle: const TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}