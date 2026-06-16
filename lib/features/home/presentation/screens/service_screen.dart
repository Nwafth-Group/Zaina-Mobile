import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/custom_icon.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../../widgets/signin_required_widget.dart';
import '../../../bookings/data/model/booking_flow_model.dart';
import '../../../bookings/presentation/cubit/booking_flow_cubit.dart';
import '../../../bookings/presentation/widgets/step_summary.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/service_model.dart';
import '../cubit/service_cubit.dart';
import '../widgets/service_result_card.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  final ServiceModel? preview;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    this.preview,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _agreedToTerms = false;
  String? _token;
  bool _showAllReviews = false;

  // ── Booking selections (shown on page after sheet closes) ─────────────────
  String? _selectedDate;
  String? _selectedStartTime;
  String? _selectedEndTime;
  int? _selectedDuration;
  List<WorkerModel> _selectedWorkers = [];
  ShiftModel? _selectedShift;

  bool get _hasSelections =>
      _selectedDate != null && _selectedWorkers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _token = SharedPrefHelper.getToken();
  }

  void _showSignInRequiredDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 480),
          child: const SignInRequiredWidget(tabKey: 'bookings', dialog: true,),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          sl<ServiceDetailCubit>()..fetchServiceDetail(widget.serviceId),
        ),
        BlocProvider(
          create: (_) =>
          sl<ServiceReviewsCubit>()..fetchReviews(widget.serviceId),
        ),
      ],
      child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
        builder: (context, state) {
          if (state is ServiceDetailLoading) {
            return _shell(child: const Center(
              child: CircularProgressIndicator(color: ZienaColors.primary),
            ));
          }
          if (state is ServiceDetailError) {
            return _shell(child: _buildError(context, state.message));
          }
          if (state is ServiceDetailLoaded) {
            return _buildDetail(context, state.service);
          }
          return _shell(child: const SizedBox());
        },
      ),
    );
  }

  Scaffold _shell({required Widget child}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('service_details'.tr(),
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
      ),
      body: child,
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded,
            size: 60, color: ZienaColors.textHint),
        const SizedBox(height: 16),
        Text(msg,
            style: const TextStyle(color: ZienaColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ZienaButton(
          text: 'retry'.tr(),
          onTap: () => context
              .read<ServiceDetailCubit>()
              .fetchServiceDetail(widget.serviceId),
        ),
      ],
    ));
  }

  Widget _buildDetail(BuildContext context, ServiceDetailModel service) {
    final lang = context.locale.languageCode;

    // Calculate total from selected workers * duration * price
    final workerCount = _selectedWorkers.length.clamp(1, 10);
    final duration = _selectedDuration ?? 1;
    final total = service.price.pricePerHour * workerCount * duration;

    return BlocProvider(
      create: (_) {
        final cubit = sl<BookingFlowCubit>();
        cubit.init(BookingFlowData(
          serviceId: widget.serviceId,
          serviceName: widget.preview!.nameAr,
          serviceNameEn: widget.preview!.nameEn,
          serviceImage: widget.preview!.image,
          categoryNameAr: widget.preview!.category.nameAr,
          categoryNameEn: widget.preview!.category.nameEn,
          avgRating: widget.preview!.avgRating,
          pricePerHour: widget.preview!.price.pricePerHour,
          currency: widget.preview!.price.currency,
          type: widget.preview!.type,
        ));
        return cubit;
      },
      child: Builder(builder: (ctx) {
        return Scaffold(
          
          body: Stack(children: [
            CustomScrollView(slivers: [
              // ── Hero ──────────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.black26,
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
                        size: 18, color: ZienaColors.textPrimary),
                  ),
                ),
                title: Text('service_details'.tr(),
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                flexibleSpace: FlexibleSpaceBar(
                  background: service.image != null
                      ? CachedNetworkImage(
                    imageUrl: service.image!, fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: ZienaColors.bg3),
                    errorWidget: (_, __, ___) => Container(
                        color: ZienaColors.bg3,
                        child: const Icon(
                            Icons.cleaning_services_rounded,
                            color: ZienaColors.primary, size: 80)),
                  )
                      : Container(
                      color: ZienaColors.bg3,
                      child: const Icon(Icons.cleaning_services_rounded,
                          color: ZienaColors.primary, size: 80)),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category + Rating ──────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.localizedCategory(lang),
                              style: const TextStyle(
                                fontSize: 12, color: ZienaColors.primary,
                                fontWeight: FontWeight.w500,
                              )),
                          const Spacer(),
                          StarRating(rating: service.avgRating, size: 15),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Text(service.localizedName(lang),
                          style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: ZienaColors.textPrimary, height: 1.2,
                          )),
                      const SizedBox(height: 6),

                      Text(service.localizedDescription(lang),
                          style: const TextStyle(
                            fontSize: 13, color: ZienaColors.textSecondary,
                            height: 1.55,
                          )),
                      const SizedBox(height: 10),

                      RichText(text: TextSpan(children: [
                        TextSpan(
                          text:
                          '${service.price.pricePerHour.toStringAsFixed(0)} ${service.price.currency} ',
                          style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700,
                            color: ZienaColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: _priceLabel(service.type),
                          style: const TextStyle(
                              fontSize: 13, color: ZienaColors.textSecondary),
                        ),
                      ])),
                      const SizedBox(height: 22),

                      // ── What's Included ───────────────────────────────────
                      _sectionTitle('whats_included'.tr()),
                      const SizedBox(height: 12),
                      ...service.features.map((f) =>
                          _FeatureRow(label: lang == 'ar' ? f.ar : f.en)),
                      const SizedBox(height: 20),

                      // ── Duration & Workers tile ───────────────────────────
                      _buildDurationWorkersTile(ctx, service),
                      const SizedBox(height: 20),

                      // ── Selected booking info (shown after sheet) ─────────
                      if (_hasSelections) ...[
                        _buildSelectedInfo(),
                        const SizedBox(height: 20),
                      ],

                      // ── Documents ─────────────────────────────────────────
                      _sectionTitle('documents'.tr()),
                      const SizedBox(height: 12),
                      _buildDocumentsCard(),
                      const SizedBox(height: 12),
                      _buildTermsCheckbox(),
                      const SizedBox(height: 20),

                      // ── Reviews ───────────────────────────────────────────
                      _sectionTitle('reviews'.tr()),
                      const SizedBox(height: 14),
                      _buildReviewsSection(),
                      const SizedBox(height: 30),

                    ],
                  ),
                ),
              ),
            ]),

            // ── Bottom bar ───────────────────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(ctx, total, service),
            ),
          ]),
        );
      }),
    );
  }

  // ── Duration & Workers tile — opens bottom sheet ───────────────────────────
  Widget _buildDurationWorkersTile(
      BuildContext ctx, ServiceDetailModel service) {
    return GestureDetector(
      onTap: () => _openDateTimeSheet(ctx, service),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.bg4.withOpacity(0.5)),
        ),
        child: Row(children: [
          ImageAsset(
            width: 45, height: 45,
              'assets/images/worker_duration.png'),
              const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('duration_workers'.tr(),
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  )),
              // const SizedBox(height: 2),
              // Text(
              //   _hasSelections
              //       ? '$_selectedDate  ·  $_selectedStartTime - $_selectedEndTime'
              //       : 'tap_to_select'.tr(),
              //   style: TextStyle(
              //     fontSize: 11,
              //     color: _hasSelections
              //         ? ZienaColors.primary
              //         : ZienaColors.textSecondary,
              //   ),
              // ),
            ],
          )),
          ImageAsset('assets/images/add_btn.png', width: 100, height: 60,)
        ]),
      ),
    );
  }

  // ── Selected booking summary shown on the page ─────────────────────────────
  Widget _buildSelectedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date/Time chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ZienaColors.bg1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
          ),
          child: Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: ZienaColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$_selectedDate',
                    style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary,
                    )),
                Text('$_selectedStartTime - $_selectedEndTime',
                    style: const TextStyle(
                        fontSize: 12, color: ZienaColors.textSecondary)),
              ],
            )),
            // Duration badge
            if (_selectedDuration != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ZienaColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$_selectedDuration hrs',
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            const SizedBox(width: 8),
            // Change button
            GestureDetector(
              onTap: () {},
              child: const Icon(Icons.close_rounded,
                  size: 18, color: ZienaColors.textSecondary),
            ),
          ]),
        ),

        const SizedBox(height: 10),

        // Workers list
        ..._selectedWorkers.map((w) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ZienaColors.bg1,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: ZienaColors.primary.withOpacity(0.2), width: 0.8),
          ),
          child: Row(children: [
            // Avatar
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: ZienaColors.bg3,
                border: Border.all(
                    color: ZienaColors.primary.withOpacity(0.2), width: 1.5),
              ),
              child: w.avatar != null
                  ? ClipOval(child: CachedNetworkImage(
                  imageUrl: w.avatar!, fit: BoxFit.cover))
                  : Center(child: Text(
                  w.name.isNotEmpty ? w.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: ZienaColors.primary,
                  ))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (w.rating != null)
                  Row(children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFB800), size: 13),
                    const SizedBox(width: 3),
                    Text(w.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: Color(0xFFFFB800),
                        )),
                  ]),
                Text(w.name,
                    style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary,
                    )),
                if (w.nationality != null)
                  Text(w.nationality!,
                      style: const TextStyle(
                          fontSize: 11, color: ZienaColors.textSecondary)),
              ],
            )),
            // Remove worker
            GestureDetector(
              onTap: () => setState(
                      () => _selectedWorkers.remove(w)),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: ZienaColors.textSecondary),
            ),
          ]),
        )),
      ],
    );
  }

  // ── Open date/time/workers bottom sheet ────────────────────────────────────
  void _openDateTimeSheet(BuildContext ctx, ServiceDetailModel service) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: ctx.read<BookingFlowCubit>(),
        child: _DateTimeWorkerSheet(
          service: service,
          onConfirm: (date, startTime, endTime, duration, shift, workers) {
            setState(() {
              _selectedDate      = date;
              _selectedStartTime = startTime;
              _selectedEndTime   = endTime;
              _selectedDuration  = duration;
              _selectedShift     = shift;
              _selectedWorkers   = workers;
            });
          },
        ),
      ),
    );
  }

  // ── Documents ──────────────────────────────────────────────────────────────
  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.bg4.withOpacity(0.6)),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: ZienaColors.bg3,
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.description_outlined,
              color: ZienaColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Text('terms_conditions'.tr(),
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500,
              color: ZienaColors.primary,
            )),
      ]),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20, height: 20,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: _agreedToTerms ? ZienaColors.primary : Colors.transparent,
            border: Border.all(
              color: _agreedToTerms
                  ? ZienaColors.primary
                  : ZienaColors.greyBorder,
              width: 1.5,
            ),
          ),
          child: _agreedToTerms
              ? const Icon(Icons.check, color: Colors.white, size: 13)
              : null,
        ),
        const SizedBox(width: 10),
        Text('agree_terms_conditions'.tr(),
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary)),
      ]),
    );
  }

  Widget _buildReviewsSection() {
    return BlocBuilder<ServiceReviewsCubit, ServiceReviewsState>(
      builder: (context, state) {
        if (state is ServiceReviewsLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2)),
          );
        }
        if (state is ServiceReviewsError) {
          return Text(state.message,
              style: const TextStyle(
                  fontSize: 13, color: ZienaColors.textSecondary));
        }
        if (state is ServiceReviewsLoaded) {
          final reviews = state.reviews;
          if (reviews.isEmpty) {
            return Text('no_reviews_yet'.tr(),
                style: const TextStyle(
                    fontSize: 13, color: ZienaColors.textSecondary));
          }
          final visible =
          _showAllReviews ? reviews : reviews.take(2).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...visible.map((r) => _ReviewCard(review: r)),
              if (!_showAllReviews && reviews.length > 2) ...[
                const SizedBox(height: 4),
                _buildSeeMoreReviews(),
              ],
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSeeMoreReviews() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => setState(() => _showAllReviews = true),
        style: OutlinedButton.styleFrom(
          foregroundColor: ZienaColors.primary,
          side: const BorderSide(color: ZienaColors.primary),
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text('see_more_reviews'.tr(),
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: ZienaColors.primary,
            )),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext ctx, double total, ServiceDetailModel service) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      decoration: BoxDecoration(
        color: ZienaColors.bg3,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16, offset: const Offset(0, -4),
        )],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('total'.tr(),
              style: const TextStyle(
                  fontSize: 14, color: ZienaColors.primary)),
          Text(
            '${total.toStringAsFixed(1)} ${service.price.currency}',
            style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: ZienaColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          Text('booking_summary'.tr(),
              style: const TextStyle(
                  fontSize: 12, color: ZienaColors.primary)),
          const Icon(Icons.keyboard_arrow_down,
              size: 16, color: ZienaColors.primary),
        ]),
        const SizedBox(height: 12),

        BlocBuilder<BookingFlowCubit, BookingFlowState>(
          builder: (bctx, bstate) {
            return ZienaButton(
              text: 'book_now'.tr(),
              isLoading: bstate.submitting,
              disabledBackgroundColor: ZienaColors.primary.withOpacity(0.4),
              onTap: (_agreedToTerms && _hasSelections && !bstate.submitting)
                  ? () {
                // 1. Auth check
                if (_token == null) {
                  _showSignInRequiredDialog(ctx);
                  return;
                }

                // 2. Update flow only (NO submit here)
                final cubit = bctx.read<BookingFlowCubit>();
                cubit.updateFlow(
                  cubit.flow.copyWith(
                    selectedDate: _selectedDate,
                    selectedStartTime: _selectedStartTime,
                    selectedEndTime: _selectedEndTime,
                    selectedDurationHours: _selectedDuration,
                    selectedWorkerIds:
                    _selectedWorkers.map((w) => w.id).toList(),
                    selectedAddressId: 1,
                  ),
                );

                // 3. NAVIGATE to summary instead of booking
                Navigator.push(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: cubit, // important: keep same cubit
                      child: const StepSummary(),
                    ),
                  ),
                );
              }
                  : null,
            );
          },
        ),
      ]),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: ZienaColors.textPrimary,
      ));

  String _priceLabel(String type) {
    switch (type) {
      case 'hourly':  return 'Per Hour'.tr();
      case 'moqema': return 'Resident';
      default:        return 'Per Session';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Date / Time / Worker bottom sheet — self-contained
// ═══════════════════════════════════════════════════════════════════════════════
class _DateTimeWorkerSheet extends StatefulWidget {
  final ServiceDetailModel service;
  final void Function(
      String date,
      String startTime,
      String endTime,
      int duration,
      ShiftModel shift,
      List<WorkerModel> workers,
      ) onConfirm;

  const _DateTimeWorkerSheet({
    required this.service,
    required this.onConfirm,
  });

  @override
  State<_DateTimeWorkerSheet> createState() => _DateTimeWorkerSheetState();
}

class _DateTimeWorkerSheetState extends State<_DateTimeWorkerSheet> {
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  ShiftModel? _shift;
  AvailableBlockModel? _block;
  final List<WorkerModel> _workers = [];

  String get _apiDate =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  int? get _duration {
    if (_block == null) return null;
    final s = int.parse(_block!.startTime.split(':')[0]);
    final e = int.parse(_block!.endTime.split(':')[0]);
    return e > s ? e - s : null;
  }

  bool get _canConfirm =>
      _shift != null && _block != null && _workers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      context.read<BookingFlowCubit>().fetchShifts(_apiDate);
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: ZienaColors.primary, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() {
        _date  = d;
        _shift = null;
        _block = null;
        _workers.clear();
      });
      context.read<BookingFlowCubit>().fetchShifts(_apiDate);
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
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: ZienaColors.greyBorder,
                  borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 16),
            Center(child: Text('select_date_and_time'.tr(),
                style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ))),
            const SizedBox(height: 20),

            // ── Date ──────────────────────────────────────────────────────────
            _label('select_new_date'.tr()),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ZienaColors.greyBorder),
                ),
                child: Row(children: [
                  Expanded(child: Text(
                    DateFormat('dd/MM/yyyy').format(_date),
                    style: const TextStyle(
                        fontSize: 14, color: ZienaColors.textPrimary),
                  )),
                  const Icon(Icons.calendar_today_outlined,
                      size: 18, color: ZienaColors.textSecondary),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // ── Shift ─────────────────────────────────────────────────────────
            _label('select_time_slot'.tr()),
            const SizedBox(height: 8),
            BlocBuilder<BookingFlowCubit, BookingFlowState>(
              builder: (context, state) {
                if (state.shiftsLoading) {
                  return const Center(child: CircularProgressIndicator(
                      color: ZienaColors.primary, strokeWidth: 2));
                }
                if (state.shifts.isEmpty) {
                  return _emptyBox('no_shifts_available'.tr());
                }
                return Column(children: state.shifts.map((s) {
                  final sel = _shift?.id == s.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() { _shift = s; _block = null; _workers.clear(); });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? ZienaColors.bg2 : ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? ZienaColors.primary : ZienaColors.greyBorder,
                          width: sel ? 1.5 : 0.8,
                        ),
                      ),
                      child: Row(children: [
                        Expanded(child: Text(s.dropdownLabel,
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: sel
                                  ? ZienaColors.primary
                                  : ZienaColors.textPrimary,
                            ))),
                        if (sel)
                          const Icon(Icons.keyboard_arrow_up,
                              color: ZienaColors.primary, size: 18)
                        else
                          const Icon(Icons.keyboard_arrow_down,
                              color: ZienaColors.textSecondary, size: 18),
                      ]),
                    ),
                  );
                }).toList());
              },
            ),

            // ── Time blocks (shown when shift selected) ────────────────────
            if (_shift != null) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _shift!.availableBlocks.map((b) {
                  final sel = _block == b;
                  return GestureDetector(
                    onTap: () {
                      setState(() { _block = b; _workers.clear(); });
                      final dur = int.parse(b.endTime.split(':')[0]) -
                          int.parse(b.startTime.split(':')[0]);
                      context.read<BookingFlowCubit>().fetchWorkers(
                        date:          _apiDate,
                        startTime:     b.startTime,
                        durationHours: dur > 0 ? dur : 1,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? ZienaColors.primary : ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? ZienaColors.primary
                              : ZienaColors.greyBorder,
                          width: sel ? 1.5 : 0.8,
                        ),
                      ),
                      child: Text(b.label,
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : ZienaColors.textPrimary,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ],

            // ── Workers ────────────────────────────────────────────────────
            if (_block != null) ...[
              const SizedBox(height: 16),
              BlocBuilder<BookingFlowCubit, BookingFlowState>(
                builder: (context, state) {
                  if (state.workersLoading) {
                    return const Center(child: CircularProgressIndicator(
                        color: ZienaColors.primary, strokeWidth: 2));
                  }

                  final preferred = state.workers?.preferredWorkers ?? [];
                  final others   = state.workers?.otherWorkers ?? [];

                  if (preferred.isEmpty && others.isEmpty) {
                    return _emptyBox('no_workers_available'.tr());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (preferred.isNotEmpty) ...[
                        Text('preferred_workers'.tr(),
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: ZienaColors.primary,
                            )),
                        const SizedBox(height: 8),
                        ...preferred.map((w) => _WorkerPickTile(
                          worker:     w,
                          isSelected: _workers.any((s) => s.id == w.id),
                          onTap: () => setState(() {
                            _workers.any((s) => s.id == w.id)
                                ? _workers.removeWhere((s) => s.id == w.id)
                                : _workers.add(w);
                          }),
                        )),
                      ],
                      if (others.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(preferred.isNotEmpty?'select_another_worker'.tr():'select_worker'.tr(),
                            style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: ZienaColors.textSecondary,
                            )),
                        const SizedBox(height: 8),
                        ...others.map((w) => _WorkerPickTile(
                          worker:     w,
                          isSelected: _workers.any((s) => s.id == w.id),
                          onTap: () => setState(() {
                            _workers.any((s) => s.id == w.id)
                                ? _workers.removeWhere((s) => s.id == w.id)
                                : _workers.add(w);
                          }),
                        )),
                      ],
                    ],
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // ── Select button ──────────────────────────────────────────────
            ZienaButton(
              text: 'select'.tr(),
              onTap: _canConfirm
                  ? () {
                Navigator.pop(context);
                widget.onConfirm(
                  _apiDate,
                  _block!.startTime,
                  _block!.endTime,
                  _duration!,
                  _shift!,
                  List.from(_workers),
                );
              }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: ZienaColors.textPrimary,
      ));

  Widget _emptyBox(String t) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ZienaColors.bg1,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: ZienaColors.greyBorder),
    ),
    child: Text(t,
        style: const TextStyle(
            fontSize: 13, color: ZienaColors.textSecondary)),
  );
}

// ── Worker pick tile inside sheet ─────────────────────────────────────────────
class _WorkerPickTile extends StatelessWidget {
  final WorkerModel worker;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkerPickTile({
    required this.worker,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.bg2 : ZienaColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: isSelected ? 1.5 : 0.7,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: ZienaColors.bg3,
              border: Border.all(
                  color: ZienaColors.primary.withOpacity(0.2), width: 1.5),
            ),
            child: Center(child: Text(
              worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: ZienaColors.primary,
              ),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (worker.rating != null)
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB800), size: 13),
                  const SizedBox(width: 3),
                  Text(worker.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB800),
                      )),
                ]),
              Text(worker.name,
                  style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: ZienaColors.textPrimary,
                  )),
              if (worker.nationality != null)
                Text(worker.nationality!,
                    style: const TextStyle(
                        fontSize: 11, color: ZienaColors.textSecondary)),
            ],
          )),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? ZienaColors.primary : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? ZienaColors.primary
                    : ZienaColors.greyBorder,
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ── Reused sub-widgets ────────────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        const ImageAsset('assets/images/point.png', height: 20, width: 20,),
        const SizedBox(width: 10),
        Expanded(child: Text(label,
            style: const TextStyle(
                fontSize: 14, color: ZienaColors.textPrimary))),
      ]),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(review.name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: ZienaColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.more_horiz,
              color: ZienaColors.textSecondary, size: 20),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          StarRating(rating: review.rating, size: 14),
          const SizedBox(width: 8),
          Text(review.timeAgo,
              style: const TextStyle(
                  fontSize: 11, color: ZienaColors.textSecondary)),
        ]),
        const SizedBox(height: 6),
        Text(review.comment,
            style: const TextStyle(
                fontSize: 13, color: ZienaColors.textSecondary, height: 1.4)),
      ]),
    );
  }
}