import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina_app/features/home/presentation/screens/service_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/empty_data_widget.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/service_model.dart';
import '../cubit/service_cubit.dart';
import '../widgets/service_result_card.dart';

class PopularServicesScreen extends StatefulWidget {
  static const String routeName = '/popular-services';
  const PopularServicesScreen({super.key});

  @override
  State<PopularServicesScreen> createState() =>
      _PopularServicesScreenState();
}

class _PopularServicesScreenState extends State<PopularServicesScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PopularServicesCubit>().fetchServices(refresh: true);
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<PopularServicesCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('popular_services'.tr(),
            style: const TextStyle(
              
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            )),
        centerTitle: false,
      ),
      body: BlocBuilder<PopularServicesCubit, PopularServicesState>(
        builder: (context, state) {
          if (state is PopularServicesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            );
          }

          if (state is PopularServicesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 60, color: ZienaColors.textHint),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(
                          
                          color: ZienaColors.textSecondary)),
                  const SizedBox(height: 16),
                  ZienaButton(
                    text: 'retry'.tr(),
                    onTap: () => context
                        .read<PopularServicesCubit>()
                        .fetchServices(refresh: true),
                  ),
                ],
              ),
            );
          }

          final services = state is PopularServicesLoaded
              ? state.services
              : state is PopularServicesLoadingMore
              ? state.current
              : <ServiceModel>[];

          final isLoadingMore = state is PopularServicesLoadingMore;

          if (services.isEmpty && state is PopularServicesLoaded) {
            return const EmptyDataWidget(
              title: 'no_services_found',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<PopularServicesCubit>()
                .fetchServices(refresh: true),
            color: ZienaColors.primary,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: services.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == services.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: ZienaColors.primary,
                          strokeWidth: 2),
                    ),
                  );
                }
                final s = services[i];
                return _PopularServiceCard(
                  service: s,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ServiceDetailScreen(
                        serviceId: s.id,
                        preview: s,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Popular service card (image left, full detail, Book Now) ──────────────────
class _PopularServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _PopularServiceCard(
      {required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Image ──────────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18)),
              child: service.image != null
                  ? CachedNetworkImage(
                imageUrl: service.image!,
                width: 110,
                height: 145,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    width: 110,
                    height: 145,
                    color: ZienaColors.bg3),
                errorWidget: (_, __, ___) => _imgFallback(),
              )
                  : _imgFallback(),
            ),

            // ── Details ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.localizedCategory(lang),
                      style: const TextStyle(
                        
                        fontSize: 11,
                        color: ZienaColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.localizedName(lang),
                      style: const TextStyle(
                        
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    StarRating(rating: service.avgRating, size: 14),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text:
                          '${service.price.pricePerHour.toStringAsFixed(0)} ${service.price.currency} ',
                          style: const TextStyle(
                            
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ZienaColors.primary,
                          ),
                        ),
                        TextSpan(
                          text: _priceLabel(service.type),
                          style: const TextStyle(
                            
                            fontSize: 11,
                            color: ZienaColors.textSecondary,
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ZienaButton(
                        text: 'book_now'.tr(),
                        onTap: onTap,
                        height: 38,
                        borderRadius: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      width: 110,
      height: 145,
      color: ZienaColors.bg3,
      child: const Icon(Icons.cleaning_services_rounded,
          color: ZienaColors.primary, size: 40),
    );
  }

  String _priceLabel(String type) {
    switch (type) {
      case 'hourly': return 'Per Hour';
      case 'moqema': return 'Resident';
      default: return 'Per Session';
    }
  }
}