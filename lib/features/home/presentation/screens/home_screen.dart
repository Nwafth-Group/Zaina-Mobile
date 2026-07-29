import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zeina/core/utils/constants.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:zeina/features/services/presentation/screens/hourly_services_list_screen.dart';
import 'package:zeina/features/services/presentation/screens/other_services_list_screen.dart';
import 'package:zeina/features/services/presentation/screens/ziena_services_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/cubit/verification_cubit.dart' show ProfileCubit, ProfileLoaded, ProfileState;
import '../../../bookings/presentation/cubit/bookings_cubit.dart';
import '../../data/model/banner_model.dart';
import '../cubit/address_cubit.dart';
import '../cubit/home_cubti.dart';
import '../../../../widgets/signin_required_widget.dart';
import 'add_edit_address_screen.dart';
import 'my_addresses_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';

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
                        const SizedBox(height: 16),
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildBannerCarousel(data.banners),
                        const SizedBox(height: 24),
                        _buildSectionHeader(AppStrings.chooseTheSuitableService, null),
                        const SizedBox(height: 12),
                        Container(
                          color: const Color(0xFFFDF4F5),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ServiceCard(
                                  label: AppStrings.hourlyServices,
                                  icon: Icons.access_time_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HourlyServicesListScreen(
                                          type: 'hourly',
                                          titleKey: 'Hourly Services',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ServiceCard(
                                  label: AppStrings.otherServices,
                                  icon: Icons.bubble_chart_outlined,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OtherServicesListScreenUi(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if(data.upcomingAppointment.isNotEmpty)...[
                        _buildSectionHeader('upcoming_appointment', null),
                        const SizedBox(height: 12),
                        // Display actual upcoming appointment from API
                        _buildAppointmentCard(data.upcomingAppointment.first),
                        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (_, state) {
              final profile = state is ProfileLoaded ? state.profile : null;
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZienaColors.bg3,
                  border: Border.all(color: ZienaColors.bg4, width: 2),
                ),
                child: ClipOval(
                  child: profile?.image != null
                      ? CachedNetworkImage(
                          imageUrl: profile!.image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const Icon(
                              Icons.person, size: 30, color: ZienaColors.primary),
                          errorWidget: (_, _, _) => const Icon(
                              Icons.person, size: 30, color: ZienaColors.primary),
                        )
                      : profile != null
                          ? Center(
                              child: Text(
                                profile.initials,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ZienaColors.primary,
                                ),
                              ),
                            )
                          : const Icon(Icons.person, size: 30, color: ZienaColors.primary),
                ),
              );
            },
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
                                  ? '${def.shortAddress}, ${def.oneLiner}'
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
                return;
              }
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ));
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
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _bannerCtrl,
          count: banners.length,
          effect: const ExpandingDotsEffect(activeDotColor: ZienaColors.primary, dotHeight: 7, dotWidth: 7),
        ),
      ],
    );
  }

  // Helper for Section Headers
  Widget _buildSectionHeader(String titleKey, String? actionKey,
      {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ZienaServicesScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(banner.image??'', width: double.infinity, height: 200,fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) =>
              Container(height: 200, width: double.infinity, color: ZienaColors.primaryLight, child: Icon(Icons.image, size: 40, color: Colors.white,),)),
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
          borderRadius: BorderRadius.circular(14),
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
                'No upcoming appointments'.tr(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingDetailScreen(bookingId: appointment.id),
            ),
          );
        },
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            color: ZienaColors.bg2,
            borderRadius: BorderRadius.circular(14),
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
                  topStart:    Radius.circular(14),
                  bottomStart: Radius.circular(14),
                ),
                isRtl: isRtl,
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
                      // Text(
                      //   appointment.localizedName(locale),
                      //   style: const TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w700,
                      //     color: ZienaColors.textPrimary,
                      //   ),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      // const SizedBox(height: 2),
                      Text(
                        appointment.localizedName(locale),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ZienaColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        label: '${AppStrings.duration.tr()}: ${appointment.durationText}',
                        color: ZienaColors.primary,
                      ),
                      const SizedBox(height: 4),
                      _InfoChip(
                        icon: Icons.hourglass_empty_outlined,
                        label: '${AppStrings.expectedArrivalTime.tr()}: ${appointment.expectedArrivalTime}',
                        color: ZienaColors.primary,
                      ),
                    ],
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  });

}

Widget _buildDatePanel(
    UpcomingAppointment appointment, {
      required BorderRadiusDirectional borderRadius,
      required bool isRtl,
    }) {
  return Container(
    width: 80,
    height: 108,
    decoration: BoxDecoration(
      color: ZienaColors.primary,
      borderRadius: borderRadius,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              appointment.dateMonth,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 5,),
            Text(
              appointment.dateDay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Text(
          appointment.time,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

      ],
    ),
  );
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  String? label;
  final Color color;

   _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label!,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: ZienaColors.bg2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ZienaColors.primary.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: ZienaColors.bg3,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ZienaColors.primaryDark, size: 32),
              ),
              const SizedBox(height: 8),
              Text(
                label.tr(),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  color: ZienaColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
