import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../../widgets/ziena_step_indicator.dart';
import '../../data/models/legal_model.dart';
import '../cubit/reports_cubit.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Fetch the fresh detail (fuller history / latest status) by id, while
      // the report passed in from the list is shown immediately below so
      // there's no blank/loading flash.
      create: (_) => sl<ReportDetailCubit>()..fetchReportDetail(report.id),
      child: _ReportDetailView(initialReport: report),
    );
  }
}

class _ReportDetailView extends StatelessWidget {
  final ReportModel initialReport;
  const _ReportDetailView({required this.initialReport});

  static const _steps = ['Submitted', 'Under Review', 'Resolved'];

  Future<void> _openWhatsAppSupport() async {
    final uri = Uri.parse('https://wa.me/966567181328');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('report_details'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: BlocBuilder<ReportDetailCubit, ReportDetailState>(
        builder: (context, state) {
          // Use the freshly-fetched report once it arrives; fall back to
          // the one passed in from the list so the screen never looks empty.
          final report =
          state is ReportDetailLoaded ? state.report : initialReport;
          final isRefreshing = state is ReportDetailLoading;

          return Stack(children: [
            RefreshIndicator(
              color: ZienaColors.primary,
              onRefresh: () => context
                  .read<ReportDetailCubit>()
                  .fetchReportDetail(report.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(children: [
                  if (state is ReportDetailError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ZienaColors.error.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                              fontSize: 12, color: ZienaColors.error),
                        ),
                      ),
                    ),

                  // Service card
                  // Container(
                  //   padding: const EdgeInsets.all(14),
                  //   decoration: BoxDecoration(
                  //     color: ZienaColors.white,
                  //     borderRadius: BorderRadius.circular(14),
                  //     border: Border.all(
                  //         color: ZienaColors.greyBorder, width: 0.5),
                  //   ),
                  //   child: Row(children: [
                  //     Container(
                  //       width: 64,
                  //       height: 64,
                  //       decoration: BoxDecoration(
                  //           color: ZienaColors.bg3,
                  //           borderRadius: BorderRadius.circular(10)),
                  //       child: const Icon(Icons.cleaning_services_rounded,
                  //           color: ZienaColors.primary, size: 32),
                  //     ),
                  //     const SizedBox(width: 12),
                  //     Expanded(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             if (report.serviceCategory.isNotEmpty)
                  //               Text(report.serviceCategory,
                  //                   style: const TextStyle(
                  //                     fontSize: 11,
                  //                     color: ZienaColors.primary,
                  //                     fontWeight: FontWeight.w500,
                  //                   )),
                  //             Text(report.serviceTitle,
                  //                 style: const TextStyle(
                  //                   fontSize: 15,
                  //                   fontWeight: FontWeight.w700,
                  //                   color: ZienaColors.textPrimary,
                  //                 )),
                  //             Row(children: [
                  //               const Icon(Icons.calendar_today_outlined,
                  //                   size: 11, color: ZienaColors.textSecondary),
                  //               const SizedBox(width: 4),
                  //               Text(report.longCreatedAtLabel,
                  //                   style: const TextStyle(
                  //                       fontSize: 11,
                  //                       color: ZienaColors.textSecondary)),
                  //             ]),
                  //           ],
                  //         )),
                  //   ]),
                  // ),
                  // const SizedBox(height: 16),

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('report_status'.tr(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ZienaColors.textPrimary,
                                )),
                            if (isRefreshing)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ZienaColors.primary),
                              ),
                          ],
                        ),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: report.statusColor,
                                  )),
                              if (report.statusDescription.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(report.statusDescription,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ZienaColors.textSecondary)),
                              ],
                              const SizedBox(height: 8),
                              Row(children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 12, color: ZienaColors.textSecondary),
                                const SizedBox(width: 5),
                                Text(
                                    '${'submitted_on'.tr()}: ${report.longCreatedAtLabel}',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: ZienaColors.textSecondary)),
                              ]),
                              if (report.hasUpdate) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 12,
                                      color: ZienaColors.textSecondary),
                                  const SizedBox(width: 5),
                                  Text(
                                      '${'last_update'.tr()}: ${report.longUpdatedAtLabel}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: ZienaColors.textSecondary)),
                                ]),
                              ],
                              if (report.reasonLabel.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(children: [
                                  const Icon(Icons.description_outlined,
                                      size: 12,
                                      color: ZienaColors.textSecondary),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                        '${'report_issue'.tr()}: ${report.reasonLabel}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: ZienaColors.textSecondary)),
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History timeline
                  if (report.history.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
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
                          Text('history'.tr(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ZienaColors.textPrimary,
                              )),
                          const SizedBox(height: 16),
                          // `history` arrives newest-first from the API; the
                          // timeline reads top-to-bottom as newest-to-oldest.
                          ...List.generate(report.history.length, (i) {
                            final item = report.history[i];
                            final isLast = i == report.history.length - 1;
                            return _HistoryTile(item: item, isLast: isLast);
                          }),
                        ],
                      ),
                    ),
                  ],
                ]),
              ),
            ),

            // Bottom support button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                color: ZienaColors.bg1,
                child: ZienaButton(
                  text: 'support'.tr(),
                  onTap: () => _openWhatsAppSupport(),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ReportHistoryItem item;
  final bool isLast;
  const _HistoryTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + connecting line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: BoxDecoration(
                  color: item.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: ZienaColors.greyBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.statusLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: item.statusColor,
                    ),
                  ),
                  if (item.note != null && item.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.note!.trim(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZienaColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    item.formattedDateTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: ZienaColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}