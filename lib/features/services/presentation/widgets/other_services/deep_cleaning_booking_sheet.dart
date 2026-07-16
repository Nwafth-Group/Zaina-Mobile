
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/theme/theme.dart';
import 'month_calendar.dart';

/// UI-only Deep Cleaning booking sheet (no cubit/API wiring). Unlike the
/// Pedicure & Manicure flow (persons/workers sheet -> separate date
/// sheet), Deep Cleaning combines date + time-of-day selection into a
/// single sheet, matching the design.

class _ServicePeriod {
  final String time;
  final String labelKey;
  final IconData icon;

  const _ServicePeriod({
    required this.time,
    required this.labelKey,
    required this.icon,
  });
}

const List<_ServicePeriod> _periods = [
  _ServicePeriod(time: '08:00', labelKey: 'period_morning', icon: Icons.wb_sunny_outlined),
  _ServicePeriod(time: '10:00', labelKey: 'period_morning', icon: Icons.wb_sunny_outlined),
  _ServicePeriod(time: '04:30', labelKey: 'period_evening', icon: Icons.nightlight_round),
  _ServicePeriod(time: '06:30', labelKey: 'period_evening', icon: Icons.nightlight_round),
];

/// Opens the Deep Cleaning booking sheet over [context]'s current screen.
Future<void> showDeepCleaningBookingSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _DeepCleaningBookingSheet(),
  );
}

class _DeepCleaningBookingSheet extends StatefulWidget {
  const _DeepCleaningBookingSheet();

  @override
  State<_DeepCleaningBookingSheet> createState() => _DeepCleaningBookingSheetState();
}

class _DeepCleaningBookingSheetState extends State<_DeepCleaningBookingSheet> {
  DateTime? _selectedDate;
  int? _selectedPeriodIndex;

  bool get _canProceed => _selectedDate != null && _selectedPeriodIndex != null;

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
              'service_date'.tr(),
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
            const SizedBox(height: 18),
            Text(
              'service_period'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _periods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final period = _periods[index];
                  final isSelected = _selectedPeriodIndex == index;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedPeriodIndex = index),
                    child: Container(
                      width: 92,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? ZienaColors.primary : ZienaColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ZienaColors.primary
                              : ZienaColors.primary.withOpacity(0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                period.time,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? ZienaColors.white : ZienaColors.textPrimary,
                                ),
                              ),
                              Icon(
                                period.icon,
                                size: 16,
                                color: isSelected ? ZienaColors.white : ZienaColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            period.labelKey.tr(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? ZienaColors.white.withOpacity(0.9)
                                  : ZienaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'deep_cleaning_period_hint'.tr(),
              style: const TextStyle(fontSize: 11, color: ZienaColors.primary),
            ),
            if (_canProceed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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