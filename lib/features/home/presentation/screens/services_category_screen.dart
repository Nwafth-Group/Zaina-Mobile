import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/features/home/presentation/screens/service_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/empty_data_widget.dart';
import '../../../../widgets/ziena_button.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/service_model.dart';
import '../cubit/category_cubit.dart';
import '../widgets/service_result_card.dart';

// Self-provides both cubits so callers don't need to wrap it.
class CategoryServicesScreen extends StatelessWidget {
  final CategoryModel category;
  const CategoryServicesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CategoryServicesCubit>()),
        BlocProvider(create: (_) => sl<SubcategoriesCubit>()),
      ],
      child: _CategoryServicesView(category: category),
    );
  }
}

class _CategoryServicesView extends StatefulWidget {
  final CategoryModel category;
  const _CategoryServicesView({required this.category});

  @override
  State<_CategoryServicesView> createState() => _CategoryServicesViewState();
}

class _CategoryServicesViewState extends State<_CategoryServicesView> {
  final ScrollController _scroll = ScrollController();
  int? _selectedSubId; // null = all

  @override
  void initState() {
    super.initState();
    context.read<CategoryServicesCubit>()
        .fetchServices(widget.category.id, refresh: true);
    context.read<SubcategoriesCubit>()
        .fetchSubcategories(widget.category.id, refresh: true);
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<CategoryServicesCubit>()
            .loadMore(_selectedSubId ?? widget.category.id);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _selectSub(int? subId) {
    setState(() => _selectedSubId = subId);
    context.read<CategoryServicesCubit>()
        .fetchServices(subId ?? widget.category.id, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
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
        title: Text(
          widget.category.localizedName(lang),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
        centerTitle: false,
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(52),
        //   child: BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
        //     builder: (context, subState) {
        //       final subs = subState is SubcategoriesLoaded
        //           ? subState.categories
        //           : subState is SubcategoriesLoadingMore
        //               ? subState.current
        //               : <CategoryModel>[];
        //       if (subs.isEmpty) return const SizedBox.shrink();
        //       return SizedBox(
        //         height: 52,
        //         child: ListView(
        //           scrollDirection: Axis.horizontal,
        //           padding: const EdgeInsets.symmetric(
        //               horizontal: 16, vertical: 8),
        //           children: [
        //             // "All" chip
        //             _SubChip(
        //               label: 'all'.tr(),
        //               selected: _selectedSubId == null,
        //               onTap: () => _selectSub(null),
        //             ),
        //             ...subs.map((s) => _SubChip(
        //                   label: s.localizedName(lang),
        //                   selected: _selectedSubId == s.id,
        //                   onTap: () => _selectSub(s.id),
        //                 )),
        //           ],
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ),
      body: BlocBuilder<CategoryServicesCubit, CategoryServicesState>(
        builder: (context, state) {
          // ── Loading ──────────────────────────────────────────────────────
          if (state is CategoryServicesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (state is CategoryServicesError) {
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
                        .read<CategoryServicesCubit>()
                        .fetchServices(widget.category.id, refresh: true),
                  ),
                ],
              ),
            );
          }

          final services = state is CategoryServicesLoaded
              ? state.services
              : state is CategoryServicesLoadingMore
              ? state.current
              : <ServiceModel>[];

          final isLoadingMore = state is CategoryServicesLoadingMore;

          if (services.isEmpty && state is CategoryServicesLoaded) {
            return const EmptyDataWidget(
              title: 'no_services_found',
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<CategoryServicesCubit>()
                .fetchServices(widget.category.id, refresh: true),
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
                          color: ZienaColors.primary, strokeWidth: 2),
                    ),
                  );
                }
                return _ServiceListCard(
                  service: services[i],
                  onBookNow: () {
                    AppNavigator.push(ServiceDetailScreen(serviceId: services[i].id, preview: services[i],));
                  }
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Service List Card (matches image: big image left + Book Now button) ────────
class _ServiceListCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onBookNow;

  const _ServiceListCard(
      {required this.service, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final name = service.localizedName(lang);
    final category = service.localizedCategory(lang);

    return GestureDetector(
      onTap: onBookNow,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: ZienaColors.bg2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.primary, width: 0.6),
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
            SizedBox(width: 5,),
            // ── Image ───────────────────────────────────────────────────────
            ClipRRect(
              borderRadius:
              BorderRadius.circular(16),
              child: service.image != null
                  ? CachedNetworkImage(
                imageUrl: service.image!,
                width: 145,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(width: 145, height: 140, color: ZienaColors.bg3),
                errorWidget: (_, _, _) => _imgFallback(),
              )
                  : _imgFallback(),
            ),

            // ── Details ──────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category label
                    Text(
                      category,
                      style: const TextStyle(
                        
                        fontSize: 10,
                        color: ZienaColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Rating
                    StarRating(rating: service.avgRating, size: 14),
                    const SizedBox(height: 4),

                    // Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                            '${service.price.pricePerHour.toStringAsFixed(0)} ${service.price.currency} ',
                            style: const TextStyle(
                              
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ZienaColors.primary,
                            ),
                          ),
                          TextSpan(
                            text: _priceLabel(service.type),
                            style: const TextStyle(
                              
                              fontSize: 12,
                              color: ZienaColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Book Now button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ZienaColors.primary,
                          minimumSize: const Size(double.infinity, 38),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'book_now'.tr(),
                          style: const TextStyle(
                            
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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
      height: 140,
      color: ZienaColors.bg3,
      child: const Icon(Icons.cleaning_services_rounded,
          color: ZienaColors.primary, size: 40),
    );
  }

  String _priceLabel(String type) {
    switch (type) {
      case 'hourly':
        return 'Per Hour';
      case 'moqema':
        return 'Resident';
      default:
        return 'Per Session';
    }
  }
}

class _SubChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SubChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? ZienaColors.primary : ZienaColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: selected ? 1.5 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? Colors.white : ZienaColors.textPrimary,
          ),
        ),
      ),
    );
  }
}