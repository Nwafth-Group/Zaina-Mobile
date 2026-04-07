import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/theme.dart';

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
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
              _buildBannerCarousel(),
              const SizedBox(height: 24),
              _buildSectionHeader('service_categories', 'see_all'),
              const SizedBox(height: 14),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildSectionHeader('upcoming_appointment', null),
              const SizedBox(height: 14),
              _buildAppointmentCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('popular_services', 'see_all'),
              const SizedBox(height: 14),
              _buildPopularServices(),
              const SizedBox(height: 100),
            ],
          ),
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
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZienaColors.bg3,
              border: Border.all(color: ZienaColors.bg4, width: 2),
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 30, color: ZienaColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    text: 'Hello, ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: ZienaColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: 'Ali',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: ZienaColors.primary),
                    const SizedBox(width: 3),
                    const Text(
                      'Cairo, Nasr City, First District...',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: ZienaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.chevron_right,
                        size: 14, color: ZienaColors.primary),
                  ],
                ),
              ],
            ),
          ),
          // Bell
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ZienaColors.bg2,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined,
                color: ZienaColors.primary, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.greyBorder),
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
            const SizedBox(width: 16),
            const Icon(Icons.search, color: ZienaColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: ZienaColors.textHint,
                  ),
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ZienaColors.bg1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune_rounded,
                  color: ZienaColors.textSecondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner carousel ────────────────────────────────────────────────────────
  Widget _buildBannerCarousel() {
    final banners = [
      _BannerData(
        tag: '30% OFF',
        title: 'Professional Home Cleaning',
        subtitle: 'Book a trusted cleaner for your home today.',
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFF45B8C), Color(0xFFFF8FA3)],
        ),
      ),
      _BannerData(
        tag: '20% OFF',
        title: 'Babysitting Services',
        subtitle: 'Trusted babysitters, available now.',
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFD94A78), Color(0xFFF45B8C)],
        ),
      ),
      _BannerData(
        tag: '15% OFF',
        title: 'Event Hosting Package',
        subtitle: 'Make your event unforgettable.',
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFF8FA3), Color(0xFFFFBEC8)],
        ),
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerCtrl,
            itemCount: banners.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => _BannerCard(data: banners[i]),
          ),
        ),
        const SizedBox(height: 12),
        SmoothPageIndicator(
          controller: _bannerCtrl,
          count: banners.length,
          effect: ExpandingDotsEffect(
            dotColor: ZienaColors.bg4,
            activeDotColor: ZienaColors.primary,
            dotHeight: 7,
            dotWidth: 7,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String titleKey, String? actionKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titleKey.tr(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ZienaColors.textPrimary,
            ),
          ),
          if (actionKey != null)
            GestureDetector(
              onTap: () {},
              child: Text(
                actionKey.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: ZienaColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Categories ─────────────────────────────────────────────────────────────
  Widget _buildCategories() {
    final cats = [
      _CategoryData('Cleaning', Icons.cleaning_services_rounded),
      _CategoryData('Babysitter', Icons.child_care_rounded),
      _CategoryData('Event H...', Icons.celebration_rounded),
      _CategoryData('Cooking', Icons.restaurant_rounded),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CategoryChip(data: cats[i]),
      ),
    );
  }

  // ── Appointment card ────────────────────────────────────────────────────────
  Widget _buildAppointmentCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service image placeholder
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: Container(
                width: 108,
                height: 108,
                color: ZienaColors.bg3,
                child: const Icon(Icons.cleaning_services_rounded,
                    color: ZienaColors.primary, size: 44),
              ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Home Cleaning',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '2500 EGP',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoChip(Icons.bookmark_outline_rounded, 'Upcoming'),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.location_on_outlined, 'Home'),
                        const SizedBox(width: 8),
                        _InfoChip(Icons.access_time_rounded, '3 Hours'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Date panel
            Container(
              width: 64,
              height: 108,
              decoration: const BoxDecoration(
                color: ZienaColors.primary,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '10',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Nov',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Popular services ────────────────────────────────────────────────────────
  Widget _buildPopularServices() {
    final services = [
      _ServiceData('Cleaning', 'Home Cleaning', '2500 EGP'),
      _ServiceData('Cleaning', 'Deep Cleaning', '3200 EGP'),
      _ServiceData('Babysitter', 'Babysitting', '1800 EGP'),
      _ServiceData('Event', 'Event Hosting', '5000 EGP'),
    ];

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _ServiceCard(data: services[i]),
      ),
    );
  }

  // ── Bottom Nav ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, Icons.home_outlined, 'home'),
      (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'bookings'),
      (Icons.wallet_rounded, Icons.wallet_outlined, 'wallet'),
      (Icons.grid_view_rounded, Icons.grid_view_outlined, 'more'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: ZienaColors.white,
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
                      Icon(
                        isActive ? item.$1 : item.$2,
                        color: isActive ? Colors.white : ZienaColors.textSecondary,
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.$3.tr(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

// ── Data models ─────────────────────────────────────────────────────────────

class _BannerData {
  final String tag, title, subtitle;
  final LinearGradient gradient;
  const _BannerData(
      {required this.tag,
        required this.title,
        required this.subtitle,
        required this.gradient});
}

class _CategoryData {
  final String label;
  final IconData icon;
  const _CategoryData(this.label, this.icon);
}

class _ServiceData {
  final String category, title, price;
  const _ServiceData(this.category, this.title, this.price);
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: data.gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.tag,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _CategoryData data;
  const _CategoryChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.bg4.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ZienaColors.bg3,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: ZienaColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              data.label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: ZienaColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            color: ZienaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceData data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 108,
                width: double.infinity,
                color: ZienaColors.bg3,
                child: const Icon(Icons.cleaning_services_rounded,
                    color: ZienaColors.primary, size: 44),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.category,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: ZienaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ZienaColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.price,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ZienaColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}