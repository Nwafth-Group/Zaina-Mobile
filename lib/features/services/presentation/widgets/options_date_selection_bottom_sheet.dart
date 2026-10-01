import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_selection_data.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/booking_validation_model.dart';
import '../../data/model/options_config_result.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/visit_type_model.dart';
import '../../data/repository/services_repository.dart';
import 'booking_calendar.dart';
import 'coverage_error_dialog.dart';

/// Step 2 of the options-based booking flow (services 6-11): pick a date from
/// whatever /bookings/available-dates returned for the chosen options, plus a
/// service period (shift), then validate and hand off to the same
/// [BookingSelectionData] / [BookingValidationModel] pair every other flow
/// produces — so Checkout stays identical.
Future<void> showOptionsDateSelectionBottomSheet({
  required BuildContext context,
  required ServiceDetailModel service,
  required VisitTypeModel visitType,
  required OptionsConfigResult config,
  required void Function(
    BookingSelectionData data,
    BookingValidationModel validation,
  ) onProceed,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OptionsDateSelectionBottomSheet(
      service: service,
      visitType: visitType,
      config: config,
      onProceed: onProceed,
    ),
  );
}

class OptionsDateSelectionBottomSheet extends StatefulWidget {
  final ServiceDetailModel service;
  final VisitTypeModel visitType;
  final OptionsConfigResult config;
  final void Function(
    BookingSelectionData data,
    BookingValidationModel validation,
  ) onProceed;

  const OptionsDateSelectionBottomSheet({
    super.key,
    required this.service,
    required this.visitType,
    required this.config,
    required this.onProceed,
  });

  @override
  State<OptionsDateSelectionBottomSheet> createState() =>
      _OptionsDateSelectionBottomSheetState();
}

class _OptionsDateSelectionBottomSheetState
    extends State<OptionsDateSelectionBottomSheet> {
  Set<DateTime> _selectedDates = {};
  ServiceShiftModel? _selectedShift;
  bool _isSubmitting = false;

  bool get _isValid => _selectedDates.isNotEmpty && _selectedShift != null;

  @override
  void initState() {
    super.initState();
    if (widget.service.availableShifts.isNotEmpty) {
      _selectedShift = widget.service.availableShifts.first;
    }
  }

  Future<void> _handleProceed() async {
    if (!_isValid || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final validation = await sl<ServicesRepository>().validateBooking(
        serviceId: widget.service.id,
        visitType: widget.visitType.type,
        addressId: widget.service.addressId,
        dates: _selectedDates.toList(),
        startTime: _selectedShift!.startLabel,
        // No workers_count for options-based services — the backend assigns
        // a team and returns its worker ids.
        workersCount: null,
        options: widget.config.options,
        note: widget.config.note,
      );
      if (!mounted) return;
      final selection = BookingSelectionData(
        serviceId: widget.service.id,
        visitType: widget.visitType,
        selectedDates: _selectedDates.toList(),
        shift: _selectedShift!,
        workerCount: validation.workerIds.length,
        preferredWorkerIds: const [],
        note: widget.config.note,
        options: widget.config.options,
      );
      Navigator.pop(context);
      widget.onProceed(selection, validation);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message =
          e is BookingValidationException ? e.displayMessage : 'err_generic'.tr();
      showCoverageErrorDialog(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                      'service_date'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    BookingCalendar(
                      availableDates: widget.config.availableDates,
                      selectedDates: _selectedDates,
                      maxSelectable: 1,
                      onChanged: (dates) =>
                          setState(() => _selectedDates = dates),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_isValid && !_isSubmitting) ? _handleProceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      disabledBackgroundColor: ZienaColors.greyBorder,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: ZienaColors.white),
                          )
                        : Text('proceed_to_payment'.tr()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Same chip design as the fixed-shift sheet's service-period row.
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
                    shift.startLabel12,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? ZienaColors.white
                          : ZienaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        shift.isMorning
                            ? Icons.wb_sunny_outlined
                            : Icons.nightlight_round,
                        size: 14,
                        color: shift.isMorning
                            ? Colors.amber
                            : (selected
                                ? ZienaColors.white
                                : ZienaColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shift.periodLabelKey.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? ZienaColors.white
                              : ZienaColors.textSecondary,
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
