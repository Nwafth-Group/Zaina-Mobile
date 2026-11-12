import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/models/legal_model.dart';
import '../cubit/reports_cubit.dart';
import 'report_details_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..fetchReports(),
      child: const _ReportScreenView(),
    );
  }
}

class _ReportScreenView extends StatelessWidget {
  const _ReportScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.bg1,
        surfaceTintColor: ZienaColors.bg1,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('reports'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            );
          }

          if (state is ReportsError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 60, color: ZienaColors.textHint),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(color: ZienaColors.textSecondary)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.read<ReportsCubit>().fetchReports(),
                  child: Text('retry'.tr(),
                      style: const TextStyle(color: ZienaColors.primary)),
                ),
              ]),
            );
          }

          if (state is ReportsLoaded) {
            if (state.reports.isEmpty) {
              return _buildEmpty();
            }

            return RefreshIndicator(
              color: ZienaColors.primary,
              onRefresh: () => context.read<ReportsCubit>().fetchReports(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: state.reports.length,
                itemBuilder: (_, i) => _ReportTile(
                  report: state.reports[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReportDetailScreen(report: state.reports[i]),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
  Widget _buildEmpty() {
    return Center(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ImageAsset(
          'assets/images/rep_empty.png',
          width: 180, height: 180,
        ),
        const SizedBox(height: 8),
        Text('no_reports'.tr(),
            style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('no_reports_desc'.tr(),
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _ReportTile extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onTap;
  const _ReportTile({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ZienaColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.primary.withOpacity(0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date strip
              Container(
                width: 68,
                alignment: Alignment.center,
                color: ZienaColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  report.shortDateLabel(context.locale.languageCode),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.white,
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (report.serviceCategory.isNotEmpty)
                        Text(
                          report.serviceCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ZienaColors.textPrimary,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        report.serviceTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: ZienaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 14, color: report.statusColor),
                          const SizedBox(width: 4),
                          Text(
                            report.statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: report.statusColor,
                            ),
                          ),
                        ],
                      ),
                      if (report.reasonLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 14, color: ZienaColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${'report_issue'.tr()}: ${report.reasonLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: ZienaColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}