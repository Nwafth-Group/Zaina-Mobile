import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zeina/app.dart';
import 'package:zeina/core/utils/app_navigator.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/auth/data/models/verification_model.dart';
import 'package:zeina/features/profile/presentation/screens/privacy_screen.dart';
import 'package:zeina/features/profile/presentation/screens/rating_scree.dart';
import 'package:zeina/features/profile/presentation/screens/reports_Screen.dart';
import 'package:zeina/features/profile/presentation/screens/terms_screen.dart';
import 'package:zeina/widgets/custom_icon.dart';
import 'package:zeina/widgets/signin_required_widget.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/verification_cubit.dart';
import '../../../auth/presentation/screens/phone_auth_screen.dart';
import '../../../home/presentation/cubit/address_cubit.dart';
import '../../../home/presentation/screens/my_addresses_screen.dart';
import '../cubit/cards_cubit.dart';
import '../cubit/coupons_cubit.dart';
import '../cubit/points_cubit.dart';
import 'edit_profile_screen.dart';
import 'my_cards_screen.dart';
import 'my_coupons_screen.dart';
import 'my_points_scree.dart';
import 'package:restart_app/restart_app.dart';


class MoreScreen extends StatefulWidget {
  final bool isLoggedIn;
  const MoreScreen({super.key, required this.isLoggedIn});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      context.read<ProfileCubit>().fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: SafeArea(
        child: widget.isLoggedIn
            ?Column(
          children: [
            // ── Title ────────────────────────────────────────────────────────
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 20),
            //   child: Text(
            //     'more'.tr(),
            //     style: const TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.w700,
            //       color: ZienaColors.textPrimary,
            //     ),
            //   ),
            // ),

            const SizedBox(height: 16,),

            Expanded(
              child:  _buildLoggedIn(),
            ),
          ],
        ):_buildGuest(),
      ),
    );
  }

  // ── Logged-in view ────────────────────────────────────────────────────────
  Widget _buildLoggedIn() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final isLoading = state is ProfileLoading;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── Profile header card ──────────────────────────────────────
              _ProfileCard(
                profile: profile,
                isLoading: isLoading,
              ),
              const SizedBox(height: 16),

              // ── Account section ──────────────────────────────────────────
              _MenuGroup(
                items: [
                  // In _buildLoggedIn() → Profile menu item:
                  _MenuItem(
                    icon: 'assets/images/profile.png',
                    label: 'profile'.tr(),
                    onTap: () {
                      if (profile == null) return;
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileCubit>(),
                          child: EditProfileScreen(profile: profile),
                        ),
                      ));
                    },
                  ),
                  _MenuItem(
                    icon: 'assets/images/addresses.png',
                    label: 'my_addresses'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<AddressCubit>(),
                          child: const MyAddressesScreen(),
                        ),
                      ),
                    ),
                  ),
                  // My Cards menu item:
                  _MenuItem(
                    icon: 'assets/images/cards.png',
                    label: 'my_cards'.tr(),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<CardsCubit>(),
                        child: const MyCardsScreen(),
                      ),
                    )),
                  ),
                  _MenuItem(
                    icon: 'assets/images/coupons.png',
                    label: 'my_coupon'.tr(),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => sl<CouponsCubit>(),
                        child: const MyCouponsScreen(),
                      ),
                    )),
                  ),
                  _MenuItem(
                    icon: 'assets/images/my_points.png',
                    label: 'my_points'.tr(),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      // Reuse the app-level PointsCubit (not a fresh
                      // sl<PointsCubit>()) so the balance shown here and
                      // on checkout always come from the same state.
                      builder: (_) => BlocProvider.value(
                        value: context.read<PointsCubit>(),
                        child: const MyPointsScreen(),
                      ),
                    )),
                  ),
                  _MenuItem(
                    icon: 'assets/images/languages.png',
                    label: 'languages'.tr(),
                    onTap: () => _showLanguageSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Support section ──────────────────────────────────────────
              _MenuGroup(
                items: [
                  _MenuItem(
                    icon: 'assets/images/ratings.png',
                    label: 'rating'.tr(),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RatingScreen())),
                  ),
                  _MenuItem(
                    icon: 'assets/images/report.png',
                    label: 'reports'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: 'assets/images/support.png',
                    label: 'support'.tr(),
                    onTap: () => _openWhatsAppSupport(),
                  ),
                  _MenuItem(
                    icon: 'assets/images/terms.png',
                    label: 'terms_and_conditions'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsScreen()),
                    ),
                  ),
                  _MenuItem(
                    icon: 'assets/images/privacy.png',
                    label: 'privacy_policy'.tr(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Logout ───────────────────────────────────────────────────
              _LogoutButton(onTap: () => _confirmLogout(context)),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  // ── Guest view ────────────────────────────────────────────────────────────
  Widget _buildGuest() {
    return SignInRequiredWidget(tabKey: 'more');
  }

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ZienaColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LanguageSheet(),
    );
  }

  Future<void> _openWhatsAppSupport() async {
    final uri = Uri.parse('https://wa.me/966567181328');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('logout'.tr(),
            style: const TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Text('logout_confirm'.tr(),
            style: const TextStyle(
                fontFamily: 'Poppins', color: ZienaColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: ZienaColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SharedPrefHelper.clearAll();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => sl<AuthCubit>(),
                    child: const PhoneAuthScreen(),
                  ),
                ),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ZienaColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('logout'.tr(),
                style: const TextStyle(
                    fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Profile Card
// ═══════════════════════════════════════════════════════════════════════════════
class _ProfileCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isLoading;

  const _ProfileCard({this.profile, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ZienaColors.primary, ZienaColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ZienaColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        // Avatar
        _buildAvatar(),
        const SizedBox(width: 14),

        // Name + phone
        Expanded(
          child: isLoading
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120, height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 90, height: 11,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                profile?.mobileNumber ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Points badge
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        //   decoration: BoxDecoration(
        //     color: Colors.white.withOpacity(0.2),
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(color: Colors.white.withOpacity(0.3)),
        //   ),
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       const ImageAsset('assets/images/points.png'),
        //       const SizedBox(height: 2),
        //       Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Text(
        //             isLoading ? '--' : '${(profile?.walletBalance ?? 0).toInt()}',
        //             style: const TextStyle(
        //               fontSize: 13,
        //               fontWeight: FontWeight.w700,
        //               color: Colors.white,
        //             ),
        //           ),
        //
        //           Text(
        //             ' '+'pts'.tr(),
        //             style: const TextStyle(
        //               fontSize: 9,
        //               color: Colors.white70,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
      ]),
    );
  }

  Widget _buildAvatar() {
    if (isLoading) {
      return Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
      );
    }

    if (profile?.image != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: profile!.image!,
          width: 56, height: 56,
          fit: BoxFit.cover,
          placeholder: (_, __) => _avatarFallback(),
          errorWidget: (_, __, ___) => _avatarFallback(),
        ),
      );
    }

    return _avatarFallback();
  }

  Widget _avatarFallback() {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Center(
        child: Text(
          profile?.initials ?? '',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Menu Group
// ═══════════════════════════════════════════════════════════════════════════════
class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZienaColors.bg2,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return _MenuTile(
            item:   item,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;

  const _MenuTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(children: [
              // Icon in circle
              ImageAsset(item.icon,
                width: 25, height: 25,
              ),
              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ZienaColors.textPrimary,
                  ),
                ),
              ),

              // Arrow
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: ZienaColors.bg1,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: ZienaColors.primary,
                ),
              ),
            ]),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 66,
            endIndent: 16,
            color: ZienaColors.primaryLight,
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Logout Button
// ═══════════════════════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [ZienaColors.primary, ZienaColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: ZienaColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'logout'.tr(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Language Sheet
// ═══════════════════════════════════════════════════════════════════════════════
class _LanguageSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: ZienaColors.greyBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('languages'.tr(),
              style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              )),
const SizedBox(height: 20),

          _LangOption(
            flag: 'assets/images/us.png',
            label: 'English',
            isSelected: currentLang == 'en',
            onTap: () async {
              lng='en';
              await context.setLocale(Locale(lng));
              await SharedPrefHelper.saveLng(lng);
              await Restart.restartApp();
            },
          ),
          const SizedBox(height: 10),
          _LangOption(
            flag: 'assets/images/eg.png',
            label: 'العربية',
            isSelected: currentLang == 'ar',
            onTap: () async {
              lng='ar';
              await context.setLocale(Locale(lng));
              await SharedPrefHelper.saveLng(lng);
              await Restart.restartApp();
            },
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.bg2 : ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: isSelected ? 1.5 : 0.8,
),
        ),
child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ZienaColors.bg1,
            ),
            child: ClipOval(
              child: Image.asset(flag, width: 28, height: 20, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500,
                color: isSelected
                    ? ZienaColors.primary
                    : ZienaColors.textPrimary,
              ))),
        ]),
      ),
    );
  }
}
