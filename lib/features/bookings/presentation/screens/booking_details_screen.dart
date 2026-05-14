import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina_app/features/bookings/presentation/screens/report_sheet.dart';
import 'package:zeina_app/features/bookings/presentation/screens/reschedule_sheet.dart';
import 'package:zeina_app/features/bookings/presentation/screens/review_sheet.dart';
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
        // Action loading
        if (state is BookingActionLoading) {
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
      backgroundColor: ZienaColors.white,
      appBar: AppBar(
        backgroundColor: ZienaColors.white,
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

    return Scaffold(
      backgroundColor: ZienaColors.white,
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
                        icon: Icons.tag_rounded,
                        label: b.bookingRef,
                        color: ZienaColors.primary,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        _InfoPill(
                          icon: Icons.calendar_today_rounded,
                          label: b.fullDate,
                          color: ZienaColors.textPrimary,
                        ),
                        const SizedBox(width: 8),
                        _InfoPill(
                          icon: Icons.access_time_rounded,
                          label: b.timeSlot,
                          color: ZienaColors.textPrimary,
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // ── Stepper ────────────────────────────────────────────
                      _buildStepper(status),
                      const SizedBox(height: 20),

                      // ── Important notes ────────────────────────────────────
                      if (b.importantNotes.isNotEmpty) ...[
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
                            color: ZienaColors.bg1,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: ZienaColors.greyBorder, width: 0.6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38, height: 38,
                                decoration: BoxDecoration(
                                  color: ZienaColors.bg3,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.location_on_outlined,
                                    color: ZienaColors.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b.address!.label,
                                        style: const TextStyle(
                                           fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ZienaColors.textPrimary,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(b.address!.fullAddress,
                                        style: const TextStyle(
                                           fontSize: 12,
                                          color: ZienaColors.textSecondary,
                                          height: 1.4,
                                        )),
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
            child: _buildBottomBar(context, b, isUpcoming, isInService, isCompleted),
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
        color: ZienaColors.bg1,
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

  Widget _buildBottomBar(BuildContext context, BookingModel b,
      bool isUpcoming, bool isInService, bool isCompleted) {
    if (!isUpcoming && !isInService && !isCompleted) return const SizedBox();

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
              builder: (_) => BlocProvider.value(
                value: context.read<BookingDetailCubit>(),
                child: RescheduleSheet(bookingId: b.id),
              ),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton(
            onPressed: () => _showCancelDialog(context),
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

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: ZienaColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(
                  color: ZienaColors.bg2, shape: BoxShape.circle),
              child: Stack(alignment: Alignment.center, children: [
                Container(
                  width: 68, height: 68,
                  decoration: const BoxDecoration(
                      color: ZienaColors.primary, shape: BoxShape.circle),
                ),
                const Icon(Icons.sentiment_dissatisfied_rounded,
                    color: Colors.white, size: 38),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 18, height: 18,
                    decoration: const BoxDecoration(
                      color: ZienaColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ]),
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
              onTap: () => Navigator.pop(context),
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
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
               fontSize: 12,
              fontWeight: FontWeight.w500, color: color,
            )),
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