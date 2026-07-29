import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/theme/theme.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:zeina/features/profile/presentation/screens/more_screen.dart';
import 'package:zeina/features/services/presentation/screens/ziena_services_screen.dart';
import 'package:zeina/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:zeina/widgets/signin_required_widget.dart';
import 'home/presentation/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static _MainScreenState? _state;

  static void switchToTab(int index) {
    _state?._switchToTab(index);
  }

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    MainScreen._state = this;
  }

  @override
  void dispose() {
    MainScreen._state = null;
    super.dispose();
  }

  void _switchToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  // 1. List of your child screens
  // Your existing HomeScreen is the first item in this list
  final List<Widget> _pages = [
    HomeScreen(),
    BookingsScreen(isLoggedIn: SharedPrefHelper.isLoggedIn()),
    WalletScreen(isLoggedIn: SharedPrefHelper.isLoggedIn()),
    MoreScreen(isLoggedIn: SharedPrefHelper.isLoggedIn())
  ];

  void _openZienaServices() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ZienaServicesScreen()),
    );
  }

  Widget _buildBottomNav() {
    // Left pair (Home, Bookings) and right pair (Wallet, More) — split so
    // the floating "+" button can sit centered between them.
    final leftItems = [
      ('assets/images/active_home.png', 'assets/images/non_active_home.png', 'home'),
      ('assets/images/active_bookings.png', 'assets/images/non_active_bookings.png', 'bookings'),
    ];
    final rightItems = [
      ('assets/images/active_wallet.png', 'assets/images/non_active_wallet.png', 'wallet'),
      ('assets/images/active_more.png', 'assets/images/non_active_more.png', 'more'),
    ];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // ── Bar background ────────────────────────────────────────
            Container(
              height: 78,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: ZienaColors.bg3,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      leftItems.length,
                          (i) => _navItem(leftItems[i], i),
                    ),
                  ),
                  const SizedBox(width: 64), // reserved space for the "+" button
                  Row(
                    children: List.generate(
                      rightItems.length,
                          (i) => _navItem(rightItems[i], i + 2),
                    ),
                  ),
                ],
              ),
            ),

            // ── Floating "+" button (Ziena Services) ─────────────────
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: _openZienaServices,
                child: Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: ZienaColors.bg1,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ZienaColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/images/zaina_services.png',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem((String, String, String) item, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? item.$1 : item.$2,
              width: 24,
              height: 24,
              color: isActive
                  ? ZienaColors.primaryDark
                  : ZienaColors.primaryDark.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              item.$3.tr(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w600,
                color: isActive
                    ? ZienaColors.primaryDark
                    : ZienaColors.primaryDark.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. The body changes based on the selected index
      // IndexedStack is used to keep the state (scroll position, etc.) of the screens alive
      body: SafeArea(
        child: Stack(
          alignment: AlignmentGeometry.bottomCenter,
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            _buildBottomNav()
          ],
        ),
      ),

      // 3. The Bottom Navigation Bar
      // bottomNavigationBar: _buildBottomNav(),

    );
  }
}