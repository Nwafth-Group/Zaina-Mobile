import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zeina_app/core/utils/app_navigator.dart';
import 'package:zeina_app/core/utils/shared_pref_helper.dart';
import 'package:zeina_app/features/home/presentation/screens/popular_services_screen.dart';
import 'package:zeina_app/features/home/presentation/screens/service_categories_screen.dart';
import 'package:zeina_app/features/home/presentation/screens/service_screen.dart';
import 'package:zeina_app/features/home/presentation/screens/subcategories_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/service_model.dart';
import '../cubit/address_cubit.dart';
import '../cubit/home_cubti.dart';
import '../cubit/search_cubit.dart';
import '../cubit/service_cubit.dart';
import 'add_edit_address_screen.dart';
import 'my_addresses_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerCtrl = PageController();

  @override
  void initState() {
    super.initState();
    // Fetch data when screen opens
    context.read<HomeCubit>().fetchHomeData();
    callInit();
  }

  void callInit()async{
    if(SharedPrefHelper.isLoggedIn()) {
      await context.read<AddressCubit>().fetchAddresses(); // ← fetch addresses
    }
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
      context.read<HomeCubit>().fetchHomeData();
    },
    child: BlocBuilder<HomeCubit, HomeState>(
    builder: (context, state) {
    if (state is HomeLoading) {
    return const Center(child: CircularProgressIndicator(color: ZienaColors.primary));
    }

    if (state is HomeError) {
    return Center(child: Text(state.message));
    }

    if (state is HomeLoaded) {
    final data = state.data;
    return RefreshIndicator(
    onRefresh: () => context.read<HomeCubit>().fetchHomeData(),
    child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const SizedBox(height: 20),
    _buildHeader(),
    const SizedBox(height: 20),
    _buildSearchBar(),
    const SizedBox(height: 20),
    _buildBannerCarousel(data.banners),
    const SizedBox(height: 24),
    _buildSectionHeader(
    'service_categories',
    'see_all',
    onSeeAll: () => Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => const ServiceCategoriesScreen()
    ),
    ),
    ),
    const SizedBox(height: 14),
    _buildCategories(data.categories),
    // const SizedBox(height: 24),
    // _buildSectionHeader('upcoming_appointment', null),
    // const SizedBox(height: 14),
    // // Pass null or the actual appointment from API
    // _buildAppointmentCard(),
    const SizedBox(height: 24),
    _buildSectionHeader('popular_services', 'see_all', onSeeAll: () => Navigator.push(
    context,
    MaterialPageRoute(
    builder: (_) => BlocProvider(
    create: (_) => sl<PopularServicesCubit>(),
    child: const PopularServicesScreen(),
    ),
    ),
    ),),
    const SizedBox(height: 14),
    _buildPopularServices(data.popularServices),
    const SizedBox(height: 100),
    ],
    ),
    ),
    );
    }
    return const SizedBox();
    },
    ),
    )
    );
  }

  Widget _addressSkeleton() {
    return Container(
      width: 140, height: 10,
      decoration: BoxDecoration(
          color: ZienaColors.greyBorder,
          borderRadius: BorderRadius.circular(5)),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZienaColors.bg3,
              border: Border.all(color: ZienaColors.bg4, width: 2),
            ),
            child: const ClipOval(child: Icon(Icons.person, size: 30, color: ZienaColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text('hello_name'.tr(args: ['Amer']),
                    style: const TextStyle(
                       fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.textPrimary,
                    )),
                const SizedBox(height: 2),

                // Address row — dynamic
                BlocBuilder<AddressCubit, AddressState>(
                  builder: (ctx, addrState) {
                    // Still loading
                    final cubit = ctx.read<AddressCubit>();
                    final hasAddress = cubit.list.isNotEmpty;
                    if (addrState is AddressLoading ||
                        addrState is AddressInitial ||
                        !hasAddress) {
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: const AddEditAddressScreen(),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ZienaColors.bg2,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: ZienaColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.add_location_alt_outlined,
                                      size: 13, color: ZienaColors.primary),
                                  const SizedBox(width: 5),
                                  Text('add_address'.tr(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ZienaColors.primary,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }


                    // ── Has address → show default ──────────────────────────
                    final def = cubit.defaultAddress;
                    final lang = ctx.locale.languageCode;
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const MyAddressesScreen(),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: ZienaColors.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              def != null
                                  ? '${def.shortAddress(lang)}, ${def.oneLiner}'
                                  : '',
                              style: const TextStyle(
                                 fontSize: 12,
                                color: ZienaColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right,
                              size: 14, color: ZienaColors.primary),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ZienaColors.bg2,
              shape: BoxShape.circle,
            ),
            child: Image.asset('assets/images/notifications.png',
                color: ZienaColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => sl<SearchCubit>(), child: const SearchScreen()))),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ZienaColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZienaColors.greyBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: ZienaColors.primary, size: 22),
              const SizedBox(width: 10),
              Text('search'.tr(), style: const TextStyle(color: ZienaColors.textHint)),
              const Spacer(),
              const Icon(Icons.tune_rounded, color: ZienaColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Banner Carousel (UPDATED) ──────────────────────────────────────────────
  Widget _buildBannerCarousel(List<BannerModel> banners) {
    if (banners.isEmpty) return const SizedBox();
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: banners.length,
            itemBuilder: (_, i) => _BannerCard(banner: banners[i]),
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _bannerCtrl,
          count: banners.length,
          effect: const ExpandingDotsEffect(activeDotColor: ZienaColors.primary, dotHeight: 7, dotWidth: 7),
        ),
      ],
    );
  }

  // ── Categories (UPDATED) ───────────────────────────────────────────────────
  Widget _buildCategories(List<CategoryModel> categories) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => InkWell(
            onTap: () {
              AppNavigator.push(SubcategoriesScreen(category: categories[i]));
            },
            child: _CategoryChip(category: categories[i])),
      ),
    );
  }

  // ── Popular Services (UPDATED) ─────────────────────────────────────────────
  Widget _buildPopularServices(List<ServiceModel> services) {
    return SizedBox(
      height: 192,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: services.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _ServiceCard(service: services[i]),
      ),
    );
  }

  // Helper for Section Headers
  Widget _buildSectionHeader(String titleKey, String? actionKey,
      {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titleKey.tr(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
          if (actionKey != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(actionKey.tr(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ZienaColors.primary,
                  )),
            ),
        ],
      ),
    );
  }
}

// ── Updated Sub-Widgets to consume Models ──────────────────────────────────

class _BannerCard extends StatelessWidget {
  final BannerModel banner;
  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [ZienaColors.primary, Color(0xFFFF8FA3)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(banner.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(banner.description, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: ZienaColors.bg1, borderRadius: BorderRadius.circular(16), border: Border.all(color: ZienaColors.primary, width: 0.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(color: ZienaColors.bg2, shape: BoxShape.circle),
            child: const Icon(Icons.category, color: ZienaColors.primary, size: 25,),
          ),
          const SizedBox(width: 4),
          Text(locale == 'ar' ? category.nameAr : category.nameEn, style: const TextStyle(fontSize: 12, color: ZienaColors.black)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    return InkWell(
      onTap: () {
        AppNavigator.push(ServiceDetailScreen(serviceId: service.id, preview: service,));
      },
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: service.image != null
              ? CachedNetworkImage(
            imageUrl: service.image!,
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
                width: double.infinity,
                height: 100,
                color: ZienaColors.bg3),
            errorWidget: (_, _, _) => Container(color: ZienaColors.bg3, child: const Center(child: Icon(Icons.image))),
                        )
              : Container(
              width: double.infinity,
              height: 100, color: ZienaColors.bg3, child: const Center(child: Icon(Icons.image))),
                      ),
            const SizedBox(height: 8),
            Text(locale == 'ar' ? service.nameAr : service.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("${service.price.basePrice} ${service.price.currency}", style: const TextStyle(color: ZienaColors.primary)),
          ],
        ),
      ),
    );
  }
}