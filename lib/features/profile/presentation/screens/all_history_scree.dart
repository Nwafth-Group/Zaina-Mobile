import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/points_model.dart';
import '../cubit/points_cubit.dart';
import 'my_points_scree.dart';

class AllHistoryScreen extends StatefulWidget {
  const AllHistoryScreen({super.key});

  @override
  State<AllHistoryScreen> createState() => _AllHistoryScreenState();
}

class _AllHistoryScreenState extends State<AllHistoryScreen> {
  List<PointsHistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({String? filter, String? start, String? end}) async {
    setState(() => _loading = true);
    final items = await context.read<PointsCubit>().fetchHistory(
        filter: filter, startDate: start, endDate: end);
    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('history'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: ZienaColors.primary),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(
          color: ZienaColors.primary, strokeWidth: 2))
          : _items.isEmpty
          ? Center(child: Text('no_history_yet'.tr(),
          style: const TextStyle(color: ZienaColors.textSecondary)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (_, i) => HistoryTile(item: _items[i]),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZienaColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PointsFilterSheet(
        onApply: (filter, from, to) {
          Navigator.pop(context);
          _load(filter: filter == 'custom' ? 'custom' : filter,
              start: from, end: to);
        },
      ),
    );
  }
}

class _PointsFilterSheet extends StatefulWidget {
  final void Function(String filter, String? from, String? to) onApply;
  const _PointsFilterSheet({required this.onApply});

  @override
  State<_PointsFilterSheet> createState() => _PointsFilterSheetState();
}

class _PointsFilterSheetState extends State<_PointsFilterSheet> {
  String _selected = 'today';
  DateTime? _from;
  DateTime? _to;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String _disp(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  Future<void> _pickDate(bool isFrom) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
                primary: ZienaColors.primary, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        if (isFrom) _from = d; else _to = d;
        _selected = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(
                color: ZienaColors.greyBorder,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text('filter_by_date'.tr(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary)),
        const SizedBox(height: 20),
        Text('rating'.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary)),
        const SizedBox(height: 12),
        ...['today', 'last_7_days', 'last_30_days'].map((f) {
          final labels = {
            'today': 'Today',
            'last_7_days': 'Last 7 Days',
            'last_30_days': 'Last 30 Days',
          };
          return GestureDetector(
            onTap: () => setState(() => _selected = f),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Expanded(child: Text(labels[f]!,
                    style: const TextStyle(fontSize: 14,
                        color: ZienaColors.textPrimary))),
                _RadioDot(selected: _selected == f),
              ]),
            ),
          );
        }),
        const SizedBox(height: 8),
        Text('custom_range'.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _DateField(
            hint: 'dd/mm/yyyy',
            value: _from != null ? _disp(_from!) : null,
            onTap: () => _pickDate(true),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('to'.tr(), style: const TextStyle(
                  fontSize: 13, color: ZienaColors.textSecondary))),
          Expanded(child: _DateField(
            hint: 'dd/mm/yyyy',
            value: _to != null ? _disp(_to!) : null,
            onTap: () => _pickDate(false),
          )),
        ]),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onApply(
              _selected,
              _from != null ? _fmt(_from!) : null,
              _to   != null ? _fmt(_to!)   : null,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Text('apply'.tr(),
                style: const TextStyle(fontSize: 16,
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
          color: selected ? ZienaColors.primary : ZienaColors.greyBorder,
          width: 2),
    ),
    child: selected ? Center(child: Container(
      width: 12, height: 12,
      decoration: const BoxDecoration(
          color: ZienaColors.primary, shape: BoxShape.circle),
    )) : null,
  );
}

class _DateField extends StatelessWidget {
  final String hint;
  final String? value;
  final VoidCallback onTap;
  const _DateField({required this.hint, this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: value != null
                ? ZienaColors.primary
                : ZienaColors.greyBorder, width: 0.8),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today_outlined,
            size: 13, color: ZienaColors.primary),
        const SizedBox(width: 5),
        Expanded(child: Text(value ?? hint,
            style: TextStyle(fontSize: 11,
                color: value != null
                    ? ZienaColors.textPrimary
                    : ZienaColors.textHint))),
      ]),
    ),
  );
}