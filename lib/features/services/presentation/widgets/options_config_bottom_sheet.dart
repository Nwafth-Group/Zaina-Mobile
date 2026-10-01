import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_selection_data.dart';
import '../../data/model/booking_validation_exception.dart';
import '../../data/model/options_config_result.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/repository/services_repository.dart';
import 'coverage_error_dialog.dart';

/// Step 1 of the options-based booking flow (services 6-11, e.g. Sofa
/// Cleaning): pick one or more priced options, a quantity for each, and an
/// optional note, then "Check Availability" calls /bookings/available-dates
/// with { service_id, address_id, options, note }. Returns an
/// [OptionsConfigResult] on success, or null if dismissed.
Future<OptionsConfigResult?> showOptionsConfigBottomSheet({
  required BuildContext context,
  required ServiceDetailModel service,
}) {
  return showModalBottomSheet<OptionsConfigResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => OptionsConfigBottomSheet(service: service),
  );
}

class OptionsConfigBottomSheet extends StatefulWidget {
  final ServiceDetailModel service;
  const OptionsConfigBottomSheet({super.key, required this.service});

  @override
  State<OptionsConfigBottomSheet> createState() =>
      _OptionsConfigBottomSheetState();
}

class _OptionsConfigBottomSheetState extends State<OptionsConfigBottomSheet> {
  /// option id -> chosen quantity. An option is "selected" iff its id is here.
  final Map<int, int> _quantities = {};
  final _noteController = TextEditingController();
  bool _isChecking = false;

  bool get _hasSelection => _quantities.isNotEmpty;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleOption(ServiceOptionModel option) {
    setState(() {
      if (_quantities.containsKey(option.id)) {
        _quantities.remove(option.id);
      } else {
        _quantities[option.id] = option.minQty.clamp(1, option.maxQty);
      }
    });
  }

  void _changeQuantity(ServiceOptionModel option, int delta) {
    final current = _quantities[option.id];
    if (current == null) return;
    final next = current + delta;
    if (next < option.minQty || next > option.maxQty) return;
    setState(() => _quantities[option.id] = next);
  }

  List<BookingOptionItem> get _selectedItems => widget.service.options
      .where((o) => _quantities.containsKey(o.id))
      .map((o) => BookingOptionItem.fromOption(o, _quantities[o.id]!))
      .toList();

  Future<void> _checkAvailability() async {
    if (!_hasSelection || _isChecking) return;
    setState(() => _isChecking = true);
    final note = _noteController.text.trim();
    try {
      final dates = await sl<ServicesRepository>().fetchAvailableDates(
        serviceId: widget.service.id,
        addressId: widget.service.addressId,
        options: _selectedItems,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      Navigator.pop(
        context,
        OptionsConfigResult(
          options: _selectedItems,
          note: note.isEmpty ? null : note,
          availableDates: dates,
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
                ...widget.service.options.map((option) {
                  final selected = _quantities.containsKey(option.id);
                  return Column(
                    children: [
                      _optionRow(option, selected, locale),
                      if (selected) ...[
                        const SizedBox(height: 10),
                        _quantityRow(option),
                      ],
                      const SizedBox(height: 10),
                    ],
                  );
                }),
                const SizedBox(height: 2),
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
                    border:
                        Border.all(color: ZienaColors.primary.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 3,
                    style: const TextStyle(
                        fontSize: 13, color: ZienaColors.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                      hintText: 'add_note_hint_generic'.tr(),
                      hintStyle: const TextStyle(
                          fontSize: 13, color: ZienaColors.textHint),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_hasSelection && !_isChecking) ? _checkAvailability : null,
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
                        : Text(_hasSelection
                            ? 'check_availability'.tr()
                            : 'continue'.tr()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionRow(ServiceOptionModel option, bool selected, String locale) {
    return GestureDetector(
      onTap: () => _toggleOption(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ZienaColors.primary
                : ZienaColors.primary.withOpacity(0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.localizedName(locale),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? ZienaColors.primary
                      : ZienaColors.greyBorder,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: ZienaColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityRow(ServiceOptionModel option) {
    final quantity = _quantities[option.id] ?? option.minQty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'choose_number'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _circleIconButton(Icons.add, () => _changeQuantity(option, 1)),
              SizedBox(
                width: 64,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),
              _circleIconButton(Icons.remove, () => _changeQuantity(option, -1)),
            ],
          ),
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
