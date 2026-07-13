import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/ziena_button.dart';
import '../cubit/bookings_cubit.dart';

class ReportSheet extends StatefulWidget {
  final int bookingId;
  const ReportSheet({super.key, required this.bookingId});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _reasons = [
    ('worker_didnt_show_up', 'worker_no_show'),
    ('late_arrival', 'late_arrival'),
    ('poor_service_quality', 'poor_quality'),
    ('wrong_charges', 'wrong_charges'),
    ('other', 'other'),
  ];

  String _selectedReason = 'other';
  final _descCtrl = TextEditingController();
  bool _descError = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() {
      if (_descError && _descCtrl.text.trim().isNotEmpty) {
        setState(() => _descError = false);
      }
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == 'other' && _descCtrl.text.trim().isEmpty) {
      setState(() => _descError = true);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await context.read<BookingDetailCubit>().submitReport(
        bookingId: widget.bookingId,
        reason: _selectedReason,
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      if (!mounted) return;
      // Signal success to the caller via the pop value — the caller (still
      // mounted after this sheet closes) shows the success dialog, rather
      // than this sheet trying to show one from its own about-to-be-disposed
      // context.
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = e is String ? e : 'err_generic'.tr();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: ZienaColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            Text('report_issue'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 16),

            // Reason radio list — wrapped in its own Material so the
            // RadioListTiles' background/ink-splash effects render properly.
            Material(
              type: MaterialType.transparency,
              child: Column(
                children: _reasons.map((r) => RadioListTile<String>(
                  value: r.$1,
                  groupValue: _selectedReason,
                  title: Text(r.$2.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: ZienaColors.textPrimary,
                      )),
                  activeColor: ZienaColors.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (v) => setState(() {
                    _selectedReason = v!;
                    if (v != 'other') _descError = false;
                  }),
                )).toList(),
              ),
            ),

            // Description
            Container(
              decoration: BoxDecoration(
                color: ZienaColors.bg1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _descError ? ZienaColors.error : ZienaColors.greyBorder,
                  width: _descError ? 1.4 : 1,
                ),
              ),
              child: CustomTextField(
                controller: _descCtrl,
                maxLines: 3,
                hintText: _selectedReason == 'other'
                    ? 'describe_issue_required'.tr()
                    : 'describe_issue_optional'.tr(),
                border: 0,
                borderRadius: 14,
                fillColor: ZienaColors.bg1,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            if (_descError) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'this_field_required'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZienaColors.error,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ZienaButton(
                text: 'submit_report'.tr(),
                onTap: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
                disabledBackgroundColor:
                ZienaColors.primary.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}