import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina_app/core/utils/app_navigator.dart';
import 'package:zeina_app/features/home/presentation/cubit/home_cubti.dart';
import 'app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/bookings/presentation/cubit/bookings_cubit.dart';
import 'features/home/presentation/cubit/category_cubit.dart';
import 'injection_container.dart';

class ZienaApp extends StatelessWidget {
  const ZienaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>(),
        ),
        BlocProvider<HomeCubit>(
          create: (_) => sl<HomeCubit>(),
        ),
        BlocProvider<BookingsCubit>(
          create: (_) => sl<BookingsCubit>(),
        ),
        BlocProvider<CategoriesCubit>(
          create: (_) => sl<CategoriesCubit>(),
        ),
        BlocProvider<CategoryServicesCubit>(
          create: (_) => sl<CategoryServicesCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Ziena',
        navigatorKey: AppNavigator.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ZienaTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const SplashScreen(),
      ),
    );
  }
}
