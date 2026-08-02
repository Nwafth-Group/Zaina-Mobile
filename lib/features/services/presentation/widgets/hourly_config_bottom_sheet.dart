import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/hourly_config_result.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/repository/services_repository.dart';
import 'coverage_error_dialog.dart';

/// Shows the "configure hourly booking" sheet (start time / duration /
/// [gender] / [children + age groups] / worker count / [note]) for services
/// like Hospitality Worker or Babysitter, where availability depends on the
/// chosen combination rather than fixed shifts. Returns a [HourlyConfigResult]
/// once "Check Availability" succeeds, or null if dismissed without completing.
Future<HourlyConfigResult?> showHourlyConfigBottomSheet({
  required BuildContext context,
  required ServiceDetailModel service,
}) {
  return showModalBottomSheet<HourlyConfigResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => HourlyConfigBottomSheet(service: service),
  );
}

class HourlyConfigBottomSheet extends StatefulWidget {
  final ServiceDetailModel service;
  const HourlyConfigBottomSheet({super.key, required this.service});

  @override
  State<HourlyConfigBottomSheet> createState() =>
      _HourlyConfigBottomSheetState();
}

class _HourlyConfigBottomSheetState extends State<HourlyConfigBottomSheet> {
  late String _startTime; // "HH:mm"
  late int _duration;
  late String _gender;
  late int _workersCount;
  bool _isChecking = false;

  // Babysitter-style only:
  late int _numberOfChildren;
  late List<int> _childAgeGroupIds; // one per child, index-aligned
  final _noteController = TextEditingController();

  // Pedicure & Manicure-style only:
  late int _numberOfPersons;

  bool get _hasChildren => widget.service.hasChildren;
  bool get _hasPersonsCount => widget.service.hasPersonsCount;

  /// A single worker can cover `coveredPersonsPerWorker` persons. This is
  /// bounded by the service's overall max worker capacity, NOT by whichever
  /// worker count is currently selected — number of persons and number of
  /// service providers are independent steppers for this service.
  int get _maxPersons =>
      widget.service.coveredPersonsPerWorker * widget.service.maxWorkers;

  /// Fixed max hours a single worker can be scheduled for in one day,
  /// per the confirmed rule: "Each worker works a maximum of 8 hours per
  /// day." This is a flat constant, NOT derived from the service's own
  /// start_time/end_time window.
  static const int _maxWorkerHoursPerDay = 8;

  /// Pedicure & Manicure auto-scaling rule (confirmed formula):
  /// required_workers = ceil((number_of_persons × default_duration) ÷ 8).
  /// Each person takes `_duration` hours of service time; once the total
  /// exceeds what one worker can do in an 8-hour day, another worker is
  /// required to cover the rest within the same day.
  int get _requiredWorkersForPersons {
    final requiredHours = _numberOfPersons * _duration;
    final needed = (requiredHours / _maxWorkerHoursPerDay).ceil();
    return needed.clamp(1, widget.service.maxWorkers);
  }

  /// Babysitter per-age-group ratio formula (confirmed rule):
  /// For each selected child_age_group id, count how many children were
  /// assigned to it, then:
  ///   workers_needed_for_group = ceil(count / group.childrenCount) * group.requiredWorkerCount
  /// Calculated Min Workers = sum of workers_needed_for_group across all
  /// selected groups. If total_children >= 3, the result is floored at 2
  /// regardless of what the sum alone would give.
  int get _calculatedMinWorkersForChildren {
    final counts = <int, int>{};
    for (final groupId in _childAgeGroupIds) {
      counts[groupId] = (counts[groupId] ?? 0) + 1;
    }
    var total = 0;
    for (final entry in counts.entries) {
      final group = widget.service.childAgeGroups.firstWhere(
            (g) => g.id == entry.key,
        orElse: () => widget.service.childAgeGroups.first,
      );
      final denom = group.childrenCount > 0 ? group.childrenCount : 1;
      total += (entry.value / denom).ceil() * group.requiredWorkerCount;
    }
    if (_numberOfChildren >= 3 && total < 2) {
      total = 2;
    }
    return total;
  }

  // Pedicure & Manicure (hasPersonsCount) and Babysitter (hasChildren) each
  // have their own confirmed auto-scaling formula for the floor, both of
  // which ignore whatever min_workers the API sends and only defer to it as
  // a fallback floor; only the ceiling (max_workers) always comes from the
  // API.
  int get _minWorkersRequired {
    if (_hasPersonsCount) return _requiredWorkersForPersons;
    if (_hasChildren) {
      final calculated = _calculatedMinWorkersForChildren;
      final base = widget.service.minWorkers;
      final floor = calculated > base ? calculated : base;
      return floor.clamp(1, widget.service.maxWorkers);
    }
    return widget.service.minWorkers;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

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
    _duration = widget.service.defaultDuration;
    _gender = widget.service.workerGenderOptions.isNotEmpty
        ? widget.service.workerGenderOptions.first
        : '';
    _workersCount = _hasPersonsCount ? 1 : widget.service.minWorkers;

    _numberOfChildren = _hasChildren ? widget.service.minChildren.clamp(1, 1 << 30) : 0;
    _childAgeGroupIds = _hasChildren
        ? List.generate(
      _numberOfChildren,
          (_) => widget.service.childAgeGroups.first.id,
    )
        : [];

    _numberOfPersons = _hasPersonsCount ? 1 : 0;

    // Make sure the default worker count reflects whatever
    // _minWorkersRequired computes from the very first render — covers
    // Babysitter's per-age-group ratio formula (e.g. default children/age
    // groups already requiring 2+ workers) and Pedicure & Manicure's
    // persons/8-hour-day formula alike.
    if (_workersCount < _minWorkersRequired) {
      _workersCount = _minWorkersRequired.clamp(1, widget.service.maxWorkers);
    }

    // Defensive: if the service's own default start+duration somehow don't
    // fit its window, pull start time back so the very first render is valid.
    final endMinutes = _toMinutes(_shortTime(widget.service.endTime));
    final minMinutes = _toMinutes(_shortTime(widget.service.startTime));
    final latestStart = endMinutes - _duration * 60;
    if (latestStart >= minMinutes && _toMinutes(_startTime) > latestStart) {
      _startTime = _fromMinutes(latestStart);
    }
  }

  // void _changeStartTime(int deltaMinutes) {
  //   final minMinutes = _toMinutes(_shortTime(widget.service.startTime));
  //   // Cap start time so that start + duration still fits before end_time.
  //   final endMinutes = _toMinutes(_shortTime(widget.service.endTime));
  //   final maxMinutes = endMinutes - _duration * 60;
  //   var next = _toMinutes(_startTime) + deltaMinutes;
  //   if (next < minMinutes) next = minMinutes;
  //   if (next > maxMinutes) next = maxMinutes;
  //   if (next < minMinutes) return; // window too short for this duration at all
  //   setState(() => _startTime = _fromMinutes(next));
  // }

  void _changeStartTime(int deltaMinutes) {
    final minMinutes = _toMinutes(_shortTime(widget.service.startTime));
    final maxMinutes = _toMinutes(_shortTime(widget.service.endTime));

    var next = _toMinutes(_startTime) + deltaMinutes;

    if (next < minMinutes) next = minMinutes;
    if (next > maxMinutes) next = maxMinutes;

    setState(() => _startTime = _fromMinutes(next));
  }

  void _changeDuration(int delta) {
    final next = _duration + delta;
    if (next < widget.service.minDuration || next > widget.service.maxDuration) {
      return;
    }
    // Don't allow a duration that would push start+duration past end_time —
    // pull the start time back instead if needed, matching what the server
    // enforces ("Selected hours must be within the service window").
    final endMinutes = _toMinutes(_shortTime(widget.service.endTime));
    final minMinutes = _toMinutes(_shortTime(widget.service.startTime));
    final latestStartForNext = endMinutes - next * 60;
    if (latestStartForNext < minMinutes) {
      return; // this duration can't fit in the service window at all
    }
    setState(() {
      _duration = next;
      if (_toMinutes(_startTime) > latestStartForNext) {
        _startTime = _fromMinutes(latestStartForNext);
      }
    });
  }

  void _changeWorkersCount(int delta) {
    final next = _workersCount + delta;
    if (next < _minWorkersRequired || next > widget.service.maxWorkers) {
      return;
    }
    setState(() => _workersCount = next);
  }

  /// Keeps `_workersCount` tracking `_minWorkersRequired` in both
  /// directions after a persons/children/age-group change:
  ///  - Always bumps UP if the new requirement exceeds the current count.
  ///  - Bumps DOWN too, but only when the current count was sitting exactly
  ///    at the *previous* requirement — i.e. it was auto-set, not a
  ///    deliberate manual over-provision the user chose on top of the
  ///    minimum, which is left untouched.
  /// Call with the requirement captured *before* the state change, then
  /// perform the change, then call this from inside the same setState.
  void _syncWorkersCount(int oldRequiredMin) {
    final newRequiredMin = _minWorkersRequired;
    if (_workersCount < newRequiredMin) {
      _workersCount = newRequiredMin.clamp(1, widget.service.maxWorkers);
    } else if (_workersCount == oldRequiredMin && newRequiredMin < oldRequiredMin) {
      _workersCount = newRequiredMin.clamp(1, widget.service.maxWorkers);
    }
  }

  void _changeNumberOfPersons(int delta) {
    final next = _numberOfPersons + delta;
    if (next < 1 || next > _maxPersons) return;
    final oldRequiredMin = _minWorkersRequired;
    setState(() {
      _numberOfPersons = next;
      // Fewer/more persons may now need fewer/more workers to cover them
      // within one worker's 8-hour day — track the requirement either way.
      _syncWorkersCount(oldRequiredMin);
    });
  }

  void _cycleGender(int direction) {
    final options = widget.service.workerGenderOptions;
    if (options.isEmpty) return;
    final currentIndex = options.indexOf(_gender);
    final nextIndex = (currentIndex + direction + options.length) % options.length;
    setState(() => _gender = options[nextIndex]);
  }

  /// Changes a single child's age group (from the per-child dropdown), then
  /// re-checks the calculated minimum — moving a child between age groups
  /// (e.g. Toddler -> Infant) can change the required worker count even
  /// when the total number of children stays the same.
  void _setChildAgeGroup(int index, int groupId) {
    final oldRequiredMin = _minWorkersRequired;
    setState(() {
      _childAgeGroupIds[index] = groupId;
      _syncWorkersCount(oldRequiredMin);
    });
  }

  void _changeNumberOfChildren(int delta) {
    final next = _numberOfChildren + delta;
    if (next < widget.service.minChildren || next > widget.service.maxChildren) {
      return;
    }
    final oldRequiredMin = _minWorkersRequired;
    setState(() {
      _numberOfChildren = next;
      // Grow/shrink the age-group list to match, defaulting new slots to
      // the first available age group.
      if (_childAgeGroupIds.length < next) {
        _childAgeGroupIds.addAll(List.filled(
          next - _childAgeGroupIds.length,
          widget.service.childAgeGroups.first.id,
        ));
      } else if (_childAgeGroupIds.length > next) {
        _childAgeGroupIds = _childAgeGroupIds.sublist(0, next);
      }
      // Re-evaluate the calculated minimum (ratio formula + 3+ children
      // override) now that the count/group list changed, and track the
      // worker count either up or down to match.
      _syncWorkersCount(oldRequiredMin);
    });
  }

  Future<void> _checkAvailability() async {
    setState(() => _isChecking = true);
    try {
      final dates = await sl<ServicesRepository>().fetchAvailableDates(
        serviceId: widget.service.id,
        addressId: widget.service.addressId,
        startTime: _startTime,
        duration: _duration,
        // Omit gender entirely when there's no real choice (e.g. Babysitter,
        // which only ever offers "Female") — matches the confirmed real
        // request payload, which has no worker_gender key at all in that case.
        workerGender: widget.service.hasGenderChoice ? _gender : null,
        workersCount: _workersCount,
        numberOfChildren: _hasChildren ? _numberOfChildren : null,
        childAgeGroupIds: _hasChildren ? _childAgeGroupIds : null,
        numberOfPersons: _hasPersonsCount ? _numberOfPersons : null,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        HourlyConfigResult(
          startTime: _startTime,
          duration: _duration,
          workerGender: widget.service.hasGenderChoice ? _gender : null,
          workersCount: _workersCount,
          availableDates: dates,
          numberOfChildren: _hasChildren ? _numberOfChildren : null,
          childAgeGroupIds: _hasChildren ? _childAgeGroupIds : null,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          numberOfPersons: _hasPersonsCount ? _numberOfPersons : null,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isChecking = false);
      final message =
      e is BookingValidationException ? e.displayMessage : 'err_generic'.tr();
      showCoverageErrorDialog(context, message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ZienaColors.greyBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                _stepperRow(
                  label: 'start_service_time'.tr(),
                  valueText: _formatTime12h(_startTime),
                  onIncrement: () => _changeStartTime(60),
                  onDecrement: () => _changeStartTime(-60),
                ),
                // Number of persons (Pedicure & Manicure-style).
                if (_hasPersonsCount) ...[
                  const SizedBox(height: 12),
                  _stepperRow(
                    label: 'number_of_persons'.tr(),
                    valueText: '$_numberOfPersons',
                    onIncrement: () => _changeNumberOfPersons(1),
                    onDecrement: () => _changeNumberOfPersons(-1),
                  ),
                ],
                const SizedBox(height: 12),
                if (_hasPersonsCount) ...[
                  // Pedicure & Manicure-style order: workers row, then a
                  // read-only duration readout (this service has no
                  // has_duration_range, so duration isn't user-adjustable —
                  // matches the design's unused 'service_duration_hint' /
                  // 'hours_suffix' keys, e.g. "Service Duration (2 hours
                  // For each person) — 2 Hours").
                  _stepperRow(
                    label: 'service_providers_number'.tr(),
                    valueText: '$_workersCount',
                    onIncrement: () => _changeWorkersCount(1),
                    onDecrement: () => _changeWorkersCount(-1),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: ZienaColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: ZienaColors.primary.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'service_duration'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ZienaColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${'service_duration_hint'.tr()}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          '$_duration ${'hours_suffix'.tr()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _stepperRow(
                    label: 'service_duration'.tr(),
                    valueText: '$_duration',
                    onIncrement: () => _changeDuration(1),
                    onDecrement: () => _changeDuration(-1),
                  ),
                  // Gender picker only when there's an actual choice.
                  if (widget.service.hasGenderChoice) ...[
                    const SizedBox(height: 12),
                    _arrowRow(
                      label: 'service_providers_gender'.tr(),
                      valueText: _gender.tr(),
                      onLeft: () => _cycleGender(-1),
                      onRight: () => _cycleGender(1),
                    ),
                  ],
                  // Children count + per-child age group (Babysitter-style).
                  if (_hasChildren) ...[
                    const SizedBox(height: 12),
                    _stepperRow(
                      label: 'number_of_children'.tr(),
                      valueText: '$_numberOfChildren',
                      onIncrement: () => _changeNumberOfChildren(1),
                      onDecrement: () => _changeNumberOfChildren(-1),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        'childrens_age_group'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(_numberOfChildren, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _fieldContainer(
                          'child_label'.tr(args: ['${i + 1}']),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _childAgeGroupIds[i],
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: ZienaColors.primary),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ZienaColors.primary,
                              ),
                              items: widget.service.childAgeGroups
                                  .map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(g.localizedName(locale)),
                              ))
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                _setChildAgeGroup(i, value);
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                  ],
                  const SizedBox(height: 12),
                  _stepperRow(
                    label: 'service_providers_number'.tr(),
                    valueText: '$_workersCount',
                    onIncrement: () => _changeWorkersCount(1),
                    onDecrement: () => _changeWorkersCount(-1),
                  ),
                ],
                // Optional care notes (Babysitter-style).
                if (_hasChildren) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'add_note'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ZienaColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ZienaColors.primary.withOpacity(0.4)),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13, color: ZienaColors.textPrimary),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                        hintText: 'add_note_hint'.tr(),
                        hintStyle: const TextStyle(fontSize: 13, color: ZienaColors.textHint),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkAvailability,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      disabledBackgroundColor: ZienaColors.greyBorder,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: ZienaColors.white),
                    )
                        : Text('check_availability'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldContainer(String label, Widget trailing) {
    return Container(
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
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
          Flexible(child: trailing),
        ],
      ),
    );
  }

  Widget _stepperRow({
    required String label,
    required String valueText,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return _fieldContainer(
      label,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleIconButton(Icons.add, onIncrement),
          SizedBox(
            width: 64,
            child: Text(
              valueText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
          ),
          _circleIconButton(Icons.remove, onDecrement),
        ],
      ),
    );
  }

  Widget _arrowRow({
    required String label,
    required String valueText,
    required VoidCallback onLeft,
    required VoidCallback onRight,
  }) {
    return _fieldContainer(
      label,
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _circleIconButton(Icons.chevron_left, onLeft),
          SizedBox(
            width: 64,
            child: Text(
              valueText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
          ),
          _circleIconButton(Icons.chevron_right, onRight),
        ],
      ),
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