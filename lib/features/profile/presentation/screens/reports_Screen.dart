import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: Text('report'.tr(),
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
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 64, color: ZienaColors.greyBorder),
                  const SizedBox(height: 12),
                  Text('no_reports'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ZienaColors.textPrimary,
                      )),
                  const SizedBox(height: 6),
                  Text('no_reports_desc'.tr(),
                      style: const TextStyle(
                          fontSize: 13, color: ZienaColors.textSecondary),
                      textAlign: TextAlign.center),
                ]),
              );
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: report.serviceImage != null
                ? CachedNetworkImage(
                    imageUrl: report.serviceImage!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: ZienaColors.bg3,
                    child: const Icon(Icons.receipt_long_outlined,
                        color: ZienaColors.primary, size: 28),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: report.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: report.statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(report.serviceName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.textPrimary,
                    )),
                if (report.category != null) ...[
                  const SizedBox(height: 2),
                  Text(report.category!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ZienaColors.primary,
                        fontWeight: FontWeight.w500,
                      )),
                ],
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 11, color: ZienaColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(report.date,
                      style: const TextStyle(
                          fontSize: 11, color: ZienaColors.textSecondary)),
                ]),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: ZienaColors.textHint, size: 20),
        ]),
      ),
    );
  }
}
