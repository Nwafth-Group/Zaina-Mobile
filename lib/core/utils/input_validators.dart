import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

/// Converts Arabic-Indic (٠-٩) and Persian (۰-۹) digits to Latin 0-9, and
/// the Arabic decimal separator (٫) to '.', so Arabic keyboards still work.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x0660 && rune <= 0x0669) {
      buffer.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      buffer.writeCharCode(0x30 + rune - 0x06F0);
    } else if (rune == 0x066B) {
      buffer.write('.');
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// Money amount input: digits with at most one '.' and two decimals.
/// Any edit that would introduce another character (letters, symbols,
/// spaces, a second dot) is rejected and the previous value is kept.
class AmountInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = normalizeDigits(newValue.text);
    if (!_pattern.hasMatch(text)) return oldValue;
    return newValue.copyWith(text: text);
  }
}

/// Validates a card expiry in `MM/YY` form: month 01-12, not in the past,
/// and not unrealistically far in the future (cards are issued for at most
/// ~20 years). Returns a translated error message, or null when valid.
String? validateCardExpiry(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'this_field_required'.tr();

  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(v);
  if (match == null) return 'invalid_expiry_date'.tr();

  final month = int.parse(match.group(1)!);
  final year = 2000 + int.parse(match.group(2)!);
  if (month < 1 || month > 12) return 'invalid_expiry_date'.tr();

  final now = DateTime.now();
  // A card is valid through the last day of its expiry month.
  if (year < now.year || (year == now.year && month < now.month)) {
    return 'card_expired'.tr();
  }
  if (year > now.year + 20) return 'invalid_expiry_date'.tr();
  return null;
}
