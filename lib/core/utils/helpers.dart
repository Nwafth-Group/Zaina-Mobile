// ============================================
// FILE: lib/utils/helpers.dart
// ============================================
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/theme.dart';
import 'app_navigator.dart';

class Helpers {
  // Format date to Arabic
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'en').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy/MM/dd - HH:mm', 'en').format(date);
  }

  // Format time only
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'en').format(date);
  }

  // Format date in Arabic style
  static String formatDateArabic(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'اليوم ${formatTime(date)}';
    } else if (dateOnly == yesterday) {
      return 'أمس ${formatTime(date)}';
    } else {
      return formatDateTime(date);
    }
  }

  // Get time ago
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : years == 2 ? 'سنتين' : 'سنوات'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : months == 2 ? 'شهرين' : 'أشهر'}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : difference.inDays == 2 ? 'يومين' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : difference.inHours == 2 ? 'ساعتين' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : difference.inMinutes == 2 ? 'دقيقتين' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  // Show snackbar
  static void showSnackBar(
      BuildContext context,
      String message, {
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.fixed, // ← FIXED! Changed from floating
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        action: action,
      ),
    );
  }

  // Show success snackbar
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: ZienaColors.success,
    );
  }

  // Show error snackbar
  static void showError(String message) {
    showSnackBar(
      AppNavigator.navigatorKey.currentContext!,
      message,
      backgroundColor: ZienaColors.error,
    );
  }

  // Show warning snackbar
  static void showWarning(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: ZienaColors.bg3,
    );
  }

  // Show info snackbar
  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: ZienaColors.primary,
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 10),
                    Text(message),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'تأكيد',
        String cancelText = 'إلغاء',
        Color? confirmColor,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show info dialog
  static Future<void> showInfoDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'حسناً',
      }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Calculate distance between two points (Haversine formula)
  static double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Format distance
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)} متر';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} كم';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} كم';
    }
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove all non-digits
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Format as +966 50 123 4567
    if (digitsOnly.startsWith('966')) {
      final cleaned = digitsOnly.substring(3);
      if (cleaned.length >= 9) {
        return '+966 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
      }
    } else if (digitsOnly.startsWith('0')) {
      final cleaned = digitsOnly.substring(1);
      if (cleaned.length >= 9) {
        return '+966 ${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
      }
    }

    return phone;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return "Confirm password don't match the new password";
    }

    return null;
  }

  // Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرابط مطلوب';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  // Validate OTP code
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }

    if (value.length != 6) {
      return 'رمز التحقق يجب أن يكون 6 أرقام';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'رمز التحقق يجب أن يحتوي على أرقام فقط';
    }

    return null;
  }

  // Validate date
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'التاريخ مطلوب';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'التاريخ غير صحيح';
    }
  }

  // Validate future date
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'التاريخ مطلوب';
    }

    if (value.isBefore(DateTime.now())) {
      return 'يجب اختيار تاريخ مستقبلي';
    }

    return null;
  }

  // Validate past date
  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'التاريخ مطلوب';
    }

    if (value.isAfter(DateTime.now())) {
      return 'يجب اختيار تاريخ سابق';
    }

    return null;
  }

  // Composite validator
  static String? Function(String?) compose(
      List<String? Function(String?)> validators,
      ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}