import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/theme/theme.dart';
import 'month_calendar.dart';

/// UI-only date selection bottom sheet (no cubit/API wiring). Shown after
/// "Check Availability" is tapped in the Pedicure & Manicure booking sheet.

/// Opens the date selection sheet. Resolves with the picked [DateTime],
/// or null if the sheet was dismissed without a selection.
Future<DateTime?> showDateSelectionSheet(BuildContext context) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DateSelectionSheet(),
  );
}

class _DateSelectionSheet extends StatefulWidget {
  const _DateSelectionSheet();

  @override
  State<_DateSelectionSheet> createState() => _DateSelectionSheetState();
}

class _DateSelectionSheetState extends State<_DateSelectionSheet> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'kindly_select_date'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            MonthCalendar(
              selectedDate: _selectedDate,
              onDateSelected: (date) => setState(() => _selectedDate = date),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZienaColors.primary,
                    foregroundColor: ZienaColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'proceed_to_payment'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}