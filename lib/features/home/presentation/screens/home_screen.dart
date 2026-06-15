import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/home/presentation/screens/popular_services_screen.dart';
import 'package:zeina/features/home/presentation/screens/service_categories_screen.dart';
import 'package:zeina/features/home/presentation/screens/service_screen.dart';
import 'package:zeina/features/home/presentation/screens/subcategories_screen.dart';
import 'package:zeina/widgets/custom_icon.dart';
import 'package:zeina/widgets/ziena_button.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/cubit/verification_cubit.dart' show ProfileCubit, ProfileLoaded, ProfileState;
import '../../../bookings/presentation/cubit/bookings_cubit.dart';
import '../../data/model/banner_model.dart';
import '../../data/model/service_model.dart';
import '../../../bookings/presentation/screens/booking_details_screen.dart';
import '../cubit/address_cubit.dart';
import '../cubit/home_cubti.dart';
import '../cubit/search_cubit.dart';
import '../cubit/service_cubit.dart';
import '../../../../widgets/signin_required_widget.dart';
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

  void _showAddressDialog() {
    showDialog(
      context: context,
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

  void callInit() async {
    if (SharedPrefHelper.isLoggedIn()) {
      final addressCubit = context.read<AddressCubit>();
      final profileCubit = context.read<ProfileCubit>();
      await addressCubit.fetchAddresses();
      profileCubit.fetchProfile();
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
                        const SizedBox(height: 24),
                        if(data.upcomingAppointment !=null)...[
                        _buildSectionHeader('upcoming_appointment', null),
                        const SizedBox(height: 14),
                        // Display actual upcoming appointment from API
                        _buildAppointmentCard(data.upcomingAppointment),
                        const SizedBox(height: 24)
                        ],
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
                        const SizedBox(height: 60),
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
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (_, state) {
                    final name = state is ProfileLoaded
                        ? (state.profile.firstName ?? state.profile.displayName)
                        : '';
                    return Text(
                      'hello_name'.tr(args: [name]),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    );
                  },
                ),
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
                        onTap: () {
                          if (!SharedPrefHelper.isLoggedIn()) {
                            _showAddressDialog();
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: const AddEditAddressScreen(),
                              ),
                            ),
                          );
                        },
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
          GestureDetector(
            onTap: () {
              if (!SharedPrefHelper.isLoggedIn()) {
                _showAddressDialog();
              }
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/notifications.png',
                  color: ZienaColors.primary),
            ),
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
              const ImageAsset('assets/images/search.png', height: 20, width: 20,),
              const SizedBox(width: 10),
              Text('search'.tr(), style: const TextStyle(color: ZienaColors.textHint)),
              const Spacer(),
              const ImageAsset('assets/images/setting.png', height: 20, width: 20,),
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
      height: 80,
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
      height: 226,
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
            const SizedBox(height: 8),
            ZienaButton(
              text: 'book_now'.tr(),
              onTap: () {},
              backgroundColor: Colors.white,
              textColor: ZienaColors.primary,
              height: 40,
              width: 120,
            )
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  const _CategoryChip({required this.category});

  String _imageFor(CategoryModel cat) {
    final name = '${cat.nameEn}${cat.nameAr}'.toLowerCase();
    if (name.contains('clean')) return 'assets/images/cleaning.png';
    if (name.contains('baby') || name.contains('sitter')) return 'assets/images/babysitter.png';
    return 'assets/images/event.png';
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZienaColors.primary, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(color: ZienaColors.bg2, shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                _imageFor(category),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            locale == 'ar' ? category.nameAr : category.nameEn,
            style: const TextStyle(fontSize: 12, color: ZienaColors.black),
          ),
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

    // Calculate full and empty stars based on avgRating
    int fullStars = service.avgRating.floor();
    bool hasHalfStar = (service.avgRating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return InkWell(
      onTap: () {
        AppNavigator.push(ServiceDetailScreen(
          serviceId: service.id,
          preview: service,
        ));
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(8), // Adjusted for proper spacing
        decoration: BoxDecoration(
      color: ZienaColors.bg2,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: ZienaColors.greyBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Service Image
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
                errorWidget: (_, _, _) => Container(
                    color: ZienaColors.bg3,
                    child: const Center(child: Icon(Icons.image))),
              )
                  : Container(
                  width: double.infinity,
                  height: 100,
                  color: ZienaColors.bg3,
                  child: const Center(child: Icon(Icons.image))),
            ),
            const SizedBox(height: 10),

            // 2. Category Name (Pink Text)
            Text(
              service.localizedCategory(locale),
              style: const TextStyle(
                color: ZienaColors.primary, // Replace with your exact pink accent color code
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),

            // 3. Service Title
            Text(
              service.localizedName(locale),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ZienaColors.black, // Dark blue/slate color as seen in screenshot
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),

            // 4. Price Row
            Text(
              "${service.price.basePrice} ${service.price.currency}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold, // Heavy bold for price emphasis
                color: ZienaColors.black,
              ),
            ),
            const SizedBox(height: 5),

            // 5. Rating Row (Stars and text)
            Row(
              children: [
                Text(
                  service.avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                // Render filled stars
                ...List.generate(fullStars, (_) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 16,
                )),
                // Render half star if applicable
                if (hasHalfStar) const Icon(
                  Icons.star_half_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
                // Render empty stars
                ...List.generate(emptyStars, (_) => const Icon(
                  Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 16,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upcoming Appointment Card ─────────────────────────────────────────────────────
Widget _buildAppointmentCard(UpcomingAppointment? appointment) {
  if (appointment == null) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZienaColors.greyBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                color: ZienaColors.primary,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No upcoming appointments',
                style: const TextStyle(
                  fontSize: 14,
                  color: ZienaColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Builder(builder: (context) {

    final locale = context.locale.languageCode;
    final isRtl = locale == 'ar';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<BookingDetailCubit>()
                  ..fetchDetail(appointment.id),
                child: BookingDetailScreen(bookingId: appointment.id),
              ),
            ),
          );
        },
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            color: ZienaColors.bg2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
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

                _buildDatePanel(
                  appointment,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart:    Radius.circular(18),
                    bottomStart: Radius.circular(18),
                  ),
                  isRtl: isRtl
                ),

              // ── Middle content ────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        appointment.localizedName(locale),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${appointment.price} ${appointment.currency}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _InfoChip(
                              icon: Icons.bookmark_outline_rounded,
                              label: appointment.status,
                              color: _statusColor(appointment.status),
                            ),
                            const SizedBox(width: 3),
                            const _InfoChip(
                              icon: Icons.location_on_outlined,
                              label: 'Home',
                              color: ZienaColors.primary,
                            ),
                            const SizedBox(width: 3),
                            _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: appointment.durationText,
                              color: ZienaColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),


                _buildImage(
                  appointment,
                  borderRadius: const BorderRadiusDirectional.only(
                    topEnd:    Radius.circular(18),
                    bottomEnd: Radius.circular(18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  });

}

Widget _buildImage(
    UpcomingAppointment appointment, {
      required BorderRadiusDirectional borderRadius,
    }) {
  return ClipRRect(
    borderRadius: borderRadius,
    child: appointment.image != null
        ? CachedNetworkImage(
      imageUrl: appointment.image!,
      width: 110,
      height: 108,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
          width: 110, height: 108, color: ZienaColors.bg3),
      errorWidget: (_, __, ___) => Container(
        width: 110,
        height: 108,
        color: ZienaColors.bg3,
        child: const Icon(Icons.cleaning_services_rounded,
            color: ZienaColors.primary, size: 38),
      ),
    )
        : Container(
      width: 110,
      height: 108,
      color: ZienaColors.bg3,
      child: const Icon(Icons.cleaning_services_rounded,
          color: ZienaColors.primary, size: 38),
    ),
  );
}

Widget _buildDatePanel(
    UpcomingAppointment appointment, {
      required BorderRadiusDirectional borderRadius,
      required bool isRtl,
    }) {
  return Container(
    width: 64,
    height: 108,
    decoration: BoxDecoration(
      color: ZienaColors.primary,
      borderRadius: borderRadius,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(!isRtl?Icons.chevron_left:Icons.chevron_right,
            color: Colors.white, size: 22),
        const SizedBox(width: 3),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appointment.dateDay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              appointment.dateMonth,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),

          ],
        ),
      ],
    ),
  );
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Status color ──────────────────────────────────────────────────────────────
Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'upcoming':
      return const Color(0xFF2196F3);
    case 'in service':
    case 'in_service':
      return const Color(0xFFFF9800);
    case 'completed':
      return const Color(0xFF4CAF50);
    case 'cancelled':
      return const Color(0xFFE53935);
    default:
      return ZienaColors.textSecondary;
  }
}
