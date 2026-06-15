import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/filter_models.dart';
import '../cubit/filter_cubit.dart';

class FilterScreen extends StatefulWidget {
  /// Current params (so re-opening preserves state)
  final FilterParams initialParams;

  const FilterScreen({
    super.key,
    required this.initialParams,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late FilterParams _params;

  // Local UI state
  LocationItem? _selectedCity;
  LocationItem? _selectedArea;
  RangeValues _priceRange = const RangeValues(50, 500);
  double? _selectedRating;
  DateTime? _selectedDate;
  TimeSlotOption? _selectedTimeSlot;

  static const _ratingOptions = [4.5, 4.0, 3.5];
  static const _timeSlots = [
    TimeSlotOption(label: '09:00 AM - 12:00 PM', startTime: '09:00', endTime: '12:00'),
    TimeSlotOption(label: '12:00 PM - 03:00 PM', startTime: '12:00', endTime: '15:00'),
    TimeSlotOption(label: '03:00 PM - 06:00 PM', startTime: '15:00', endTime: '18:00'),
    TimeSlotOption(label: '06:00 PM - 09:00 PM', startTime: '18:00', endTime: '21:00'),
  ];

  @override
  void initState() {
    super.initState();
    _params = widget.initialParams;
    _priceRange = RangeValues(
      _params.minPrice,
      _params.maxPrice,
    );
    _selectedRating = _params.minRating;
    if (_params.date != null) {
      _selectedDate = DateTime.tryParse(_params.date!);
    }
    if (_params.startTime != null) {
      _selectedTimeSlot = _timeSlots.firstWhere(
        (s) => s.startTime == _params.startTime && s.endTime == _params.endTime,
        orElse: () => _timeSlots.first,
      );
    }

    // Load cities and categories on open
    context.read<FilterCubit>().loadCities(governorateId: 1);
    context.read<FilterCubit>().loadCategories();
  }

  void _toggleCategory(int id) {
    final ids = List<int>.from(_params.categoryIds);
    ids.contains(id) ? ids.remove(id) : ids.add(id);
    setState(() => _params = _params.copyWith(categoryIds: ids));
  }

  void _onCitySelected(LocationItem? city) {
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
      _params = _params.copyWith(
        cityId: city?.id,
        clearArea: true,
      );
    });
    if (city != null) {
      context.read<FilterCubit>().loadAreas(city.id);
    }
  }

  void _onAreaSelected(LocationItem? area) {
    setState(() {
      _selectedArea = area;
      _params = _params.copyWith(areaId: area?.id);
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
        _params = _params.copyWith(
          date:
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
        );
      });
    }
  }

  void _reset() {
    setState(() {
      _params           = const FilterParams();
      _selectedCity     = null;
      _selectedArea     = null;
      _priceRange       = const RangeValues(50, 500);
      _selectedRating   = null;
      _selectedDate     = null;
      _selectedTimeSlot = null;
    });
  }

  void _apply() {
    final finalParams = _params.copyWith(
      minPrice:  _priceRange.start,
      maxPrice:  _priceRange.end,
      minRating: _selectedRating,
      date:      _selectedDate != null
          ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
          : null,
      clearDate: _selectedDate == null,
      startTime: _selectedTimeSlot?.startTime,
      endTime:   _selectedTimeSlot?.endTime,
      clearTime: _selectedTimeSlot == null,
    );
    Navigator.pop(context, finalParams);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('filter'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text('reset'.tr(),
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: ZienaColors.primary,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(children: [

          // ── Category ───────────────────────────────────────────────────────
          _SectionCard(
            title: 'category'.tr(),
            child: BlocBuilder<FilterCubit, FilterState>(
              builder: (context, state) {
                final data = state is FilterLocationsLoaded
                    ? state.data
                    : state is FilterLocationsLoading
                    ? state.data
                    : context.read<FilterCubit>().data;
                final allCategories = data.categories;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DropdownField<int>(
                        hint: data.categoriesLoading
                            ? 'loading'.tr()
                            : 'select_category'.tr(),
                        items: allCategories
                            .where((c) => !_params.categoryIds.contains(c.id))
                            .map((c) => DropdownMenuItem<int>(
                          value: c.id,
      
                          child: Text(lang == 'ar' ? c.nameAr : c.nameEn,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: ZienaColors.textPrimary)),
                        ))
                            .toList(),
                        onChanged: (id) {
                          if (id != null) _toggleCategory(id);
                        },
                      ),
                    
                    const SizedBox(height: 12),
                    if (_params.categoryIds.isNotEmpty)
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: _params.categoryIds.map((id) {
                          final cat = allCategories.firstWhere(
                                (c) => c.id == id,
                            orElse: () => CategoryModel(
                                id: id, nameAr: '$id', nameEn: '$id', status: ''),
                          );
                          return _CategoryChip(
                            label: lang == 'ar' ? cat.nameAr : cat.nameEn,
                            onRemove: () => _toggleCategory(id),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Location ────────────────────────────────────────────────────────
          _SectionCard(
            title: 'location'.tr(),
            child: BlocBuilder<FilterCubit, FilterState>(
              builder: (context, state) {
                final data = state is FilterLocationsLoaded
                    ? state.data
                    : state is FilterLocationsLoading
                    ? state.data
                    : context.read<FilterCubit>().data;

                return Row(children: [
                  // City
                  Expanded(child: _DropdownField(
                    prefixIcon: Icons.location_on_outlined,
                    hint: data.citiesLoading
                        ? 'loading'.tr()
                        : 'city'.tr(),
                    value: _selectedCity?.id,
                    items: data.cities.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: ZienaColors.primary),
                        const SizedBox(width: 6),
                        Text(c.localized(lang), style: const TextStyle(fontSize: 13)),
                      ]),
                    )).toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final city =
                      data.cities.firstWhere((c) => c.id == id);
                      _onCitySelected(city);
                    },
                  )),
                  const SizedBox(width: 10),
                  // Area
                  Expanded(child: _DropdownField(
                    prefixIcon: Icons.location_on_outlined,
                    hint: data.areasLoading
                        ? 'loading'.tr()
                        : _selectedCity == null
                        ? 'area'.tr()
                        : 'area'.tr(),
                    value: _selectedArea?.id,
                    items: data.areas.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: ZienaColors.primary),
                        const SizedBox(width: 6),
                        Text(a.localized(lang), style: const TextStyle(fontSize: 13)),
                      ]),
                    )).toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final area =
                      data.areas.firstWhere((a) => a.id == id);
                      _onAreaSelected(area);
                    },
                  )),
                ]);
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Price Range ─────────────────────────────────────────────────────
          _SectionCard(
            title: 'price_range'.tr(),
            trailingWidget: Text(
              '${_priceRange.start.toInt()} - ${_priceRange.end.toInt()}',
              style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: ZienaColors.primary,
              ),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: ZienaColors.primary,
                inactiveTrackColor: ZienaColors.bg4,
                trackHeight: 4,
                overlayColor: ZienaColors.primary.withValues(alpha: 0.1),
                rangeThumbShape: const _BorderedRangeThumb(),
              ),
              child: RangeSlider(
                values: _priceRange,
                min:  0,
                max:  1000,
                divisions: 100,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Rating ──────────────────────────────────────────────────────────
          _SectionCard(
            title: 'rating'.tr(),
            child: Column(
              children: _ratingOptions.map((r) {
                return GestureDetector(
                  onTap: () => setState(() =>
                  _selectedRating = _selectedRating == r ? null : r),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFB800), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text('$r & up',
                          style: const TextStyle(
                              fontSize: 14, color: ZienaColors.textPrimary))),
                      _RadioDot(selected: _selectedRating == r),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // ── Availability ────────────────────────────────────────────────────
          _SectionCard(
            title: 'availability'.tr(),
            child: Column(children: [
              // Date
              GestureDetector(
                onTap: _pickDate,
                child: _LocationRow(
                  icon: Icons.calendar_month_outlined,
                  label: _selectedDate != null
                      ? DateFormat('dd MMM, yyyy').format(_selectedDate!)
                      : 'select_date'.tr(),
                  hasValue: _selectedDate != null,
                ),
              ),
              const SizedBox(height: 10),
              // Time slot
              _DropdownField<TimeSlotOption>(
                prefixIcon: Icons.access_time_rounded,
                hint: 'select_time_slot'.tr(),
                value: _selectedTimeSlot,
                items: _timeSlots.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.label,
                      style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) =>
                    setState(() => _selectedTimeSlot = v),
              ),
            ]),
          ),
        ]),
      ),

      // ── Bottom bar ──────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: const BoxDecoration(color: ZienaColors.white),
        child: Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZienaColors.primary,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('apply'.tr(),
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: ZienaColors.primary,
                side: const BorderSide(color: ZienaColors.primary),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('cancel'.tr(),
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: ZienaColors.primary,
                  )),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailingWidget;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6, offset: const Offset(0, 2),
        )],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ))),
            if (trailingWidget != null) trailingWidget!,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Dropdown field ────────────────────────────────────────────────────────────
class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final double? h;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const _DropdownField({
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.prefixIcon,
    this.h = 45,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h??45,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ZienaColors.bg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Row(children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: 15, color: ZienaColors.primary),
              const SizedBox(width: 6),
            ],
            Text(hint,
                style: const TextStyle(
                    fontSize: 13, color: ZienaColors.textPrimary)),
          ]),
          selectedItemBuilder: prefixIcon != null
              ? (context) => items.map((item) => Row(children: [
                    Icon(prefixIcon, size: 15, color: ZienaColors.primary),
                    const SizedBox(width: 6),
                    Flexible(child: item.child),
                  ])).toList()
              : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: ZienaColors.textSecondary, size: 18),
          items: items,
          onChanged: onChanged,
          style: const TextStyle(
              fontSize: 13, color: ZienaColors.textPrimary),
          dropdownColor: ZienaColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _CategoryChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: ZienaColors.bg3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: ZienaColors.textPrimary,
            )),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close,
              size: 14, color: ZienaColors.textSecondary),
        ),
      ]),
    );
  }
}

// ── Radio dot ─────────────────────────────────────────────────────────────────
class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: ZienaColors.primary,
          width: 2,
        ),
      ),
      child: selected
          ? Center(child: Container(
        width: 12, height: 12,
        decoration: const BoxDecoration(
            color: ZienaColors.primary, shape: BoxShape.circle),
      ))
          : null,
    );
  }
}

class _BorderedRangeThumb extends RangeSliderThumbShape {
  const _BorderedRangeThumb();

  static const double _radius = 10;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.fromRadius(_radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = true,
    bool isOnTop = false,
    TextDirection textDirection = TextDirection.ltr,
    required SliderThemeData sliderTheme,
    Thumb thumb = Thumb.start,
    bool isPressed = false,
  }) {
    final canvas = context.canvas;

    canvas.drawCircle(center, _radius, Paint()..color = ZienaColors.bg3);

    canvas.drawCircle(
      center,
      _radius,
      Paint()
        ..color = ZienaColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }
}

// ── Location row (for date display) ──────────────────────────────────────────
class _LocationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool hasValue;

  const _LocationRow({
    required this.icon,
    required this.label,
    this.hasValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue
              ? ZienaColors.primary.withOpacity(0.4)
              : ZienaColors.greyBorder,
          width: 0.8,
        ),
      ),
      child: Row(children: [
        Icon(icon, size: 16,
            color: hasValue ? ZienaColors.primary : ZienaColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(label,
            style: TextStyle(
              fontSize: 13,
              color: hasValue
                  ? ZienaColors.textPrimary
                  : ZienaColors.textHint,
            ))),
        const Icon(Icons.keyboard_arrow_down,
            size: 16, color: ZienaColors.textSecondary),
      ]),
    );
  }
}