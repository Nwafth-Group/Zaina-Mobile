import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/booking_flow_model.dart';
import '../cubit/booking_flow_cubit.dart';

class StepDateTime extends StatefulWidget {
  final VoidCallback onNext;
  const StepDateTime({super.key, required this.onNext});

  @override
  State<StepDateTime> createState() => _StepDateTimeState();
}

class _StepDateTimeState extends State<StepDateTime> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  ShiftModel? _selectedShift;
  String? _selectedStartHour;
  String? _selectedEndHour;
  int _workerCount = 1;

  // ── Computed duration from selected start/end ─────────────────────────────
  int? get _calculatedDuration {
    if (_selectedStartHour == null || _selectedEndHour == null) return null;
    final start = int.parse(_selectedStartHour!.split(':')[0]);
    final end   = int.parse(_selectedEndHour!.split(':')[0]);
    final diff  = end - start;
    return diff > 0 ? diff : null;
  }

  String get _apiDate =>
      '${_selectedDate.year}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _displayDate => DateFormat('dd MMM yyyy').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  void _loadShifts() =>
      context.read<BookingFlowCubit>().fetchShifts(_apiDate);

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ZienaColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _selectedDate    = d;
        _selectedShift   = null;
        _selectedStartHour = null;
        _selectedEndHour   = null;
      });
      context.read<BookingFlowCubit>().fetchShifts(_apiDate);
    }
  }

  /// Hours that can be selected as start (all available hours except the last)
  List<String> get _startHours {
    if (_selectedShift == null) return [];
    final hours = _selectedShift!.availableHours;
    // Start can be any hour except the very last (need at least 1h gap for end)
    return hours.length > 1 ? hours.sublist(0, hours.length - 1) : [];
  }

  /// Hours that can be selected as end — must be after start
  List<String> get _endHours {
    if (_selectedShift == null || _selectedStartHour == null) return [];
    final hours = _selectedShift!.availableHours;
    final startIdx = hours.indexOf(_selectedStartHour!);
    if (startIdx == -1) return [];
    // End can be any hour after start
    return hours.sublist(startIdx + 1);
  }

  bool get _canNext =>
      _selectedShift != null &&
          _selectedStartHour != null &&
          _selectedEndHour != null &&
          _calculatedDuration != null &&
          _calculatedDuration! > 0;

  void _onNext() {
    if (!_canNext) return;

    final endTime =
        '${_selectedEndHour!.split(':')[0].padLeft(2, '0')}:00';

    final cubit = context.read<BookingFlowCubit>();
    cubit.updateFlow(cubit.flow.copyWith(
      selectedDate:          _apiDate,
      selectedStartTime:     _selectedStartHour,
      selectedEndTime:       endTime,
      selectedDurationHours: _calculatedDuration,
      selectedWorkerCount:   _workerCount,
      selectedShiftLabel:    _selectedShift!.dropdownLabel,
    ));

    cubit.fetchWorkers(
      date:          _apiDate,
      startTime:     _selectedStartHour!,
      durationHours: _calculatedDuration!,
    );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Date ───────────────────────────────────────────────────────────
          _sectionTitle('select_date'.tr()),
          const SizedBox(height: 10),
          _DateTile(display: _displayDate, onTap: _pickDate),
          const SizedBox(height: 20),

          // ── Shift ───────────────────────────────────────────────────────────
          _sectionTitle('select_time_slot'.tr()),
          const SizedBox(height: 10),
          BlocBuilder<BookingFlowCubit, BookingFlowState>(
            builder: (context, state) {
              if (state is BookingFlowShiftsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: ZienaColors.primary, strokeWidth: 2),
                );
              }
              if (state is BookingFlowShiftsLoaded) {
                if (state.shifts.isEmpty) {
                  return _EmptyBox(label: 'no_shifts_available'.tr());
                }
                return Column(
                  children: state.shifts.map((shift) {
                    final selected = _selectedShift?.id == shift.id;
                    return _ShiftTile(
                      shift: shift,
                      isSelected: selected,
                      onTap: () => setState(() {
                        _selectedShift     = shift;
                        _selectedStartHour = null;
                        _selectedEndHour   = null;
                      }),
                    );
                  }).toList(),
                );
              }
              return const SizedBox();
            },
          ),

          // ── Start hour ──────────────────────────────────────────────────────
          if (_selectedShift != null) ...[
            const SizedBox(height: 20),
            _sectionTitle('select_start_hour'.tr()),
            const SizedBox(height: 10),
            _startHours.isEmpty
                ? _EmptyBox(label: 'no_hours_available'.tr())
                : _HourGrid(
              hours:        _startHours,
              selectedHour: _selectedStartHour,
              disabledHours: const [],
              onSelect: (h) => setState(() {
                _selectedStartHour = h;
                _selectedEndHour   = null; // reset end when start changes
              }),
            ),
          ],

          // ── End hour ────────────────────────────────────────────────────────
          if (_selectedStartHour != null) ...[
            const SizedBox(height: 20),
            _sectionTitle('select_end_hour'.tr()),
            const SizedBox(height: 10),
            _endHours.isEmpty
                ? _EmptyBox(label: 'no_end_hours_available'.tr())
                : _HourGrid(
              hours:        _endHours,
              selectedHour: _selectedEndHour,
              disabledHours: const [],
              onSelect: (h) => setState(() => _selectedEndHour = h),
            ),
          ],

          // ── Duration summary (auto-calculated) ──────────────────────────────
          if (_calculatedDuration != null) ...[
            const SizedBox(height: 20),
            _DurationSummary(
              startHour: _selectedStartHour!,
              endHour:   _selectedEndHour!,
              duration:  _calculatedDuration!,
            ),
          ],

          const SizedBox(height: 20),

          // ── Workers ─────────────────────────────────────────────────────────
          _sectionTitle('number_of_workers'.tr()),
          const SizedBox(height: 10),
          _CounterRow(
            value:       _workerCount,
            min:         1,
            max:         5,
            onDecrement: () => setState(() => _workerCount--),
            onIncrement: () => setState(() => _workerCount++),
          ),
          const SizedBox(height: 32),

          // ── Next ────────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ZienaButton(
              text: 'next'.tr(),
              onTap: _canNext ? _onNext : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ZienaColors.textPrimary,
      ));
}

// ── Date tile ─────────────────────────────────────────────────────────────────
class _DateTile extends StatelessWidget {
  final String display;
  final VoidCallback onTap;
  const _DateTile({required this.display, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZienaColors.greyBorder),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 18, color: ZienaColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(display,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ZienaColors.textPrimary,
                )),
          ),
          const Icon(Icons.keyboard_arrow_down,
              color: ZienaColors.textSecondary),
        ]),
      ),
    );
  }
}

// ── Shift tile ────────────────────────────────────────────────────────────────
class _ShiftTile extends StatelessWidget {
  final ShiftModel shift;
  final bool isSelected;
  final VoidCallback onTap;
  const _ShiftTile({
    required this.shift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.bg2 : ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? ZienaColors.primary
                : ZienaColors.greyBorder,
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(children: [
          const Icon(Icons.wb_sunny_outlined,
              color: ZienaColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(shift.dropdownLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? ZienaColors.primary
                      : ZienaColors.textPrimary,
                )),
          ),
          if (isSelected)
            const Icon(Icons.check_circle,
                color: ZienaColors.primary, size: 18),
        ]),
      ),
    );
  }
}

// ── Hour grid — shared by start & end ────────────────────────────────────────
class _HourGrid extends StatelessWidget {
  final List<String> hours;
  final String? selectedHour;
  final List<String> disabledHours;
  final ValueChanged<String> onSelect;

  const _HourGrid({
    required this.hours,
    required this.selectedHour,
    required this.disabledHours,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: hours.map((h) {
        final sel      = selectedHour == h;
        final disabled = disabledHours.contains(h);
        return GestureDetector(
          onTap: disabled ? null : () => onSelect(h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 74,
            height: 42,
            decoration: BoxDecoration(
              color: sel
                  ? ZienaColors.primary
                  : disabled
                  ? ZienaColors.greyLight
                  : ZienaColors.bg1,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: sel
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
                width: sel ? 1.5 : 0.8,
              ),
            ),
            child: Center(
              child: Text(h,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel
                        ? Colors.white
                        : disabled
                        ? ZienaColors.textHint
                        : ZienaColors.textPrimary,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Duration summary card ─────────────────────────────────────────────────────
class _DurationSummary extends StatelessWidget {
  final String startHour;
  final String endHour;
  final int duration;

  const _DurationSummary({
    required this.startHour,
    required this.endHour,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: ZienaColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: ZienaColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time_rounded,
              color: ZienaColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('booking_duration'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ZienaColors.textSecondary,
                  )),
              const SizedBox(height: 2),
              Text(
                '$startHour  →  $endHour',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ZienaColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$duration ${'hrs'.tr()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Empty placeholder ─────────────────────────────────────────────────────────
class _EmptyBox extends StatelessWidget {
  final String label;
  const _EmptyBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder),
      ),
      child: Text(label,
          style: const TextStyle(
            fontSize: 13,
            color: ZienaColors.textSecondary,
          )),
    );
  }
}

// ── Workers counter ───────────────────────────────────────────────────────────
class _CounterRow extends StatelessWidget {
  final int value, min, max;
  final VoidCallback onDecrement, onIncrement;

  const _CounterRow({
    required this.value,
    required this.min,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$value ${'worker'.tr()}${value > 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ZienaColors.textPrimary,
            ),
          ),
          Row(children: [
            _Btn(icon: Icons.remove,
                onTap: value > min ? onDecrement : null),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$value',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  )),
            ),
            _Btn(icon: Icons.add,
                onTap: value < max ? onIncrement : null),
          ]),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _Btn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: onTap != null ? ZienaColors.bg2 : ZienaColors.greyLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap != null
                ? ZienaColors.primary.withOpacity(0.3)
                : ZienaColors.greyBorder,
          ),
        ),
        child: Icon(icon,
            size: 16,
            color: onTap != null
                ? ZienaColors.primary
                : ZienaColors.textHint),
      ),
    );
  }
}