import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/services/data/model/booking_selection_data.dart';
import 'package:zeina/features/services/data/model/review_customer_model.dart';
import 'package:zeina/features/services/presentation/cubit/service_detail_cubit.dart';
import 'package:zeina/features/services/presentation/cubit/services_cubit.dart';
import 'package:zeina/features/services/presentation/widgets/booking_bottom_sheet.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/booking_validation_model.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/visit_type_model.dart';
import '../widgets/date_selection_bottom_sheet.dart';
import '../widgets/hourly_config_bottom_sheet.dart';
import 'checkout_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  static const String routeName = '/service-detail';

  final int serviceId;
  final VisitTypeModel visitType;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    required this.visitType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ServiceDetailCubit>()..fetch(serviceId),
      child: _ServiceDetailView(visitType: visitType),
    );
  }
}

class _ServiceDetailView extends StatelessWidget {
  final VisitTypeModel visitType;
  const _ServiceDetailView({required this.visitType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
          builder: (context, state) {
            if (state is ServiceDetailLoading || state is ServiceDetailInitial) {
              return const Center(
                child: CircularProgressIndicator(color: ZienaColors.primary),
              );
            }
            if (state is ServiceDetailError) {
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

            final loaded = state as ServiceDetailLoaded;
            return _LoadedBody(detail: loaded.detail, reviews: loaded.reviews, visitType: visitType);
          },
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final ServiceDetailModel detail;
  final List<ReviewModel> reviews;
  final VisitTypeModel visitType;

  const _LoadedBody({
    required this.detail,
    required this.reviews,
    required this.visitType,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    final categoryLabel = detail.type == 'hourly' ? 'Hourly Services' : 'Other Services';

    final double computedAvgRating = reviews.isNotEmpty
        ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
        : 0;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Image.network(
                      detail.image ?? '',
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
                        Expanded(
                          child: Text(
                            detail.localizedName(locale),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            categoryLabel.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ZienaColors.primary,
                            ),
                          ),
                          if (reviews.isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  computedAvgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: ZienaColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                _StarRow(rating: computedAvgRating),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail.localizedName(locale),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail.localizedDescription(locale),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ZienaColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'whats_included'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...detail.features.map(
                            (f) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: ZienaColors.bg3,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      ZienaColors.primary,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      'assets/images/check.png',
                                      width: 14,
                                      height: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f.localized(locale),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ZienaColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'reviews'.tr(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (reviews.isEmpty)
                        Text(
                          'no_reviews_yet'.tr(),
                          style: const TextStyle(color: ZienaColors.textSecondary),
                        )
                      else
                        ...reviews.map((r) => _ReviewTile(review: r)),
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
          child: Container(
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
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onBookNow(context, detail),
                child: Text('book_now'.tr()),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onBookNow(BuildContext context, ServiceDetailModel detail) async {
    if (detail.isConfigurableHourly) {
      // Hospitality Worker-style: configure start time/duration/gender/
      // worker count FIRST, check availability, THEN pick a date.
      final config = await showHourlyConfigBottomSheet(
        context: context,
        service: detail,
      );
      if (config == null || !context.mounted) return;

      await showDateSelectionBottomSheet(
        context: context,
        service: detail,
        visitType: visitType,
        config: config,
        onProceed: (BookingSelectionData data, BookingValidationModel validation) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                service: detail,
                selection: data,
                validation: validation,
              ),
            ),
          );
        },
      );
      return;
    }

    // Domestic Helper-style: pick from fixed pre-set shifts on a calendar.
    showBookingBottomSheet(
      context: context,
      service: detail,
      visitType: visitType,
      onProceed: (BookingSelectionData data, BookingValidationModel validation) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CheckoutScreen(
              service: detail,
              selection: data,
              validation: validation,
            ),
          ),
        );
      },
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon;
        if (i < full) {
          icon = Icons.star;
        } else if (i == full && hasHalf) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, size: 15, color: Colors.amber);
      }),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.customer.fullName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ),
          ),
          Row(
            children: [
              _StarRow(rating: review.rating.toDouble()),
              const SizedBox(width: 6),
              Text(
                review.createdSince,
                style: const TextStyle(
                  fontSize: 11,
                  color: ZienaColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review.comment,
            style: const TextStyle(fontSize: 13, color: ZienaColors.textSecondary),
          ),
          const Divider(height: 20, color: ZienaColors.greyBorder),
        ],
      ),
    );
  }
}