import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina_app/core/utils/shared_pref_helper.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/screens/phone_auth_screen.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/model/service_detail_model.dart';
import '../../data/model/service_model.dart';
import '../cubit/service_cubit.dart';
import '../widgets/service_result_card.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;
  // Pass lightweight data for instant header render while loading
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
  int _selectedDuration = 2;
  int _workerCount = 1;
  String? token;

  @override
  void initState() {
    getLoggedIn();
    super.initState();
  }

  Future<void> getLoggedIn()async{
    token = await SharedPrefHelper.getToken();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      sl<ServiceDetailCubit>()..fetchServiceDetail(widget.serviceId),
      child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
        builder: (context, state) {
          if (state is ServiceDetailLoading) {
            return _buildScaffold(child: const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            ));
          }
          if (state is ServiceDetailError) {
            return _buildScaffold(child: _buildError(context, state.message));
          }
          if (state is ServiceDetailLoaded) {
            return _buildFullDetail(context, state.service);
          }
          return _buildScaffold(child: const SizedBox());
        },
      ),
    );
  }

  Scaffold _buildScaffold({required Widget child}) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('service_details'.tr(),
            style: const TextStyle(
                
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary)),
      ),
      body: child,
    );
  }

  Widget _buildError(BuildContext context, String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 60, color: ZienaColors.textHint),
          const SizedBox(height: 16),
          Text(msg,
              style: const TextStyle(
                  
                  color: ZienaColors.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context
                .read<ServiceDetailCubit>()
                .fetchServiceDetail(widget.serviceId),
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('retry'.tr(),
                style: const TextStyle(
                     color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDetail(
      BuildContext context, ServiceDetailModel service) {
    final lang = context.locale.languageCode;
    final total = service.price.pricePerHour * _workerCount * _selectedDuration;

    return Scaffold(
      backgroundColor: ZienaColors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Hero image app bar ────────────────────────────────────────
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
                title: Text(
                  'service_details'.tr(),
                  style: const TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.white,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: service.image != null
                      ? CachedNetworkImage(
                    imageUrl: service.image!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: ZienaColors.bg3),
                    errorWidget: (_, __, ___) => Container(
                      color: ZienaColors.bg3,
                      child: const Icon(
                          Icons.cleaning_services_rounded,
                          color: ZienaColors.primary,
                          size: 80),
                    ),
                  )
                      : Container(
                    color: ZienaColors.bg3,
                    child: const Icon(
                        Icons.cleaning_services_rounded,
                        color: ZienaColors.primary,
                        size: 80),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category + Rating ───────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.localizedCategory(lang),
                            style: const TextStyle(
                              
                              fontSize: 12,
                              color: ZienaColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          StarRating(
                              rating: service.avgRating, size: 15),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ── Name ─────────────────────────────────────────────
                      Text(
                        service.localizedName(lang),
                        style: const TextStyle(
                          
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ── Description ───────────────────────────────────────
                      Text(
                        service.localizedDescription(lang),
                        style: const TextStyle(
                          
                          fontSize: 13,
                          color: ZienaColors.textSecondary,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Price ─────────────────────────────────────────────
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text:
                            '${service.price.pricePerHour.toStringAsFixed(0)} ${service.price.currency} ',
                            style: const TextStyle(
                              
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: ZienaColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: _priceLabel(service.type),
                            style: const TextStyle(
                              
                              fontSize: 13,
                              color: ZienaColors.textSecondary,
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 22),

                      // ── What's Included ──────────────────────────────────
                      _sectionTitle('whats_included'.tr()),
                      const SizedBox(height: 12),
                      ...service.features.map((f) => _FeatureRow(
                          label: lang == 'ar' ? f.ar : f.en)),

                      const SizedBox(height: 20),

                      // ── Duration & Workers ───────────────────────────────
                      _buildDurationWorkers(service),

                      const SizedBox(height: 20),

                      // ── Documents ────────────────────────────────────────
                      _sectionTitle('documents'.tr()),
                      const SizedBox(height: 12),
                      _buildDocumentsCard(),
                      const SizedBox(height: 12),
                      _buildTermsCheckbox(),

                      const SizedBox(height: 20),

                      // ── Reviews ──────────────────────────────────────────
                      _sectionTitle('reviews'.tr()),
                      const SizedBox(height: 14),
                      ...ReviewModel.mockReviews
                          .take(2)
                          .map((r) => _ReviewCard(review: r)),
                      const SizedBox(height: 4),
                      _buildSeeMoreReviews(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Sticky bottom bar ───────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(context, total, service),
          ),
        ],
      ),
    );
  }

  // ── Duration & Workers tile ───────────────────────────────────────────────
  Widget _buildDurationWorkers(ServiceDetailModel service) {
    return GestureDetector(
      onTap: () => _showDurationSheet(service),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.bg4.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ZienaColors.bg3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.people_outline_rounded,
                  color: ZienaColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'duration_workers'.tr(),
                    style: const TextStyle(
                      
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_selectedDuration hrs · $_workerCount worker',
                    style: const TextStyle(
                      
                      fontSize: 11,
                      color: ZienaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: ZienaColors.bg3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: ZienaColors.primary, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationSheet(ServiceDetailModel service) {
    final durations = service.duration?.allowedDurations ?? [1, 2, 3, 4];
    showModalBottomSheet(
      context: context,
      backgroundColor: ZienaColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (_, setBS) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: ZienaColors.greyBorder,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),

              // Duration selector
              Text('select_duration'.tr(),
                  style: const TextStyle(
                      
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.textPrimary)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                children: durations.map((d) {
                  final selected = _selectedDuration == d;
                  return GestureDetector(
                    onTap: () => setBS(
                            () => setState(() => _selectedDuration = d)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? ZienaColors.primary
                            : ZienaColors.bg1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? ZienaColors.primary
                              : ZienaColors.greyBorder,
                        ),
                      ),
                      child: Text(
                        '$d hrs',
                        style: TextStyle(
                          
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: selected
                              ? Colors.white
                              : ZienaColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Workers counter
              _CounterRow(
                label: 'workers'.tr(),
                value: _workerCount,
                min: 1,
                max: 5,
                onDecrement: () =>
                    setBS(() => setState(() => _workerCount--)),
                onIncrement: () =>
                    setBS(() => setState(() => _workerCount++)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZienaColors.primary,
                    minimumSize:
                    const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('done'.tr(),
                      style: const TextStyle(
                          
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ZienaColors.bg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZienaColors.bg4.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: ZienaColors.bg3,
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.description_outlined,
                color: ZienaColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            'terms_conditions'.tr(),
            style: const TextStyle(
              
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ZienaColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20, height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: _agreedToTerms
                  ? ZienaColors.primary
                  : Colors.transparent,
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
          Text(
            'agree_terms_conditions'.tr(),
            style: const TextStyle(
              
              fontSize: 13,
              color: ZienaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeeMoreReviews() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: ZienaColors.primary,
          side: const BorderSide(color: ZienaColors.primary),
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Text('see_more_reviews'.tr(),
            style: const TextStyle(
              
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ZienaColors.primary,
            )),
      ),
    );
  }

  // ── Sticky bottom bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar(
      BuildContext context, double total, ServiceDetailModel service) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('total'.tr(),
                  style: const TextStyle(
                    
                    fontSize: 14,
                    color: ZienaColors.textSecondary,
                  )),
              Text(
                '${total.toStringAsFixed(1)} ${service.price.currency}',
                style: const TextStyle(
                  
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text('booking_summary'.tr(),
                    style: const TextStyle(
                      
                      fontSize: 12,
                      color: ZienaColors.textSecondary,
                    )),
                const Icon(Icons.keyboard_arrow_down,
                    size: 16, color: ZienaColors.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _agreedToTerms
                  ? () {
                if (token==null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<AuthCubit>(),
                        child: const PhoneAuthScreen(),
                      ),
                    ),
                  );
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ZienaColors.primary,
                disabledBackgroundColor:
                ZienaColors.primary.withOpacity(0.4),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('book_now'.tr(),
                  style: const TextStyle(
                    
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: ZienaColors.textPrimary,
    ),
  );

  String _priceLabel(String type) {
    switch (type) {
      case 'hourly': return 'Per Hour';
      case 'moqema': return 'Resident';
      default: return 'Per Session';
    }
  }
}

// ── Feature row ───────────────────────────────────────────────────────────────
class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
                color: ZienaColors.bg2, shape: BoxShape.circle),
            child: const Icon(Icons.check,
                size: 13, color: ZienaColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    
                    fontSize: 14,
                    color: ZienaColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(review.name,
                  style: const TextStyle(
                      
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.textPrimary)),
              const Spacer(),
              const Icon(Icons.more_horiz,
                  color: ZienaColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              StarRating(rating: review.rating, size: 14),
              const SizedBox(width: 8),
              Text(review.timeAgo,
                  style: const TextStyle(
                      
                      fontSize: 11,
                      color: ZienaColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          Text(review.comment,
              style: const TextStyle(
                  
                  fontSize: 13,
                  color: ZienaColors.textSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }
}

// ── Counter row ───────────────────────────────────────────────────────────────
class _CounterRow extends StatelessWidget {
  final String label;
  final int value, min, max;
  final VoidCallback onDecrement, onIncrement;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary)),
        Row(
          children: [
            _CircleBtn(icon: Icons.remove,
                onTap: value > min ? onDecrement : null),
            const SizedBox(width: 16),
            Text('$value',
                style: const TextStyle(
                    
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary)),
            const SizedBox(width: 16),
            _CircleBtn(icon: Icons.add,
                onTap: value < max ? onIncrement : null),
          ],
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? ZienaColors.bg2 : ZienaColors.greyLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap != null
                ? ZienaColors.primary.withOpacity(0.3)
                : ZienaColors.greyBorder,
          ),
        ),
        child: Icon(icon, size: 18,
            color: onTap != null
                ? ZienaColors.primary
                : ZienaColors.textHint),
      ),
    );
  }
}