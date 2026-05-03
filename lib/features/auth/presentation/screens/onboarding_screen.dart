import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_button.dart';
import 'phone_auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'slide1_title',
      description: 'slide1_desc',
      imagePlaceholder: 'assets/images/board1.png',
      gradientTop: Color(0xFFFFC1CC),
      gradientBottom: Color(0xFFFFE4E8),
    ),
    _OnboardingData(
      title: 'slide2_title',
      description: 'slide2_desc',
      imagePlaceholder: 'assets/images/board2.png',
      gradientTop: Color(0xFFFFD6DF),
      gradientBottom: Color(0xFFFFF0F2),
    ),
    _OnboardingData(
      title: 'slide3_title',
      description: 'slide3_desc',
      imagePlaceholder: 'assets/images/board3.png',
      gradientTop: Color(0xFFFFBEC8),
      gradientBottom: Color(0xFFFFE8EC),
    ),
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToPhone();
    }
  }

  void _navigateToPhone() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PhoneAuthScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (_, i) => _OnboardingPage(data: _pages[i]),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color:_pages[_currentPage].gradientBottom
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            child: Column(
              children: [
                Text(
                  _pages[_currentPage].title.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _pages[_currentPage].description.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: ExpandingDotsEffect(
                    dotColor: ZienaColors.bg4,
                    activeDotColor: ZienaColors.primary,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3,
                  ),
                ),
                const SizedBox(height: 28),
                ZienaButton(
                  text: _currentPage == _pages.length - 1
                      ? 'get_started'.tr()
                      : 'next'.tr(),
                  onTap: _onNext,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String imagePlaceholder;
  final Color gradientTop;
  final Color gradientBottom;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.imagePlaceholder,
    required this.gradientTop,
    required this.gradientBottom,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(data.imagePlaceholder, height: double.infinity, width: double.infinity, fit: BoxFit.cover,),
        Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [data.gradientTop.withAlpha(10), data.gradientBottom],
                )))
      ],
    );
  }
}
