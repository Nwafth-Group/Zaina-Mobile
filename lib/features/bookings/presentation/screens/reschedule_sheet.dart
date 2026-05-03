import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/success_dialog.dart';
import '../cubit/bookings_cubit.dart';

class RescheduleSheet extends StatefulWidget {
  final int bookingId;
  const RescheduleSheet({super.key, required this.bookingId});

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  DateTime _selectedDate = DateTime(2026, 8, 20);
  bool _isAm = true;
  String? _selectedStartTime;

  final _amTimes = ['09:00', '10:00', '11:00'];
  final _pmTimes = ['12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'];

  List<String> get _times => _isAm ? _amTimes : _pmTimes;

  String get _displayDate =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

  String get _apiDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: ZienaColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() { _selectedDate = d; _selectedStartTime = null; });
  }

  void _onConfirm() {
    if (_selectedStartTime == null) return;
    final parts = _selectedStartTime!.split(':');
    int h = int.parse(parts[0]);
    final endH = (h + 1).toString().padLeft(2, '0');
    final start = '$_selectedStartTime:00';
    final end = '$endH:00:00';

    context.read<BookingDetailCubit>().reschedule(
      bookingId: widget.bookingId,
      newDate: _apiDate,
      newStartTime: start,
      newEndTime: end,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingDetailCubit, BookingDetailState>(
      listener: (context, state) {
        if (state is BookingRescheduleSuccess) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => SuccessDialog(
              icon: Icons.notifications_active_rounded,
              title: 'reschedule_success_title'.tr(),
              message: 'reschedule_success_msg'.tr(),
            ),
          );
        }
        if (state is BookingDetailError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: ZienaColors.error,
          ));
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            Center(child: Text('select_date_and_time'.tr(),
                style: const TextStyle(
                   fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ))),
            const SizedBox(height: 20),
            Text('select_new_date'.tr(),
                style: const TextStyle(
                   fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZienaColors.greyBorder),
                ),
                child: Row(children: [
                  Expanded(child: Text(_displayDate,
                      style: const TextStyle(
                         fontSize: 14,
                        color: ZienaColors.textPrimary,
                      ))),
                  const Icon(Icons.calendar_today_rounded,
                      size: 18, color: ZienaColors.textSecondary),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // AM/PM
            Row(children: [
              _Toggle('AM', _isAm, () => setState(() {
                _isAm = true; _selectedStartTime = null;
              })),
              const SizedBox(width: 10),
              _Toggle('PM', !_isAm, () => setState(() {
                _isAm = false; _selectedStartTime = null;
              })),
            ]),
            const SizedBox(height: 14),

            // Time grid
            Wrap(spacing: 10, runSpacing: 10,
              children: _times.map((t) {
                final sel = _selectedStartTime == t;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStartTime = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 74, height: 40,
                    decoration: BoxDecoration(
                      color: sel ? ZienaColors.primary : ZienaColors.bg1,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? ZienaColors.primary : ZienaColors.greyBorder),
                    ),
                    child: Center(child: Text(t,
                        style: TextStyle(
                           fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : ZienaColors.textPrimary,
                        ))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            BlocBuilder<BookingDetailCubit, BookingDetailState>(
              builder: (_, state) {
                final loading = state is BookingActionLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedStartTime != null && !loading)
                        ? _onConfirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      disabledBackgroundColor:
                      ZienaColors.primary.withOpacity(0.4),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: loading
                        ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                        : Text('select'.tr(),
                        style: const TextStyle(
                           fontSize: 16,
                          fontWeight: FontWeight.w600, color: Colors.white,
                        )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _Toggle(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.primary : ZienaColors.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder),
        ),
        child: Text(label,
            style: TextStyle(
               fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : ZienaColors.textPrimary,
            )),
      ),
    );
  }
}