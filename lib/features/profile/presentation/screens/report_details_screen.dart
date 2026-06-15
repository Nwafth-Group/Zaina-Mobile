import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../../widgets/ziena_step_indicator.dart';
import '../../data/models/legal_model.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  const ReportDetailScreen({super.key, required this.report});

  static const _steps = ['Submitted', 'Under Review', 'Resolved'];

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
        title: Text('report_details'.tr(),
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: Stack(children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(children: [
            // Service card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ZienaColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: ZienaColors.greyBorder, width: 0.5),
              ),
              child: Row(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: ZienaColors.bg3,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.cleaning_services_rounded,
                      color: ZienaColors.primary, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (report.category != null)
                      Text(report.category!,
                          style: const TextStyle(
                            fontSize: 11, color: ZienaColors.primary,
                            fontWeight: FontWeight.w500,
                          )),
                    Text(report.serviceName,
                        style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        )),
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 11, color: ZienaColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(report.date,
                          style: const TextStyle(
                              fontSize: 11, color: ZienaColors.textSecondary)),
                    ]),
                  ],
                )),
              ]),
            ),
            const SizedBox(height: 16),

            // Status section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ZienaColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: ZienaColors.greyBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('report_status'.tr(),
                      style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      )),
                  const SizedBox(height: 20),

                  // Stepper
                  ZienaStepIndicator(
                    steps: _steps,
                    currentStep: report.statusStep,
                  ),
                  const SizedBox(height: 20),

                  // Status message box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: report.statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: report.statusColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.statusLabel,
                            style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: report.statusColor,
                            )),
                        if (report.statusMessage != null) ...[
                          const SizedBox(height: 4),
                          Text(report.statusMessage!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: ZienaColors.textSecondary)),
                        ],
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: ZienaColors.textSecondary),
                          const SizedBox(width: 5),
                          Text('Submitted on: ${report.date}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: ZienaColors.textSecondary)),
                        ]),
                        if (report.lastUpdate != null) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.access_time_rounded,
                                size: 12, color: ZienaColors.textSecondary),
                            const SizedBox(width: 5),
                            Text('Last Update: ${report.lastUpdate}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: ZienaColors.textSecondary)),
                          ]),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),

        // Bottom support button
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            color: ZienaColors.bg1,
            child: ZienaButton(
              text: 'support'.tr(),
              onTap: () {},
            ),
          ),
        ),
      ]),
    );
  }
}

