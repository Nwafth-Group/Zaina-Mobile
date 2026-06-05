import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zeina/core/utils/shared_pref_helper.dart';
import 'package:zeina/features/bookings/presentation/screens/bookings_screen.dart';
import 'package:zeina/features/profile/presentation/screens/more_screen.dart';
import 'package:zeina/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:zeina/widgets/signin_required_widget.dart';

import '../core/theme/theme.dart';
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
              final isActive = _selectedIndex == i;
              final item = items[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 2. The body changes based on the selected index
      // IndexedStack is used to keep the state (scroll position, etc.) of the screens alive
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),

      // 3. The Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(),

    );
  }
}