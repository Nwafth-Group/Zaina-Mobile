
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_small_button.dart';
import '../../../services/data/model/service_detail_model.dart';
import '../../../services/presentation/widgets/booking_calendar.dart';
import '../../data/model/reschedule_result.dart';

/// Shows a reschedule sheet for configurable-hourly services (Hospitality
/// Worker/Babysitter-style — start time is chosen via stepper rather than
/// fixed shift chips).
///
/// NOTE: no confirmed UI/API sample was given for rescheduling THIS service
/// type specifically (only service 1's fixed-shift reschedule UI was
/// provided) — this is a reasonable best-effort analog of the existing
/// "configure hourly" pattern, not a confirmed design. Flag if it needs
/// changing once you have the real spec for it.
Future<RescheduleResult?> showRescheduleConfigurableSheet({
  required BuildContext context,
  required ServiceDetailModel service,
}) {
  return showModalBottomSheet<RescheduleResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RescheduleConfigurableSheet(service: service),
  );
}

class _RescheduleConfigurableSheet extends StatefulWidget {
  final ServiceDetailModel service;
  const _RescheduleConfigurableSheet({required this.service});

  @override
  State<_RescheduleConfigurableSheet> createState() =>
      _RescheduleConfigurableSheetState();
}

class _RescheduleConfigurableSheetState
    extends State<_RescheduleConfigurableSheet> {
  Set<DateTime> _selectedDates = {};
  late String _startTime;

  bool get _isValid => _selectedDates.length == 1;

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  String _fromMinutes(int minutes) {
    final wrapped = ((minutes % (24 * 60)) + 24 * 60) % (24 * 60);
    final h = wrapped ~/ 60;
    final m = wrapped % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String _shortTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  String _formatTime12h(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1].padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    _startTime = _shortTime(widget.service.startTime);
  }

  void _changeStartTime(int deltaMinutes) {
    final minMinutes = _toMinutes(_shortTime(widget.service.startTime));
    final endMinutes = _toMinutes(_shortTime(widget.service.endTime));
    final maxMinutes = endMinutes - widget.service.defaultDuration * 60;
    var next = _toMinutes(_startTime) + deltaMinutes;
    if (next < minMinutes) next = minMinutes;
    if (next > maxMinutes) next = maxMinutes;
    setState(() => _startTime = _fromMinutes(next));
  }

  void _onSave() {
    if (!_isValid) return;
    Navigator.pop(
      context,
      RescheduleResult(dates: _selectedDates.toList(), startTime: _startTime),
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

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: ZienaColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ZienaColors.primary.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'start_service_time'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ZienaColors.textPrimary,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _circleIconButton(Icons.add, () => _changeStartTime(60)),
                              SizedBox(
                                width: 74,
                                child: Text(
                                  _formatTime12h(_startTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ZienaColors.textPrimary,
                                  ),
                                ),
                              ),
                              _circleIconButton(
                                  Icons.remove, () => _changeStartTime(-60)),
                            ],
                          ),
                        ],
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
                    const SizedBox(height: 8),
                    BookingCalendar(
                      availableDates: widget.service.availableDates,
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

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ZienaColors.primary.withOpacity(0.5)),
        ),
        child: Icon(icon, size: 16, color: ZienaColors.primary),
      ),
    );
  }
}