
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class BookingCalendar extends StatefulWidget {
  final List<DateTime> availableDates;
  final Set<DateTime> selectedDates;
  final int maxSelectable; // 1 for single_visit, 3 for 3_days_per_week
  final ValueChanged<Set<DateTime>> onChanged;

  const BookingCalendar({
    super.key,
    required this.availableDates,
    required this.selectedDates,
    required this.maxSelectable,
    required this.onChanged,
  });

  @override
  State<BookingCalendar> createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  late DateTime _currentMonth;
  late final Set<DateTime> _availableSet;
  late final DateTime? _minMonth;
  late final DateTime? _maxMonth;

  @override
  void initState() {
    super.initState();
    _availableSet = widget.availableDates.map(_normalize).toSet();
    final sorted = widget.availableDates.toList()..sort();
    _minMonth = sorted.isNotEmpty
        ? DateTime(sorted.first.year, sorted.first.month)
        : null;
    _maxMonth = sorted.isNotEmpty
        ? DateTime(sorted.last.year, sorted.last.month)
        : null;
    final initial = widget.selectedDates.isNotEmpty
        ? widget.selectedDates.first
        : (sorted.isNotEmpty ? sorted.first : DateTime.now());
    _currentMonth = DateTime(initial.year, initial.month);
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _canGoBack =>
      _minMonth == null || _currentMonth.isAfter(_minMonth!);
  bool get _canGoForward =>
      _maxMonth == null || _currentMonth.isBefore(_maxMonth!);

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  void _onDayTap(DateTime day) {
    final normalized = _normalize(day);
    if (!_availableSet.contains(normalized)) return;

    final updated = Set<DateTime>.from(widget.selectedDates);
    if (widget.maxSelectable == 1) {
      updated
        ..clear()
        ..add(normalized);
      widget.onChanged(updated);
      return;
    }

    if (updated.contains(normalized)) {
      updated.remove(normalized);
      widget.onChanged(updated);
      return;
    }

    if (updated.length >= widget.maxSelectable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can select up to ${widget.maxSelectable} days'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    updated.add(normalized);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final today = _normalize(DateTime.now());
    final firstOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    // Columns: Sat, Sun, Mon, Tue, Wed, Thu, Fri
    final leadingBlanks = (firstOfMonth.weekday + 1) % 7;

    final cells = <DateTime?>[
      ...List.filled(leadingBlanks, null),
      for (int d = 1; d <= daysInMonth; d++)
        DateTime(_currentMonth.year, _currentMonth.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final monthLabel = '${_monthName(_currentMonth.month)} ${_currentMonth.year}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left,
                  color:
                  _canGoBack ? ZienaColors.primary : ZienaColors.greyBorder),
              onPressed: _canGoBack ? () => _changeMonth(-1) : null,
            ),
            Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right,
                  color: _canGoForward
                      ? ZienaColors.primary
                      : ZienaColors.greyBorder),
              onPressed: _canGoForward ? () => _changeMonth(1) : null,
            ),
          ],
        ),
        Row(
          children: const [
            _WeekdayLabel('Sat'),
            _WeekdayLabel('Sun'),
            _WeekdayLabel('Mon'),
            _WeekdayLabel('Tue'),
            _WeekdayLabel('Wed'),
            _WeekdayLabel('Thu'),
            _WeekdayLabel('Fri'),
          ],
        ),
        const SizedBox(height: 4),
        for (int row = 0; row < cells.length ~/ 7; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                for (int col = 0; col < 7; col++)
                  Expanded(
                    child: _DayCell(
                      date: cells[row * 7 + col],
                      isAvailable: cells[row * 7 + col] != null &&
                          _availableSet.contains(cells[row * 7 + col]),
                      isSelected: cells[row * 7 + col] != null &&
                          widget.selectedDates
                              .contains(_normalize(cells[row * 7 + col]!)),
                      isToday: cells[row * 7 + col] != null &&
                          _normalize(cells[row * 7 + col]!) == today,
                      onTap: cells[row * 7 + col] == null
                          ? null
                          : () => _onDayTap(cells[row * 7 + col]!),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ZienaColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime? date;
  final bool isAvailable;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.date,
    required this.isAvailable,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (date == null) return const SizedBox(height: 44);

    final textColor = isSelected
        ? ZienaColors.white
        : isAvailable
        ? ZienaColors.textPrimary
        : ZienaColors.textHint;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? ZienaColors.primary : Colors.transparent,
                border: (isToday && !isSelected)
                    ? Border.all(color: ZienaColors.primary, width: 1.2)
                    : null,
              ),
              child: Text(
                '${date!.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (isAvailable && !isSelected)
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
  }
}