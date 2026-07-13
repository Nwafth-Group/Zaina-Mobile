
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_small_button.dart';
import '../../../services/data/model/service_detail_model.dart';
import '../../../services/presentation/widgets/booking_calendar.dart';
import '../../data/model/reschedule_result.dart';

/// Shows the "Select New Date And Time" sheet for fixed-shift services
/// (Domestic Helper-style — has pre-set shift slots rather than a
/// configurable start-time/duration). Returns a [RescheduleResult] on Save,
/// or null if dismissed.
Future<RescheduleResult?> showRescheduleFixedShiftSheet({
  required BuildContext context,
  required ServiceDetailModel service,
  required int requiredDays, // 1 for single_visit, 3 for 3_days_per_week
}) {
  return showModalBottomSheet<RescheduleResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RescheduleFixedShiftSheet(
      service: service,
      requiredDays: requiredDays,
    ),
  );
}

class _RescheduleFixedShiftSheet extends StatefulWidget {
  final ServiceDetailModel service;
  final int requiredDays;
  const _RescheduleFixedShiftSheet({
    required this.service,
    required this.requiredDays,
  });

  @override
  State<_RescheduleFixedShiftSheet> createState() =>
      _RescheduleFixedShiftSheetState();
}

class _RescheduleFixedShiftSheetState extends State<_RescheduleFixedShiftSheet> {
  Set<DateTime> _selectedDates = {};
  ServiceShiftModel? _selectedShift;

  bool get _isValid =>
      _selectedDates.length == widget.requiredDays && _selectedShift != null;

  @override
  void initState() {
    super.initState();
    if (widget.service.availableShifts.isNotEmpty) {
      _selectedShift = widget.service.availableShifts.first;
    }
  }

  void _onSave() {
    if (!_isValid) return;
    Navigator.pop(
      context,
      RescheduleResult(
        dates: _selectedDates.toList()..sort(),
        startTime: _selectedShift!.startLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: ZienaColors.bg1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    Text(
                      'select_new_date_and_time'.tr(),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'service_date'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    if (widget.requiredDays > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'please_select_days'.tr(args: ['${widget.requiredDays}']),
                          style: const TextStyle(
                            color: ZienaColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    BookingCalendar(
                      availableDates: widget.service.availableDates,
                      selectedDates: _selectedDates,
                      maxSelectable: widget.requiredDays,
                      onChanged: (dates) => setState(() => _selectedDates = dates),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'service_period'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildShiftRow(),
                    const SizedBox(height: 8),
                    Text(
                      'service_duration_note'
                          .tr(args: ['${widget.service.defaultDuration}']),
                      style: const TextStyle(
                        color: ZienaColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ZienaSmallButton(
                        text: 'cancel'.tr(),
                        isOutlined: true,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ZienaSmallButton(
                        text: 'save_button'.tr(),
                        onTap: _isValid ? _onSave : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShiftRow() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.service.availableShifts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final shift = widget.service.availableShifts[index];
          final selected = _selectedShift?.startTime == shift.startTime;
          return GestureDetector(
            onTap: () => setState(() => _selectedShift = shift),
            child: Container(
              width: 96,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? ZienaColors.primary : ZienaColors.white,
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? null
                    : Border.all(color: ZienaColors.greyBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shift.startLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? ZienaColors.white : ZienaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        shift.isMorning
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        size: 12,
                        color: selected ? ZienaColors.white : ZienaColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shift.periodLabelKey.tr(),
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? ZienaColors.white : ZienaColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}