import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/features/services/data/model/booking_selection_data.dart';
import 'package:zeina/features/services/data/model/service_feature_model.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_validation_model.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/visit_type_model.dart';
import '../../data/repository/services_repository.dart';
import 'booking_calendar.dart';
import 'coverage_error_dialog.dart';

/// Shows the booking sheet for a service, after a visit type has been chosen.
/// Validates the selection against /customer/bookings/validate before
/// closing; [onProceed] only fires once that call succeeds, with both the
/// raw [BookingSelectionData] and the server's [BookingValidationModel]
/// (assigned worker ids + final pricing) — pass both into the checkout screen.
Future<void> showBookingBottomSheet({
  required BuildContext context,
  required ServiceDetailModel service,
  required VisitTypeModel visitType,
  required void Function(
      BookingSelectionData data,
      BookingValidationModel validation,
      ) onProceed,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BookingBottomSheet(
      service: service,
      visitType: visitType,
      onProceed: onProceed,
    ),
  );
}

class BookingBottomSheet extends StatefulWidget {
  final ServiceDetailModel service;
  final VisitTypeModel visitType;
  final void Function(
      BookingSelectionData data,
      BookingValidationModel validation,
      ) onProceed;

  const BookingBottomSheet({
    super.key,
    required this.service,
    required this.visitType,
    required this.onProceed,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  Set<DateTime> _selectedDates = {};
  ServiceShiftModel? _selectedShift;
  int? _selectedWorkerCount;
  final Set<int> _selectedWorkerIds = {};
  bool _isSubmitting = false;

  late final List<PreferredWorkerModel> _activeWorkers;

  int get _requiredDays =>
      widget.visitType.type == VisitTypeEnum.threeDaysPerWeek ? 3 : 1;

  /// How many preferred workers the user may pick — capped by how many
  /// service providers they've chosen (not the service's max_workers).
  int get _maxPreferredWorkers => _selectedWorkerCount ?? 1;

  bool get _isValid =>
      _selectedDates.length == _requiredDays &&
          _selectedShift != null &&
          _selectedWorkerCount != null;

  @override
  void initState() {
    super.initState();
    _activeWorkers =
        widget.service.preferredWorkers.where((w) => w.isActive).toList();
    if (widget.service.availableShifts.isNotEmpty) {
      _selectedShift = widget.service.availableShifts.first;
    }
    _selectedWorkerCount = widget.service.minWorkers;
  }

  void _onWorkerCountChanged(int count) {
    setState(() {
      _selectedWorkerCount = count;
      // Trim any excess preferred-worker selections if the cap just shrank.
      while (_selectedWorkerIds.length > count) {
        _selectedWorkerIds.remove(_selectedWorkerIds.last);
      }
    });
  }

  void _toggleWorker(int workerId) {
    setState(() {
      if (widget.service.maxWorkers <= 1) {
        // Single-select behaviour (acts like the old Radio).
        _selectedWorkerIds
          ..clear()
          ..add(workerId);
        return;
      }
      if (_selectedWorkerIds.contains(workerId)) {
        _selectedWorkerIds.remove(workerId);
        return;
      }
      if (_selectedWorkerIds.length >= _maxPreferredWorkers) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'You can select up to $_maxPreferredWorkers preferred worker(s)'),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
      _selectedWorkerIds.add(workerId);
    });
  }

  Future<void> _handleProceed() async {
    if (!_isValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final validation = await sl<ServicesRepository>().validateBooking(
        serviceId: widget.service.id,
        visitType: widget.visitType.type,
        addressId: widget.service.addressId,
        dates: _selectedDates.toList()..sort(),
        startTime: _selectedShift!.startLabel,
        workersCount: _selectedWorkerCount!,
        preferredWorkerIds:
        _selectedWorkerIds.isEmpty ? null : _selectedWorkerIds.toList(),
      );

      if (!mounted) return;
      final selection = BookingSelectionData(
        serviceId: widget.service.id,
        visitType: widget.visitType,
        selectedDates: _selectedDates.toList()..sort(),
        shift: _selectedShift!,
        workerCount: _selectedWorkerCount!,
        preferredWorkerIds: _selectedWorkerIds.toList(),
      );
      Navigator.pop(context);
      widget.onProceed(selection, validation);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = e is BookingValidationException
          ? e.displayMessage
          : 'err_generic'.tr();
      showCoverageErrorDialog(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
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
                    _sectionTitle('service_date'),
                    if (_requiredDays > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'please_select_days'.tr(args: ['$_requiredDays']),
                          style: const TextStyle(
                            color: ZienaColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    BookingCalendar(
                      availableDates: widget.service.availableDates,
                      selectedDates: _selectedDates,
                      maxSelectable: _requiredDays,
                      onChanged: (dates) => setState(() => _selectedDates = dates),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle('service_period'),
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
                    const SizedBox(height: 20),
                    _sectionTitle('number_of_workers_title'),
                    const SizedBox(height: 8),
                    _buildWorkerCountRow(),
                    if (_activeWorkers.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionTitle('preferred_workers'),
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 8),
                        child: Text(
                          'choose_preferred_or_random'.tr(),
                          style: const TextStyle(
                            color: ZienaColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _buildPreferredWorkers(),
                    ],
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
                    onPressed: (_isValid && !_isSubmitting) ? _handleProceed : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      disabledBackgroundColor: ZienaColors.greyBorder,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ZienaColors.white,
                      ),
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

  Widget _sectionTitle(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        key.tr(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: ZienaColors.textPrimary,
        ),
      ),
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
                        size: 12,
                        color: selected
                            ? ZienaColors.white
                            : ZienaColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        shift.periodLabelKey.tr(),
                        style: TextStyle(
                          fontSize: 11,
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

  Widget _buildWorkerCountRow() {
    final options = [
      for (int i = widget.service.minWorkers; i <= widget.service.maxWorkers; i++) i
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((count) {
        final selected = _selectedWorkerCount == count;
        return GestureDetector(
          onTap: () => _onWorkerCountChanged(count),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? ZienaColors.primary : ZienaColors.white,
              borderRadius: BorderRadius.circular(12),
              border:
              selected ? null : Border.all(color: ZienaColors.greyBorder),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? ZienaColors.white : ZienaColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreferredWorkers() {
    // maxWorkers <= 1 → single-select (Radio). Otherwise → multi-select
    // (Checkbox), capped at however many providers were chosen above.
    final useCheckbox = widget.service.maxWorkers > 1;

    return Column(
      children: _activeWorkers.map((worker) {
        final selected = _selectedWorkerIds.contains(worker.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _WorkerTile(
            name: worker.name,
            rating: worker.rating,
            image: worker.image,
            nationality: worker.nationality,
            selected: selected,
            useCheckbox: useCheckbox,
            onTap: () => _toggleWorker(worker.id),
          ),
        );
      }).toList(),
    );
  }
}

class _WorkerTile extends StatelessWidget {
  final String name;
  final double? rating;
  final String? image;
  final String? nationality;
  final bool selected;
  final bool useCheckbox;
  final VoidCallback onTap;

  const _WorkerTile({
    required this.name,
    required this.rating,
    required this.image,
    this.nationality,
    required this.selected,
    required this.useCheckbox,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: ZienaColors.bg3,
              backgroundImage: image != null ? NetworkImage(image!) : null,
              child: image == null
                  ? const Icon(Icons.person, color: ZienaColors.primary)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ZienaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.textPrimary,
                    ),
                  ),
                  if (nationality != null && nationality!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.flag_outlined,
                            size: 12, color: ZienaColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          nationality!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ZienaColors.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (useCheckbox)
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: ZienaColors.primary,
              )
            else
              Radio<bool>(
                value: true,
                groupValue: selected,
                onChanged: (_) => onTap(),
                activeColor: ZienaColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}