import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/language_selection_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/phone_auth_screen.dart';
import 'features/auth/presentation/screens/success_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'injection_container.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return _buildRoute(const SplashScreen());
      case LanguageSelectionScreen.routeName:
        return _buildRoute(const LanguageSelectionScreen());
      case OnboardingScreen.routeName:
        return _buildRoute(const OnboardingScreen());
      case PhoneAuthScreen.routeName:
        return _buildRoute(
          BlocProvider(
            create: (_) => sl<AuthCubit>(),
            child: const PhoneAuthScreen(),
          ),
        );
      case SuccessScreen.routeName:
        return _buildRoute(const SuccessScreen());
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
