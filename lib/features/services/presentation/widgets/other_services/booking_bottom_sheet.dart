import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/theme/theme.dart';
import 'package:zeina/features/services/presentation/widgets/other_services/date_selection_sheet.dart';

/// UI-only booking bottom sheet (no cubit/API wiring). Local state here
/// only drives the visual interactions (steppers, worker-mode picker,
/// duration recalculation) so the sheet feels alive when demoed — swap
/// this out for a real BookingCubit when integrating.

enum _WorkerMode { forAll, perPerson, others }

/// Opens the "Book Now" booking sheet over [context]'s current screen.
Future<void> showBookingSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _BookingSheet(),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet();

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  static const int _hoursPerPerson = 2;

  TimeOfDay _startTime = const TimeOfDay(hour: 14, minute: 0);
  int _persons = 1;
  _WorkerMode _workerMode = _WorkerMode.forAll;
  int _customWorkers = 1;

  int get _durationHours {
    switch (_workerMode) {
      case _WorkerMode.forAll:
      // One worker sees every person in sequence.
        return _hoursPerPerson * _persons;
      case _WorkerMode.perPerson:
      // Everyone is served in parallel, one worker each.
        return _hoursPerPerson;
      case _WorkerMode.others:
      // A fixed crew splits the persons into rounds.
        final workers = _customWorkers.clamp(1, _persons);
        final rounds = (_persons / workers).ceil();
        return _hoursPerPerson * rounds;
    }
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _shiftTime(int minutes) {
    setState(() {
      const minutesPerDay = 24 * 60;
      final total = (_startTime.hour * 60 + _startTime.minute + minutes) % minutesPerDay;
      final normalized = total < 0 ? total + minutesPerDay : total;
      _startTime = TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
    });
  }

  void _changePersons(int delta) {
    setState(() {
      _persons = (_persons + delta).clamp(1, 20);
      if (_workerMode == _WorkerMode.others) {
        _customWorkers = _customWorkers.clamp(1, _persons);
      }
    });
  }

  void _changeCustomWorkers(int delta) {
    setState(() {
      _customWorkers = (_customWorkers + delta).clamp(1, _persons);
    });
  }

  String _workerModeLabel(_WorkerMode mode) {
    switch (mode) {
      case _WorkerMode.forAll:
        return 'worker_for_all'.tr();
      case _WorkerMode.perPerson:
        return 'worker_per_person'.tr();
      case _WorkerMode.others:
        return 'workers_others'.tr();
    }
  }

  Future<void> _pickWorkerMode() async {
    final selected = await showModalBottomSheet<_WorkerMode>(
      context: context,
      backgroundColor: ZienaColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _WorkerMode.values.map((mode) {
              return ListTile(
                title: Text(
                  _workerModeLabel(mode),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  ),
                ),
                trailing: mode == _workerMode
                    ? const Icon(Icons.check, color: ZienaColors.primary)
                    : null,
                onTap: () => Navigator.pop(sheetContext, mode),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() {
        _workerMode = selected;
        if (selected == _WorkerMode.others) {
          _customWorkers = _customWorkers.clamp(1, _persons);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keep the sheet above the keyboard, in case a text field is
      // added here later.
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
            _StepperField(
              label: 'start_service_time'.tr(),
              value: _formatTime(_startTime),
              onIncrement: () => _shiftTime(30),
              onDecrement: () => _shiftTime(-30),
            ),
            const SizedBox(height: 12),
            _StepperField(
              label: 'number_of_persons'.tr(),
              value: '$_persons',
              onIncrement: () => _changePersons(1),
              onDecrement: () => _changePersons(-1),
            ),
            const SizedBox(height: 12),
            _DropdownField(
              label: 'number_of_workers'.tr(),
              value: _workerModeLabel(_workerMode),
              onTap: _pickWorkerMode,
            ),
            if (_workerMode == _WorkerMode.others) ...[
              const SizedBox(height: 12),
              _StepperField(
                label: 'select_number_of_workers'.tr(),
                value: '$_customWorkers',
                onIncrement: () => _changeCustomWorkers(1),
                onDecrement: () => _changeCustomWorkers(-1),
              ),
            ],
            const SizedBox(height: 12),
            _ReadonlyField(
              label: 'service_duration'.tr(),
              hint: 'service_duration_hint'.tr(),
              value: '$_durationHours ${'hours_suffix'.tr()}',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showDateSelectionSheet(context),
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
                  'check_availability'.tr(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
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

/// Shared bordered-box shell used by every row in the booking sheet.
class _FieldShell extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget trailing;
  final VoidCallback? onTap;

  const _FieldShell({
    required this.label,
    required this.trailing,
    this.hint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZienaColors.primary.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary,
                    ),
                  ),
                  if (hint != null)
                    TextSpan(
                      text: ' $hint',
                      style: const TextStyle(
                        fontSize: 10,
                        color: ZienaColors.textHint,
                      ),
                    ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: content,
    );
  }
}

class _StepperField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _StepperField({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperIconButton(icon: Icons.add, onTap: onIncrement),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          _StepperIconButton(icon: Icons.remove, onTap: onDecrement),
        ],
      ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ZienaColors.primary),
        ),
        child: Icon(icon, size: 14, color: ZienaColors.primary),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            color: ZienaColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ReadonlyField extends StatelessWidget {
  final String label;
  final String hint;
  final String value;

  const _ReadonlyField({
    required this.label,
    required this.hint,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      hint: hint,
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ZienaColors.textPrimary,
        ),
      ),
    );
  }
}