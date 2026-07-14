import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/home/presentation/cubit/home_cubti.dart';
import 'package:zeina/features/wallet/presentation/cubit/cubit.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/ziena_small_button.dart';
import '../../../services/data/model/service_detail_model.dart';
import '../../../services/data/repository/services_repository.dart';
import '../../data/model/booking_detail_model.dart';
import '../../data/model/booking_model.dart' show VisitScheduleItem;
import '../../data/model/reschedule_result.dart';
import '../cubit/bookings_cubit.dart';
import '../widgets/report_sheet.dart';
import '../widgets/reschedule_configurable_sheet.dart';
import '../widgets/reschedule_fixed_shift_sheet.dart';
import '../widgets/review_sheet.dart';

class BookingDetailScreen extends StatelessWidget {
  static const String routeName = '/booking-detail';
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingDetailCubit>()..fetchDetail(bookingId),
      child: const _BookingDetailView(),
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  const _BookingDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: BlocBuilder<BookingDetailCubit, BookingDetailState>(
        builder: (context, state) {
          if (state is BookingDetailLoading ||
              state is BookingDetailInitial ||
              state is BookingActionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: ZienaColors.primary),
            );
          }
          if (state is BookingDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: ZienaColors.error),
                ),
              ),
            );
          }
          if (state is! BookingDetailLoaded) {
            // BookingCancelSuccess (or any other non-loaded state) — the
            // cancel flow's own success dialog is already showing on top of
            // this screen and will pop it shortly; just avoid rebuilding
            // into a crash in the meantime.
            return const SizedBox.shrink();
          }
          final loaded = state;
          return _LoadedBody(booking: loaded.booking, features: loaded.features);
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final BookingDetailModel booking;
  final List<ServiceFeatureModel> features;

  const _LoadedBody({required this.booking, required this.features});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: Image.network(
                      booking.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: ZienaColors.bg3,
                        child: const Icon(Icons.image_outlined,
                            size: 48, color: ZienaColors.primary),
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'booking_details'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                  decoration: const BoxDecoration(
                    color: ZienaColors.bg1,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.visitTypeLabelKey.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ZienaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Ref pill ─────────────────────────────────────────
                      Row(children: [
                        _Pill(
                          asset: 'assets/images/rn.png',
                          text: booking.bookingReference,
                        ),
                      ]),
                      const SizedBox(height: 10),
                      // ── Date / time pills ────────────────────────────────
                      Row(children: [
                        _Pill(
                          asset: 'assets/images/calender.png',
                          text: booking.dateRangeLabel,
                        ),
                        const SizedBox(width: 10),
                        _Pill(
                          icon: Icons.access_time_rounded,
                          text: booking.timeSlot,
                        ),
                      ]),
                      const SizedBox(height: 20),

                      // ── Status: cancelled banner OR timeline(s) ─────────
                      if (booking.isCancelled)
                        _CancelledBanner(reason: booking.cancellationReason)
                      else if (booking.isMultiVisit)
                        ...booking.visitSchedule.asMap().entries.map(
                              (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _VisitTimeline(
                              visitNumber: entry.key + 1,
                              visit: entry.value,
                            ),
                          ),
                        )
                      else
                        _StatusStepper(currentStatus: booking.bookingStatus),

                      const SizedBox(height: 12),
                      const Divider(color: ZienaColors.greyBorder),
                      const SizedBox(height: 12),

                      // ── What's Included ──────────────────────────────────
                      if (features.isNotEmpty) ...[
                        Text('whats_included'.tr(), style: _titleStyle),
                        const SizedBox(height: 10),
                        ...features.map(
                              (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: ZienaColors.bg3,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                          ZienaColors.primary, BlendMode.srcIn),
                                      child: Image.asset('assets/images/check.png',
                                          width: 13, height: 13),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(f.localized(locale),
                                      style: const TextStyle(
                                          fontSize: 14, color: ZienaColors.textPrimary)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Important Notes ──────────────────────────────────
                      if (booking.importantNotes.isNotEmpty) ...[
                        Text('important_notes'.tr(), style: _titleStyle),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ZienaColors.bg2,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ZienaColors.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: booking.importantNotes
                                .map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Icon(Icons.circle,
                                        size: 6, color: ZienaColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(n,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: ZienaColors.textSecondary)),
                                  ),
                                ],
                              ),
                            ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Address ──────────────────────────────────────────
                      if (booking.address != null) ...[
                        Text('address'.tr(), style: _titleStyle),
                        const SizedBox(height: 10),
                        _AddressCard(address: booking.address!, locale: locale),
                        const SizedBox(height: 20),
                      ],

                      // ── Workers ──────────────────────────────────────────
                      if (booking.workers.isNotEmpty) ...[
                        Text('workers'.tr(), style: _titleStyle),
                        const SizedBox(height: 10),
                        ...booking.workers.map(
                              (w) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _WorkerTile(worker: w),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Documents ────────────────────────────────────────
                      Text('documents'.tr(), style: _titleStyle),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          // TODO: open/download the contract document once
                          // a contract-fetch endpoint is available.
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ZienaColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: ZienaColors.greyBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: ZienaColors.bg2,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.description_outlined,
                                    size: 18, color: ZienaColors.primary),
                              ),
                              const SizedBox(width: 10),
                              Text('contract'.tr(),
                                  style: const TextStyle(
                                      fontSize: 14, color: ZienaColors.primary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Price Summary ────────────────────────────────────
                      if (booking.priceSummary != null) ...[
                        Text('price_summary'.tr(), style: _titleStyle),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ZienaColors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: ZienaColors.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              _priceRow('service_price',
                                  booking.priceSummary!.subtotal, booking.currencyCode),
                              _priceRow('service_vat',
                                  booking.priceSummary!.tax, booking.currencyCode),
                              if (booking.priceSummary!.discount > 0)
                                _priceRow('discount',
                                    booking.priceSummary!.discount, booking.currencyCode),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                    color: ZienaColors.primary, height: 1, thickness: 0.6),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('total'.tr(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: ZienaColors.primary)),
                                  Text(
                                    '${booking.priceSummary!.total.toStringAsFixed(0)} ${booking.currencyCode}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: ZienaColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomActions(booking: booking),
        ),
      ],
    );
  }

  static const _titleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ZienaColors.textPrimary,
  );

  Widget _priceRow(String labelKey, double amount, String currency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(labelKey.tr(),
              style: const TextStyle(fontSize: 13, color: ZienaColors.textSecondary)),
          Text('${amount.toStringAsFixed(0)} $currency',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary)),
        ],
      ),
    );
  }
}

// ── Small pill (Ref / Date / Time) ────────────────────────────────────────────
class _Pill extends StatelessWidget {
  final IconData? icon;
  final String? asset;
  final String text;
  const _Pill({this.icon, this.asset, required this.text})
      : assert(icon != null || asset != null);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZienaColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                    ZienaColors.primary, BlendMode.srcIn),
                child: Image.asset(asset!, width: 15, height: 15),
              )
            else
              Icon(icon, size: 15, color: ZienaColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cancelled banner ───────────────────────────────────────────────────────────
class _CancelledBanner extends StatelessWidget {
  final String? reason;
  const _CancelledBanner({this.reason});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: ZienaColors.error, size: 20),
            const SizedBox(width: 6),
            Text(
              'cancelled'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ZienaColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'cancelled_refund_message'.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: ZienaColors.textSecondary),
        ),
      ],
    );
  }
}

// ── 3-stage status stepper (single visit / overall booking) ──────────────────
class _StatusStepper extends StatelessWidget {
  final String currentStatus; // "Upcoming" | "In Service"/"In Progress" | "Completed"
  const _StatusStepper({required this.currentStatus});

  int get _stageIndex {
    final normalized = currentStatus.toLowerCase().replaceAll(' ', '');
    if (normalized.contains('complet')) return 2;
    if (normalized.contains('progress') || normalized.contains('service')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final stageKeys = ['upcoming', 'in_service', 'completed'];
    final current = _stageIndex;
    return Row(
      children: List.generate(5, (i) {
        if (i.isOdd) {
          final stageBefore = (i - 1) ~/ 2;
          final lineActive = stageBefore < current;
          return Expanded(
            child: Container(
              height: 2,
              color: lineActive ? ZienaColors.primary : ZienaColors.greyBorder,
            ),
          );
        }
        final stage = i ~/ 2;
        final reached = stage <= current;
        return Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? ZienaColors.primary : ZienaColors.bg3,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 70,
              child: Text(
                stageKeys[stage].tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reached ? ZienaColors.primary : ZienaColors.textHint,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Per-visit timeline (3-visits-per-week bookings) ───────────────────────────
class _VisitTimeline extends StatelessWidget {
  final int visitNumber;
  final VisitScheduleItem visit;
  const _VisitTimeline({required this.visitNumber, required this.visit});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(visit.visitDate);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateLabel = date != null ? '${date.day} ${months[date.month - 1]}' : visit.visitDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'visit_number_label'.tr(args: ['$visitNumber'])} - ${visit.visitStatus.tr()} '
              '${'on_date_label'.tr()} $dateLabel',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ZienaColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _StatusStepper(currentStatus: visit.visitStatus),
      ],
    );
  }
}

// ── Address card ───────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final BookingDetailAddress address;
  final String locale;
  const _AddressCard({required this.address, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: ZienaColors.bg2,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(ZienaColors.primary, BlendMode.srcIn),
                child: Image.asset('assets/images/addresses.png', width: 18, height: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.label.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: ZienaColors.bg2,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(address.label,
                        style: const TextStyle(fontSize: 11, color: ZienaColors.primary)),
                  ),
                Text(address.cityAreaLine(locale),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary)),
                Text(address.streetBuildingLine,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: ZienaColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Worker tile (read-only) ───────────────────────────────────────────────────
class _WorkerTile extends StatelessWidget {
  final BookingDetailWorker worker;
  const _WorkerTile({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ZienaColors.bg3,
            backgroundImage: worker.image != '' ? NetworkImage(worker.image) : null,
            child: worker.image == ''
                ? const Icon(Icons.person, color: ZienaColors.primary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(worker.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ZienaColors.textPrimary)),
                  ],
                ),
                Text(worker.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary)),
                if (worker.nationality.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, size: 12, color: ZienaColors.primary),
                      const SizedBox(width: 3),
                      Text(worker.nationality,
                          style: const TextStyle(fontSize: 11, color: ZienaColors.primary)),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom action buttons (status-dependent) ──────────────────────────────────
class _BottomActions extends StatelessWidget {
  final BookingDetailModel booking;
  const _BottomActions({required this.booking});

  Future<void> _openReportSheet(BuildContext context) async {
    final cubit = context.read<BookingDetailCubit>();
    final reported = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ReportSheet(bookingId: booking.id),
      ),
    );
    // Sheet is fully closed now — safe to show the success dialog using
    // this (still-mounted) context, unlike showing it from inside the sheet
    // itself right as it's being disposed (that caused a white-screen bug).
    if (!context.mounted || reported != true) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('report_submitted'.tr()),
        content: Text('report_submitted_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              cubit.fetchDetail(booking.id);
              // Use the dialog's OWN context, not the outer captured one —
              // fetchDetail() flips the page behind this dialog to a
              // loading state, unmounting _BottomActions (and the outer
              // context with it) while the dialog is still open. The
              // dialog's context is a sibling route on the Navigator and
              // stays valid regardless.
              Navigator.pop(dialogCtx);
            },
            child: Text('done'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _openReviewSheet(BuildContext context) async {
    final cubit = context.read<BookingDetailCubit>();
    final reviewed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ReviewSheet(booking: booking),
      ),
    );
    if (!context.mounted || reviewed != true) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('review_submitted_title'.tr()),
        content: Text('review_submitted_msg'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              cubit.fetchDetail(booking.id);
              Navigator.pop(dialogCtx);
            },
            child: Text('done'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _startCancelFlow(BuildContext context) async {
    final cubit = context.read<BookingDetailCubit>();
    final bookingsCubit = context.read<BookingsCubit>();

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelReasonDialog(),
    );
    if (reason == null || !context.mounted) return; // user backed out

    final otpSent = await _runWithLoadingDialog(
      context,
          () => cubit.sendCancelOtp(booking.id),
    );
    if (!otpSent || !context.mounted) return;

    final otp = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OtpBottomSheet(
        onResend: () => _runWithLoadingDialog(
          context,
              () => cubit.sendCancelOtp(booking.id),
        ),
      ),
    );
    if (otp == null || !context.mounted) return; // user cancelled the sheet

    // Let the sheet's dismiss animation finish so the OTP boxes/keypad are
    // fully gone before the next dialog appears, instead of overlapping it.
    await Future.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    final success = await _runWithLoadingDialog(
      context,
          () => cubit.confirmCancel(
        bookingId: booking.id,
        cancellationReason: reason,
        otp: otp,
      ),
    );
    if (!context.mounted) return;
    if (success) {
      // Refresh the bookings list BEFORE popping back, so it reflects the
      // cancellation immediately rather than showing stale data for a beat.
      bookingsCubit.fetchBookings(refresh: true);
      context.read<HomeCubit>().fetchHomeData();
      context.read<WalletCubit>().fetchWallet();
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _CancelSuccessDialog(),
      );
      // _CancelSuccessDialog's Done button already pops itself and then
      // popUntil(isFirst) internally — nothing more to do here.
    }
    // On failure (e.g. wrong OTP) — the error dialog was already shown by
    // _runWithLoadingDialog; the flow ends here. The user taps
    // "Cancel Booking" again from scratch to retry, rather than looping
    // straight back into another OTP entry.
  }

  Future<void> _startRescheduleFlow(BuildContext context) async {
    final cubit = context.read<BookingDetailCubit>();
    final bookingsCubit = context.read<BookingsCubit>();
    final homeCubit = context.read<HomeCubit>();

    final service = await _fetchServiceWithLoading(context, booking.serviceId);
    if (service == null || !context.mounted) return;

    final requiredDays = booking.isMultiVisit ? 3 : 1;
    final result = service.hasDurationRange
        ? await showRescheduleConfigurableSheet(context: context, service: service)
        : await showRescheduleFixedShiftSheet(
      context: context,
      service: service,
      requiredDays: requiredDays,
    );
    if (result == null || !context.mounted) return;

    final otpSent = await _runWithLoadingDialog(
      context,
          () => cubit.sendRescheduleOtp(
        bookingId: booking.id,
        dates: result.dates,
        startTime: result.startTime,
      ),
    );
    if (!otpSent || !context.mounted) return;

    final otp = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OtpBottomSheet(
        onResend: () => _runWithLoadingDialog(
          context,
              () => cubit.sendRescheduleOtp(
            bookingId: booking.id,
            dates: result.dates,
            startTime: result.startTime,
          ),
        ),
      ),
    );
    if (otp == null || !context.mounted) return;

    // Let the sheet's dismiss animation finish before the next dialog.
    await Future.delayed(const Duration(milliseconds: 250));
    if (!context.mounted) return;

    final success = await _runWithLoadingDialog(
      context,
          () => cubit.confirmReschedule(
        bookingId: booking.id,
        dates: result.dates,
        startTime: result.startTime,
        otp: otp,
      ),
    );
    if (!context.mounted) return;
    if (success) {
      // The booking still exists after a reschedule (unlike cancel) — just
      // refresh everything so the new date/time shows up everywhere.
      bookingsCubit.fetchBookings(refresh: true);
      homeCubit.fetchHomeData();
      cubit.fetchDetail(booking.id);
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('reschedule_success_title'.tr()),
          content: Text('reschedule_success_msg'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('done'.tr()),
            ),
          ],
        ),
      );
    }
    // On failure (e.g. wrong OTP) — the error dialog was already shown by
    // _runWithLoadingDialog; the user taps "Reschedule Booking" again to retry.
  }

  /// Fetches the fresh service detail behind a small blocking spinner —
  /// needed to know whether this service uses fixed shifts or a
  /// configurable start-time/duration, and to get valid dates/shifts.
  Future<ServiceDetailModel?> _fetchServiceWithLoading(
      BuildContext context,
      int serviceId,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: ZienaColors.primary),
      ),
    );
    try {
      final detail = await sl<ServicesRepository>().fetchServiceDetail(serviceId);
      if (context.mounted) Navigator.pop(context); // close spinner
      return detail;
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close spinner
      if (context.mounted) {
        final message = e is String ? e : 'err_generic'.tr();
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('done'.tr()),
              ),
            ],
          ),
        );
      }
      return null;
    }
  }

  /// Shows a small blocking spinner while [action] runs; on failure, shows
  /// the shared error dialog with whatever message was thrown (ApiClient's
  /// post/put throw a plain String on failure — see core/network/api_client.dart).
  Future<bool> _runWithLoadingDialog(
      BuildContext context,
      Future<void> Function() action,
      ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: ZienaColors.primary),
      ),
    );
    try {
      await action();
      if (context.mounted) Navigator.pop(context); // close spinner
      return true;
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // close spinner
      if (context.mounted) {
        final message = e is String ? e : 'err_generic'.tr();
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('done'.tr()),
              ),
            ],
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Reporting is only valid for "In Service" or "Completed" bookings
    // (backend rule) — Cancelled bookings get no bottom action bar at all.
    if (booking.isCancelled) {
      return const SizedBox.shrink();
    }

    Widget buttons;

    if (booking.isCompleted) {
      final showReport = !booking.isReported;
      final showRate = !booking.isReviewed;
      if (!showReport && !showRate) return const SizedBox.shrink();
      buttons = Row(
        children: [
          if (showReport)
            Expanded(
              child: ZienaSmallButton(
                text: 'report'.tr(),
                isOutlined: true,
                onTap: () => _openReportSheet(context),
              ),
            ),
          if (showReport && showRate) const SizedBox(width: 12),
          if (showRate)
            Expanded(
              child: ZienaSmallButton(
                text: 'rate'.tr(),
                onTap: () => _openReviewSheet(context),
              ),
            ),
        ],
      );
    } else if (booking.isInService) {
      if (booking.isReported) return const SizedBox.shrink();
      buttons = ZienaSmallButton(
        text: 'report'.tr(),
        onTap: () => _openReportSheet(context),
      );
    } else {
      // Upcoming
      final allowCancel = booking.serviceRules?.allowCancel ?? true;
      final allowReschedule = booking.serviceRules?.allowReschedule ?? true;
      buttons = Row(
        children: [
          if (allowCancel)
            Expanded(
              child: ZienaSmallButton(
                text: 'cancel_booking'.tr(),
                isOutlined: true,
                onTap: () => _startCancelFlow(context),
              ),
            ),
          if (allowCancel && allowReschedule) const SizedBox(width: 12),
          if (allowReschedule)
            Expanded(
              child: ZienaSmallButton(
                text: 'reschedule_booking'.tr(),
                onTap: () => _startRescheduleFlow(context),
              ),
            ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: buttons,
    );
  }
}

// ── "Are You Sure?" reason dialog ─────────────────────────────────────────────
class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _reasonController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _errorText = 'this_field_required'.tr());
      return;
    }
    Navigator.pop(context, reason);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'are_you_sure'.tr(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: ZienaColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'do_you_want_cancel_order'.tr(),
              style: const TextStyle(fontSize: 13, color: ZienaColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              decoration: InputDecoration(
                hintText: 'write_reason'.tr(),
                hintStyle: const TextStyle(color: ZienaColors.textHint, fontSize: 13),
                errorText: _errorText,
                filled: true,
                fillColor: ZienaColors.bg1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: ZienaColors.greyBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: ZienaColors.greyBorder),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ZienaSmallButton(
                    text: 'cancel'.tr(),
                    isOutlined: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ZienaSmallButton(
                    text: 'confirm_button'.tr(),
                    onTap: _onConfirm,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP entry bottom sheet ─────────────────────────────────────────────────────
class _OtpBottomSheet extends StatefulWidget {
  final Future<bool> Function() onResend;
  const _OtpBottomSheet({required this.onResend});

  @override
  State<_OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends State<_OtpBottomSheet> {
  static const _digitCount = 6;
  String _otp = '';

  String get _otpValue => _otp;
  bool get _isComplete => _otp.length == _digitCount;

  void _onDigitTap(String digit) {
    if (_otp.length >= _digitCount) return;
    setState(() => _otp += digit);
  }

  void _onBackspace() {
    if (_otp.isEmpty) return;
    setState(() => _otp = _otp.substring(0, _otp.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            Text(
              'enter_otp_mobile_hint'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // ── Display-only boxes — no TextField, no system keyboard ────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_digitCount, (i) {
                final hasDigit = i < _otpValue.length;
                final isNext = i == _otpValue.length;
                return Container(
                  width: 42,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ZienaColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNext
                          ? ZienaColors.primary
                          : ZienaColors.primary.withOpacity(0.4),
                      width: isNext ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    hasDigit ? _otpValue[i] : '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.primary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                setState(() => _otp = '');
                await widget.onResend();
              },
              child: Text(
                'resend_otp'.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Custom in-app numeric keypad ─────────────────────────────
            _NumericKeypad(onDigit: _onDigitTap, onBackspace: _onBackspace),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ZienaSmallButton(
                    text: 'cancel'.tr(),
                    isOutlined: true,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ZienaSmallButton(
                    text: 'submit'.tr(),
                    onTap: _isComplete ? () => Navigator.pop(context, _otp) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fully custom 0-9 + backspace keypad — deliberately bypasses the system
/// keyboard/IME entirely (no TextField involved anywhere in the OTP sheet),
/// since the device's on-screen keyboard was showing a symbols layout
/// instead of a numeric one regardless of keyboardType.
class _NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  const _NumericKeypad({required this.onDigit, required this.onBackspace});

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((d) => _key(text: d, onTap: () => onDigit(d))).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 64, height: 48),
              _key(text: '0', onTap: () => onDigit('0')),
              _key(icon: Icons.backspace_outlined, onTap: onBackspace),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key({String? text, IconData? icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 48,
          alignment: Alignment.center,
          child: text != null
              ? Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ),
          )
              : Icon(icon, size: 20, color: ZienaColors.textSecondary),
        ),
      ),
    );
  }
}

// ── "Canceled!" success dialog ────────────────────────────────────────────────
class _CancelSuccessDialog extends StatelessWidget {
  const _CancelSuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('cancel_success_title'.tr()),
      content: Text('cancel_success_msg'.tr()),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Text('done'.tr()),
        ),
      ],
    );
  }
}