import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/wallet_model.dart';

class FilterSheet extends StatefulWidget {
  final WalletFilter activeFilter;
  final String? fromDate;
  final String? toDate;
  final void Function(WalletFilter, String?, String?) onApply;

  const FilterSheet({
    super.key,
    required this.activeFilter,
    this.fromDate,
    this.toDate,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late WalletFilter _selected;
  DateTime? _from;
  DateTime? _to;

  final _dateOptions = [
    WalletFilter.today,
    WalletFilter.last7Days,
    WalletFilter.last30Days,
  ];

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void initState() {
    super.initState();
    _selected = widget.activeFilter;
    if (widget.fromDate != null) _from = DateTime.tryParse(widget.fromDate!);
    if (widget.toDate != null)   _to   = DateTime.tryParse(widget.toDate!);
  }

  Future<void> _pickFrom() async {
    final d = await _datePicker(initial: _from);
    if (d != null) setState(() { _from = d; _selected = WalletFilter.custom; });
  }

  Future<void> _pickTo() async {
    final d = await _datePicker(initial: _to ?? _from);
    if (d != null) setState(() { _to = d; _selected = WalletFilter.custom; });
  }

  Future<DateTime?> _datePicker({DateTime? initial}) {
    return showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: ZienaColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
  }

  void _apply() {
    Navigator.pop(context);
    widget.onApply(
      _selected,
      _from != null ? _fmt(_from!) : null,
      _to   != null ? _fmt(_to!)   : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: ZienaColors.greyBorder,
                borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Center(child: Text('filter_by_date'.tr(),
              style: const TextStyle(
               fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ))),
          const SizedBox(height: 20),

          Text('rating'.tr(),
              style: const TextStyle(
               fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 12),

          // Preset options
          ..._dateOptions.map((opt) => GestureDetector(
            onTap: () => setState(() => _selected = opt),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Expanded(child: Text(opt.label,
                    style: const TextStyle(
                     fontSize: 14,
                      color: ZienaColors.textPrimary,
                    ))),
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selected == opt
                        ? ZienaColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: _selected == opt
                          ? ZienaColors.primary
                          : ZienaColors.greyBorder,
                      width: 2,
                    ),
                  ),
                  child: _selected == opt
                      ? const Icon(Icons.check,
                      color: Colors.white, size: 13)
                      : null,
                ),
              ]),
            ),
          )),

          const SizedBox(height: 4),

          // Custom range
          Text('custom_range'.tr(),
              style: const TextStyle(
               fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              )),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DateField(
              hint: 'dd/mm/yyyy',
              value: _from != null ? _fmtDisplay(_from!) : null,
              onTap: _pickFrom,
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('to'.tr(),
                  style: const TextStyle(
                   fontSize: 13,
                    color: ZienaColors.textSecondary,
                  )),
            ),
            Expanded(child: _DateField(
              hint: 'dd/mm/yyyy',
              value: _to != null ? _fmtDisplay(_to!) : null,
              onTap: _pickTo,
            )),
          ]),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
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
                   fontSize: 16,
                    fontWeight: FontWeight.w600, color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;
  const _DateField({required this.hint, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? ZienaColors.primary
                : ZienaColors.greyBorder,
            width: value != null ? 1.3 : 0.8,
          ),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 14, color: ZienaColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(
            value ?? hint,
            style: TextStyle(
             fontSize: 12,
              color: value != null
                  ? ZienaColors.textPrimary
                  : ZienaColors.textHint,
            ),
          )),
        ]),
      ),
    );
  }
}