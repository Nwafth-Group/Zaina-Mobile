import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/success_dialog.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/booking_flow_model.dart';
import '../cubit/bookings_cubit.dart';
import '../cubit/reschedule_shifts_cubit.dart';

class RescheduleSheet extends StatefulWidget {
  final int bookingId;
  const RescheduleSheet({super.key, required this.bookingId});

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  ShiftModel? _shift;
  AvailableBlockModel? _block;

  String get _apiDate =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  bool get _canConfirm => _block != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RescheduleShiftsCubit>()
          .fetchShifts(widget.bookingId, _apiDate);
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
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
    if (d != null && mounted) {
      setState(() {
        _date = d;
        _shift = null;
        _block = null;
      });
      context
          .read<RescheduleShiftsCubit>()
          .fetchShifts(widget.bookingId, _apiDate);
    }
  }

  void _onConfirm() {
    if (_block == null) return;
    context.read<BookingDetailCubit>().reschedule(
      bookingId: widget.bookingId,
      newDate: _apiDate,
      newStartTime: _block!.startTime,
      newEndTime: _block!.endTime,
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
            20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ZienaColors.greyBorder,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'select_date_and_time'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Date picker ────────────────────────────────────────────────
              _label('select_new_date'.tr()),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: ZienaColors.bg1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ZienaColors.greyBorder),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_date),
                        style: const TextStyle(
                            fontSize: 14,
                            color: ZienaColors.textPrimary),
                      ),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: ZienaColors.textSecondary),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // ── Shifts ─────────────────────────────────────────────────────
              _label('select_time_slot'.tr()),
              const SizedBox(height: 8),
              BlocBuilder<RescheduleShiftsCubit, RescheduleShiftsState>(
                builder: (context, state) {
                  if (state is RescheduleShiftsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: ZienaColors.primary, strokeWidth: 2),
                    );
                  }
                  if (state is RescheduleShiftsError) {
                    return _emptyBox(state.message);
                  }
                  final shifts =
                      state is RescheduleShiftsLoaded ? state.shifts : <ShiftModel>[];
                  if (shifts.isEmpty) {
                    return _emptyBox('no_shifts_available'.tr());
                  }
                  return Column(
                    children: shifts.map((s) {
                      final sel = _shift?.id == s.id;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _shift = s;
                          _block = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                sel ? ZienaColors.bg2 : ZienaColors.bg1,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: sel
                                  ? ZienaColors.primary
                                  : ZienaColors.greyBorder,
                              width: sel ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Text(
                                s.dropdownLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? ZienaColors.primary
                                      : ZienaColors.textPrimary,
                                ),
                              ),
                            ),
                            if (sel)
                              const Icon(Icons.keyboard_arrow_up,
                                  color: ZienaColors.primary, size: 18)
                            else
                              const Icon(Icons.keyboard_arrow_down,
                                  color: ZienaColors.textSecondary,
                                  size: 18),
                          ]),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              // ── Available time blocks ──────────────────────────────────────
              if (_shift != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _shift!.availableBlocks.map((b) {
                    final sel = _block == b;
                    return GestureDetector(
                      onTap: () => setState(() => _block = b),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel
                              ? ZienaColors.primary
                              : ZienaColors.bg1,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel
                                ? ZienaColors.primary
                                : ZienaColors.greyBorder,
                            width: sel ? 1.5 : 0.8,
                          ),
                        ),
                        child: Text(
                          b.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : ZienaColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // ── Confirm button ─────────────────────────────────────────────
              BlocBuilder<BookingDetailCubit, BookingDetailState>(
                builder: (_, state) {
                  final loading = state is BookingActionLoading;
                  return ZienaButton(
                    text: 'select'.tr(),
                    onTap: (_canConfirm && !loading) ? _onConfirm : null,
                    disabledBackgroundColor:
                        ZienaColors.primary.withValues(alpha: 0.4),
                    disabledTextColor: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
        t,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ZienaColors.textPrimary,
        ),
      );

  Widget _emptyBox(String t) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZienaColors.greyBorder),
        ),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary)),
      );
}
