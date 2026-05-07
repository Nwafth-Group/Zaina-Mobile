import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../../../widgets/success_dialog.dart';
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
    ('worker_no_show', 'worker_no_show'),
    ('late_arrival', 'late_arrival'),
    ('poor_quality', 'poor_quality'),
    ('wrong_charges', 'wrong_charges'),
    ('other', 'other'),
  ];

  String _selectedReason = 'other';
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<BookingDetailCubit>().submitReport(
      bookingId: widget.bookingId,
      reason: _selectedReason,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingDetailCubit, BookingDetailState>(
      listener: (context, state) {
        if (state is BookingReportSuccess) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (_) => SuccessDialog(
              icon: Icons.notifications_active_rounded,
              title: 'report_submitted'.tr(),
              message: 'report_submitted_msg'.tr(),
            ),
          );
        }
        if (state is BookingDetailError) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: ZienaColors.error,
          ));
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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

            // Reason radio list
            ..._reasons.map((r) => RadioListTile<String>(
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
              onChanged: (v) => setState(() => _selectedReason = v!),
            )),

            // Description
            Container(
              decoration: BoxDecoration(
                color: ZienaColors.bg1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ZienaColors.greyBorder),
              ),
              child: CustomTextField(
                controller: _descCtrl,
                maxLines: 3,
                hintText: 'describe_issue_optional'.tr(),
                border: 0,
                borderRadius: 14,
                fillColor: ZienaColors.bg1,
                contentPadding: const EdgeInsets.all(16),
                ),
              ),

            const SizedBox(height: 20),

            BlocBuilder<BookingDetailCubit, BookingDetailState>(
              builder: (_, state) {
                final loading = state is BookingActionLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ZienaButton(
                    text: 'submit_report'.tr(),
                    onTap: loading ? null : _submit,
                    isLoading: loading,
                    disabledBackgroundColor:
                        ZienaColors.primary.withOpacity(0.4),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
