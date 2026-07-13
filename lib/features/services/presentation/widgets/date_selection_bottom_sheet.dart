import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_selection_data.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/booking_validation_model.dart';
import '../../data/model/hourly_config_result.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/visit_type_model.dart';
import '../../data/repository/services_repository.dart';
import 'booking_calendar.dart';
import 'coverage_error_dialog.dart';

/// Step 2 of the "configurable hourly" booking flow: pick a single date from
/// whatever /bookings/available-dates returned for the chosen config, then
/// validate and hand off to the same [BookingSelectionData] /
/// [BookingValidationModel] pair the fixed-shift flow produces — so
/// Checkout stays identical either way.
Future<void> showDateSelectionBottomSheet({
  required BuildContext context,
  required ServiceDetailModel service,
  required VisitTypeModel visitType,
  required HourlyConfigResult config,
  required void Function(
      BookingSelectionData data,
      BookingValidationModel validation,
      ) onProceed,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DateSelectionBottomSheet(
      service: service,
      visitType: visitType,
      config: config,
      onProceed: onProceed,
    ),
  );
}

class DateSelectionBottomSheet extends StatefulWidget {
  final ServiceDetailModel service;
  final VisitTypeModel visitType;
  final HourlyConfigResult config;
  final void Function(
      BookingSelectionData data,
      BookingValidationModel validation,
      ) onProceed;

  const DateSelectionBottomSheet({
    super.key,
    required this.service,
    required this.visitType,
    required this.config,
    required this.onProceed,
  });

  @override
  State<DateSelectionBottomSheet> createState() =>
      _DateSelectionBottomSheetState();
}

class _DateSelectionBottomSheetState extends State<DateSelectionBottomSheet> {
  Set<DateTime> _selectedDates = {};
  bool _isSubmitting = false;

  Future<void> _handleProceed() async {
    if (_selectedDates.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final validation = await sl<ServicesRepository>().validateBooking(
        serviceId: widget.service.id,
        visitType: widget.visitType.type,
        addressId: widget.service.addressId,
        dates: _selectedDates.toList(),
        startTime: widget.config.startTime,
        workersCount: widget.config.workersCount,
        preferredWorkerIds: null,
        duration: widget.config.duration,
        workerGender: widget.config.workerGender,
        numberOfChildren: widget.config.numberOfChildren,
        childAgeGroupIds: widget.config.childAgeGroupIds,
      );
      if (!mounted) return;
      final selection = BookingSelectionData(
        serviceId: widget.service.id,
        visitType: widget.visitType,
        selectedDates: _selectedDates.toList(),
        shift: ServiceShiftModel(
          startTime: widget.config.startTime,
          endTime: widget.config.endTime,
        ),
        workerCount: widget.config.workersCount,
        preferredWorkerIds: const [],
        duration: widget.config.duration,
        workerGender: widget.config.workerGender,
        numberOfChildren: widget.config.numberOfChildren,
        childAgeGroupIds: widget.config.childAgeGroupIds,
        note: widget.config.note,
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
                      'kindly_select_date'.tr(),
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
                      onChanged: (dates) => setState(() => _selectedDates = dates),
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
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedDates.isNotEmpty && !_isSubmitting)
                        ? _handleProceed
                        : null,
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
}