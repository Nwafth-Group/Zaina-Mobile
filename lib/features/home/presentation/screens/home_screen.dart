import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zeina_app/features/home/presentation/screens/service_categories_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/service_model.dart';
import '../cubit/category_cubit.dart';
import '../cubit/home_cubti.dart';
import '../cubit/search_cubit.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  final PageController _bannerCtrl = PageController();

  @override
  void initState() {
    super.initState();
    // Fetch data when screen opens
    context.read<HomeCubit>().fetchHomeData();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      _buildSectionHeader('popular_services', 'see_all'),
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
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, Amer', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Cairo, Egypt', style: TextStyle(fontSize: 12, color: ZienaColors.textSecondary)),
              ],
            ),
          ),
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
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CategoryChip(category: categories[i]),
      ),
    );
  }

  // ── Popular Services (UPDATED) ─────────────────────────────────────────────
  Widget _buildPopularServices(List<ServiceModel> services) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
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

  // Appointment Card (Placeholder for now)
  Widget _buildAppointmentCard() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text("No upcoming appointments"),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      ('assets/images/active_home.png', 'assets/images/non_active_home.png', 'home'),
      ('assets/images/active_bookings.png', 'assets/images/non_active_bookings.png', 'bookings'),
      ('assets/images/active_wallet.png', 'assets/images/non_active_wallet.png', 'wallet'),
      ('assets/images/active_more.png', 'assets/images/non_active_more.png', 'more'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ZienaColors.bg4,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final isActive = _bottomNavIndex == i;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _bottomNavIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isActive ? 20 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? ZienaColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        isActive ? item.$1 : item.$2,
                        // color: isActive ? Colors.white : ZienaColors.textSecondary,
                        // size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.$3.tr(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
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
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: ZienaColors.bg1, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.category, color: ZienaColors.primary),
        ),
        const SizedBox(height: 4),
        Text(locale == 'ar' ? category.nameAr : category.nameEn, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    return Container(
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
          Expanded(child: Container(color: ZienaColors.bg3, child: const Center(child: Icon(Icons.image)))),
          const SizedBox(height: 8),
          Text(locale == 'ar' ? service.nameAr : service.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${service.price.basePrice} ${service.price.currency}", style: const TextStyle(color: ZienaColors.primary)),
        ],
      ),
    );
  }
}