import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/bookings/presentation/screens/report_sheet.dart';
import 'package:zeina/widgets/custom_icon.dart';
import '../../../../widgets/success_dialog.dart';
import 'package:zeina/features/bookings/presentation/cubit/reschedule_shifts_cubit.dart';
import 'package:zeina/features/bookings/presentation/screens/reschedule_sheet.dart';
import 'package:zeina/injection_container.dart';
import 'package:zeina/features/bookings/presentation/screens/review_sheet.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/booking_model.dart';
import '../cubit/bookings_cubit.dart';

class BookingDetailScreen extends StatelessWidget {
  final int bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingDetailCubit, BookingDetailState>(
      listener: (context, state) {
        if (state is BookingDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: ZienaColors.error,
          ));
        }
        if (state is BookingCancelSuccess) {
          showDialog(
            context: context,
            builder: (_) => SuccessDialog(
              icon: Icons.cancel_outlined,
              title: 'cancel_success_title'.tr(),
              message: 'cancel_success_msg'.tr(),
              onButtonTap: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // back to bookings list
              },
            ),
          );
        }
        if (state is BookingReviewSuccess ||
            state is BookingRescheduleSuccess ||
            state is BookingReportSuccess) {
          context.read<BookingDetailCubit>().fetchDetail(bookingId);
        }
      },
      builder: (context, state) {
        if (state is BookingDetailLoading) {
          return _shell(child: const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2)));
        }
        if (state is BookingDetailError) {
          return _shell(child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 60, color: ZienaColors.textHint),
                const SizedBox(height: 12),
                Text(state.message,
                    style: const TextStyle(
                        
                        color: ZienaColors.textSecondary)),
                const SizedBox(height: 16),
                ZienaButton(
                  text: 'retry'.tr(),
                  onTap: () => context
                      .read<BookingDetailCubit>()
                      .fetchDetail(bookingId),
                ),
              ],
            ),
          ));
        }
        if (state is BookingDetailLoaded) {
          return _buildDetail(context, state.booking);
        }
        if (state is BookingActionLoading ||
            state is BookingReviewSuccess ||
            state is BookingRescheduleSuccess ||
            state is BookingReportSuccess) {
          return _shell(child: const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2)));
        }
        return _shell(child: const SizedBox());
      },
    );
  }

  Scaffold _shell({required Widget child}) {
    return Scaffold(
      
      appBar: AppBar(
        
        elevation: 0,
        title: Text('booking_details'.tr(),
            style: const TextStyle(
               fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: child,
    );
  }

  Widget _buildDetail(BuildContext context, BookingModel b) {
    final status = b.statusEnum;
    final isUpcoming = status == BookingStatusEnum.upcoming;
    final isInService = status == BookingStatusEnum.inService;
    final isCompleted = status == BookingStatusEnum.completed;
    final isCancelled = status == BookingStatusEnum.cancelled;

    return Scaffold(
      
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero ──────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: ZienaColors.primary,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        size: 16, color: ZienaColors.textPrimary),
                  ),
                ),
                title: Text('booking_details'.tr(),
                    style: const TextStyle(
                       fontSize: 16,
                      fontWeight: FontWeight.w600, color: Colors.white,
                    )),
                flexibleSpace: FlexibleSpaceBar(
                  background: b.image != null
                      ? CachedNetworkImage(
                      imageUrl: b.image!, fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: ZienaColors.bg3),
                      errorWidget: (_, _, _) =>
                          Container(color: ZienaColors.bg3,
                              child: const Icon(
                                  Icons.cleaning_services_rounded,
                                  color: ZienaColors.primary,
                                  size: 70)))
                      : Container(color: ZienaColors.bg3),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Service name ───────────────────────────────────────
                      Text(b.serviceName,
                          style: const TextStyle(
                             fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.textPrimary,
                          )),
                      const SizedBox(height: 12),

                      // ── Booking ref ────────────────────────────────────────
                      _InfoPill(
                        icon: 'assets/images/delivery.png',
                        label: b.bookingRef,
                        color: ZienaColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: _InfoPill(
                            icon: 'assets/images/calender.png',
                            label: b.fullDate,
                            color: ZienaColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoPill(
                            icon: 'assets/images/time.png',
                            label: b.timeSlot,
                            color: ZienaColors.primary,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // ── Status indicator ───────────────────────────────────
                      if (isCancelled)
                        _buildCancelledBadge()
                      else
                        _buildStepper(status),
                      const SizedBox(height: 20),

                      // ── Important notes ────────────────────────────────────
                      if (!isCancelled && b.importantNotes.isNotEmpty) ...[
                        _sectionTitle('important_notes'.tr()),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ZienaColors.bg1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: ZienaColors.greyBorder, width: 0.6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: b.importantNotes.map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 7, height: 7,
                                    margin: const EdgeInsets.only(top: 5),
                                    decoration: const BoxDecoration(
                                      color: ZienaColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(n,
                                      style: const TextStyle(
                                         fontSize: 13,
                                        color: ZienaColors.textSecondary,
                                        height: 1.4,
                                      ))),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Address ────────────────────────────────────────────
                      if (b.address != null) ...[
                        _sectionTitle('address'.tr()),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ZienaColors.bg2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: ZienaColors.primaryLight, width: 0.6),
                          ),
                          child: Row(
                            children: [
                              ImageAsset('assets/images/address_booking.png', height: 60, width: 60),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ZienaColors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: ZienaColors.primary
                                                .withValues(alpha: 0.3),
                                            width: 0.8),
                                      ),
                                      child: Text(b.address!.label,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: ZienaColors.primary,
                                          )),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${b.address!.areaName}, ${b.address!.cityName}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: ZienaColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${b.address!.areaName} ${b.address!.street}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: ZienaColors.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Worker ─────────────────────────────────────────────
                      if (b.worker != null) ...[
                        _sectionTitle('workers'.tr()),
                        const SizedBox(height: 6),
                        Text('cleaner_count'.tr(),
                            style: const TextStyle(
                               fontSize: 12,
                              color: ZienaColors.textSecondary,
                            )),
                        const SizedBox(height: 10),
                        _WorkerCard(worker: b.worker!),
                        const SizedBox(height: 20),
                      ],

                      // ── Price summary ──────────────────────────────────────
                      if (b.priceSummary != null) ...[
                        _sectionTitle('price_summary'.tr()),
                        const SizedBox(height: 12),
                        _buildPriceSummary(b.priceSummary!, b.currency),
                        const SizedBox(height: 20),
                      ],

                      // ── Documents ──────────────────────────────────────────
                      _sectionTitle('documents'.tr()),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: ZienaColors.bg1,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: ZienaColors.bg4.withOpacity(0.6)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: ZienaColors.bg3,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description_outlined,
                                color: ZienaColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Text('terms_conditions'.tr(),
                              style: const TextStyle(
                                 fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ZienaColors.primary,
                              )),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom action bar ──────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(context, b, isUpcoming, isInService, isCompleted, isCancelled),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper(BookingStatusEnum status) {
    final steps = ['upcoming'.tr(), 'in_service'.tr(), 'completed'.tr()];
    int activeIndex = 0;
    if (status == BookingStatusEnum.inService) activeIndex = 1;
    if (status == BookingStatusEnum.completed) activeIndex = 2;

    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= activeIndex;
        return Expanded(
          child: Column(children: [
            Container(
              height: 6,
              margin: EdgeInsets.only(right: i < steps.length - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: active ? ZienaColors.primary : ZienaColors.greyBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Text(steps[i],
                style: TextStyle(
                   fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: active ? ZienaColors.primary : ZienaColors.textHint,
                )),
          ]),
        );
      }),
    );
  }

  Widget _buildPriceSummary(BookingPriceSummary p, String currency) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Column(children: [
        _PriceRow('service_price'.tr(),
            '${p.subtotal.toStringAsFixed(0)} $currency', false),
        const SizedBox(height: 6),
        _PriceRow('service_vat'.tr(),
            '${p.tax.toStringAsFixed(0)} $currency', false),
        if (p.discount > 0) ...[
          const SizedBox(height: 6),
          _PriceRow('discount'.tr(),
              '-${p.discount.toStringAsFixed(0)} $currency', false),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: ZienaColors.greyBorder, height: 1),
        ),
        _PriceRow('total'.tr(),
            '${p.total.toStringAsFixed(0)} $currency', true),
      ]),
    );
  }

  Widget _buildCancelledBadge() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFE53935), size: 22),
            const SizedBox(width: 8),
            Text('cancelled'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE53935),
                )),
          ],
        ),
        const SizedBox(height: 6),
        Text('cancelled_refund_message'.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: ZienaColors.textSecondary,
            )),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingModel b,
      bool isUpcoming, bool isInService, bool isCompleted, bool isCancelled) {
    if (!isUpcoming && !isInService && !isCompleted && !isCancelled) return const SizedBox();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 16, offset: const Offset(0, -4),
        )],
      ),
      child: Row(children: [
        if (isUpcoming) ...[
          Expanded(child: ZienaButton(
            text: 'reschedule'.tr(),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                      value: context.read<BookingDetailCubit>()),
                  BlocProvider(
                    create: (_) => sl<RescheduleShiftsCubit>(),
                  ),
                ],
                child: RescheduleSheet(bookingId: b.id),
              ),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton(
            onPressed: () => _showCancelDialog(context, b.id),
            style: OutlinedButton.styleFrom(
              foregroundColor: ZienaColors.primary,
              side: const BorderSide(color: ZienaColors.primary),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('cancel'.tr(),
                style: const TextStyle(
                   fontSize: 15,
                  fontWeight: FontWeight.w600, color: ZienaColors.primary,
                )),
          )),
        ],
        if (isInService)
          Expanded(child: ZienaButton(
            text: 'report'.tr(),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<BookingDetailCubit>(),
                child: ReportSheet(bookingId: b.id),
              ),
            ),
          )),
        if (isCompleted) ...[
          Expanded(child: ZienaButton(
            text: 'report'.tr(),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<BookingDetailCubit>(),
                child: ReportSheet(bookingId: b.id),
              ),
            ),
            backgroundColor: ZienaColors.bg2,
            textColor: ZienaColors.primary,
          )),
          const SizedBox(width: 12),
          Expanded(child: ZienaButton(
            text: 'rate'.tr(),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => BlocProvider.value(
                value: context.read<BookingDetailCubit>(),
                child: ReviewSheet(booking: b),
              ),
            ),
          )),
        ],
      ]),
    );
  }

  void _showCancelDialog(BuildContext context, int bookingId) {
    final cubit = context.read<BookingDetailCubit>();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE56B8F).withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Padding around vector map
                  child: Image.asset(
                    'assets/images/cancel_illustration.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('are_you_sure_cancel'.tr(),
                style: const TextStyle(
                   fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('do_you_want_cancel_order'.tr(),
                style: const TextStyle(
                   fontSize: 13,
                  color: ZienaColors.textSecondary,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ZienaButton(
              text: 'confirm_button'.tr(),
              onTap: () {
                Navigator.pop(context);
                cubit.cancelBooking(bookingId);
              },
              height: 50,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ZienaColors.greyBorder),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('cancel_button'.tr(),
                  style: const TextStyle(
                     fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ZienaColors.textSecondary,
                  )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
         fontSize: 15,
        fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
      ));
}

class _WorkerCard extends StatelessWidget {
  final BookingWorkerModel worker;
  const _WorkerCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle, color: ZienaColors.bg3,
            border: Border.all(
                color: ZienaColors.primary.withOpacity(0.2), width: 1.5),
          ),
          child: worker.avatar != null
              ? ClipOval(child: CachedNetworkImage(
              imageUrl: worker.avatar!, fit: BoxFit.cover))
              : const Icon(Icons.person, color: ZienaColors.primary, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (worker.rating != null)
              Row(children: [
                const Icon(Icons.star_rounded,
                    color: Color(0xFFFFB800), size: 14),
                const SizedBox(width: 3),
                Text(worker.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                       fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB800),
                    )),
              ]),
            Text(worker.name,
                style: const TextStyle(
                   fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary,
                )),
            if (worker.nationality != null)
              Row(children: [
                const Icon(Icons.flag_outlined,
                    size: 12, color: ZienaColors.textSecondary),
                const SizedBox(width: 4),
                Text(worker.nationality!,
                    style: const TextStyle(
                       fontSize: 11,
                      color: ZienaColors.textSecondary,
                    )),
              ]),
          ],
        )),
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
        ImageAsset(icon, height: 15, width: 15),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                 fontSize: 12,
                fontWeight: FontWeight.w500, color: color,
              )),
        ),
      ]),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label, value;
  final bool isTotal;
  const _PriceRow(this.label, this.value, this.isTotal);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          
          fontSize: isTotal ? 14 : 13,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          color: isTotal ? ZienaColors.textPrimary : ZienaColors.textSecondary,
        )),
        Text(value, style: TextStyle(
          
          fontSize: isTotal ? 14 : 13,
          fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
          color: isTotal ? ZienaColors.primary : ZienaColors.textSecondary,
        )),
      ],
    );
  }
}