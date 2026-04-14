import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/utils/constants.dart';
import 'core/utils/shared_pref_helper.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Setup dependency injection
  setupDependencies();

  final prefs = await SharedPreferences.getInstance();
  SharedPrefHelper.init(prefs);
  lng = (await SharedPrefHelper.getLng())??'en';
  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('ar'),
      Locale('en'),
    ],
    path: 'assets/translations',
    fallbackLocale:  Locale(lng),
    startLocale: Locale(lng),
    child: const ZienaApp(),
  ));}
