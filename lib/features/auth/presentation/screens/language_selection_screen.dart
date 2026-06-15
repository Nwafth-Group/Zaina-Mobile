import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/constants.dart';
import '../../../../widgets/ziena_button.dart';
import '../../../../widgets/ziena_logo.dart';
import 'onboarding_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  static const String routeName = '/language';
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLang = 'en';

  void _onNext() {
    lng = _selectedLang;
    context.setLocale(Locale(lng));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const SizedBox(height: 80),
              const Spacer(),
              Text(
                'select_language'.tr(),
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 260,
                child: Text(
                  'select_language_hint'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ZienaColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              _LanguageTile(
                flag: 'assets/images/us.png',
                language: 'english'.tr(),
                isSelected: _selectedLang == 'en',
                onTap: () => setState(() => _selectedLang = 'en'),
              ),
              const SizedBox(height: 12),
              _LanguageTile(
                flag: 'assets/images/eg.png',
                language: 'arabic'.tr(),
                isSelected: _selectedLang == 'ar',
                onTap: () => setState(() => _selectedLang = 'ar'),
              ),
              const Spacer(flex: 2),
              ZienaButton(
                text: 'next'.tr(),
                onTap: _onNext,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? ZienaColors.bg2 : ZienaColors.bg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ZienaColors.bg1,
              ),
              child: ClipOval(
                child: Image.asset(flag, width: 40, height: 40, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
