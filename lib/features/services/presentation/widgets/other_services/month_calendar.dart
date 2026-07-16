
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/theme/theme.dart';

const List<String> monthKeys = [
  'month_1', 'month_2', 'month_3', 'month_4', 'month_5', 'month_6',
  'month_7', 'month_8', 'month_9', 'month_10', 'month_11', 'month_12',
];

// Header order is Sat–Fri to match the region's Fri/Sat weekend.
const List<String> weekdayKeys = [
  'weekday_sat', 'weekday_sun', 'weekday_mon', 'weekday_tue',
  'weekday_wed', 'weekday_thu', 'weekday_fri',
];

/// Reusable Sat-first month calendar grid (UI only). Selection is
/// controlled by the parent via [selectedDate]/[onDateSelected]; which
/// month is currently visible is kept as internal state so callers don't
/// need to manage month navigation themselves.
class MonthCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const MonthCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _visibleMonth;
  late final DateTime _today;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    final anchor = widget.selectedDate ?? now;
    _visibleMonth = DateTime(anchor.year, anchor.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  // Sat=0 ... Fri=6, to line up with the Sat-first weekday header.
  int _columnIndexFor(int dartWeekday) => (dartWeekday % 7 + 1) % 7;

  List<DateTime?> _buildGridCells() {
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final leadingEmpty = _columnIndexFor(firstDay.weekday);

    final cells = <DateTime?>[
      ...List.filled(leadingEmpty, null),
      for (int day = 1; day <= daysInMonth; day++)
        DateTime(_visibleMonth.year, _visibleMonth.month, day),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildGridCells();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _changeMonth(-1),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.chevron_left, color: ZienaColors.primary),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${monthKeys[_visibleMonth.month - 1].tr()} ${_visibleMonth.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _changeMonth(1),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.chevron_right, color: ZienaColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: weekdayKeys
              .map(
                (key) => Expanded(
              child: Center(
                child: Text(
                  key.tr(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textSecondary,
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: cells.map((date) {
            if (date == null) return const SizedBox.shrink();

            final isPast = date.isBefore(_today);
            final isToday = _isSameDay(date, _today);
            final isSelected =
                widget.selectedDate != null && _isSameDay(date, widget.selectedDate!);

            Color textColor;
            BoxDecoration? decoration;

            if (isSelected) {
              textColor = ZienaColors.white;
              decoration = const BoxDecoration(
                color: ZienaColors.primary,
                shape: BoxShape.circle,
              );
            } else if (isPast) {
              textColor = ZienaColors.textHint;
              decoration = null;
            } else if (isToday) {
              textColor = ZienaColors.primary;
              decoration = BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ZienaColors.primary),
              );
            } else {
              textColor = ZienaColors.textPrimary;
              decoration = null;
            }

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: isPast ? null : () => widget.onDateSelected(date),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: decoration,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (!isPast)
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: ZienaColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}