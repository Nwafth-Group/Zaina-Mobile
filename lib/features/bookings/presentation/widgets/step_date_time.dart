import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
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
  String? _selectedHour;
  int _selectedDuration = 2;
  int _workerCount = 1;

  String get _apiDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  String get _displayDate =>
      DateFormat('dd MMM yyyy').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  void _loadShifts() {
    context.read<BookingFlowCubit>().fetchShifts(_apiDate);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: ZienaColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _selectedDate = d;
        _selectedShift = null;
        _selectedHour = null;
      });
      context.read<BookingFlowCubit>().fetchShifts(_apiDate);
    }
  }

  void _onNext() {
    if (_selectedShift == null || _selectedHour == null) return;
    final endHour = int.parse(_selectedHour!.split(':')[0]) + _selectedDuration;
    final endTime = '${endHour.toString().padLeft(2, '0')}:00';

    final cubit = context.read<BookingFlowCubit>();
    cubit.updateFlow(cubit.flow.copyWith(
      selectedDate: _apiDate,
      selectedStartTime: _selectedHour,
      selectedEndTime: endTime,
      selectedDurationHours: _selectedDuration,
      selectedWorkerCount: _workerCount,
      selectedShiftLabel: _selectedShift!.dropdownLabel,
    ));

    // Fetch workers for next step
    cubit.fetchWorkers(
      date: _apiDate,
      startTime: _selectedHour!,
      durationHours: _selectedDuration,
    );
    widget.onNext();
  }

  bool get _canNext => _selectedShift != null && _selectedHour != null;

  @override
  Widget build(BuildContext context) {
    final flow = context.read<BookingFlowCubit>().flow;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Date picker ──────────────────────────────────────────────────────
        _sectionTitle('select_date'.tr()),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: ZienaColors.bg1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ZienaColors.greyBorder),
            ),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 18, color: ZienaColors.primary),
              const SizedBox(width: 10),
              Expanded(child: Text(_displayDate,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ZienaColors.textPrimary,
                  ))),
              const Icon(Icons.keyboard_arrow_down,
                  color: ZienaColors.textSecondary),
            ]),
          ),
        ),
        const SizedBox(height: 20),

        // ── Shifts ────────────────────────────────────────────────────────────
        _sectionTitle('select_time_slot'.tr()),
        const SizedBox(height: 10),
        BlocBuilder<BookingFlowCubit, BookingFlowState>(
          builder: (context, state) {
            if (state is BookingFlowShiftsLoading) {
              return const Center(child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2));
            }
            if (state is BookingFlowShiftsLoaded) {
              final shifts = state.shifts;
              if (shifts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ZienaColors.bg1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ZienaColors.greyBorder),
                  ),
                  child: Text('no_shifts_available'.tr(),
                      style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        color: ZienaColors.textSecondary,
                      )),
                );
              }
              return Column(
                children: shifts.map((shift) {
                  final selected = _selectedShift?.id == shift.id;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedShift = shift;
                      _selectedHour = null;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? ZienaColors.bg2 : ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? ZienaColors.primary
                              : ZienaColors.greyBorder,
                          width: selected ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(children: [
                        const Icon(Icons.wb_sunny_outlined,
                            color: ZienaColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text(shift.dropdownLabel,
                            style: TextStyle(
                              fontFamily: 'Poppins', fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: selected
                                  ? ZienaColors.primary
                                  : ZienaColors.textPrimary,
                            ))),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: ZienaColors.primary, size: 18),
                      ]),
                    ),
                  );
                }).toList(),
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(height: 20),

        // ── Available hours (shown after shift selection) ────────────────────
        if (_selectedShift != null) ...[
          _sectionTitle('select_start_hour'.tr()),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _selectedShift!.availableHours.map((h) {
              final sel = _selectedHour == h;
              // Check if enough hours remain for duration
              final idx = _selectedShift!.availableHours.indexOf(h);
              final remaining = _selectedShift!.availableHours.length - idx;
              final available = remaining >= _selectedDuration;
              return GestureDetector(
                onTap: available ? () => setState(() => _selectedHour = h) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 74, height: 42,
                  decoration: BoxDecoration(
                    color: sel
                        ? ZienaColors.primary
                        : available
                        ? ZienaColors.bg1
                        : ZienaColors.greyLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel
                          ? ZienaColors.primary
                          : available
                          ? ZienaColors.greyBorder
                          : ZienaColors.greyBorder,
                    ),
                  ),
                  child: Center(child: Text(h,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? Colors.white
                            : available
                            ? ZienaColors.textPrimary
                            : ZienaColors.textHint,
                      ))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // ── Duration ──────────────────────────────────────────────────────────
        _sectionTitle('select_duration'.tr()),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: flow.allowedDurations.map((d) {
            final sel = _selectedDuration == d;
            return GestureDetector(
              onTap: () => setState(() {
                _selectedDuration = d;
                _selectedHour = null; // reset hour on duration change
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? ZienaColors.primary : ZienaColors.bg1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? ZienaColors.primary : ZienaColors.greyBorder),
                ),
                child: Text('$d hrs',
                    style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : ZienaColors.textPrimary,
                    )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // ── Workers count ─────────────────────────────────────────────────────
        _sectionTitle('number_of_workers'.tr()),
        const SizedBox(height: 10),
        _CounterRow(
          value: _workerCount,
          min: 1, max: 5,
          onDecrement: () => setState(() => _workerCount--),
          onIncrement: () => setState(() => _workerCount++),
        ),
        const SizedBox(height: 32),

        // ── Next ─────────────────────────────────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canNext ? _onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.primary,
              disabledBackgroundColor: ZienaColors.primary.withOpacity(0.4),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('next'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white,
                )),
          ),
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
        fontFamily: 'Poppins', fontSize: 14,
        fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
      ));
}

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$value Worker${value > 1 ? 's' : ''}',
              style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ZienaColors.textPrimary,
              )),
          Row(children: [
            _Btn(icon: Icons.remove,
                onTap: value > min ? onDecrement : null),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$value',
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 18,
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
                  : ZienaColors.greyBorder),
        ),
        child: Icon(icon, size: 16,
            color: onTap != null ? ZienaColors.primary : ZienaColors.textHint),
      ),
    );
  }
}