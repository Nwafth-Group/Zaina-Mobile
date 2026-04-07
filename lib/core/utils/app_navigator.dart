// ============================================
// FILE: lib/utils/app_navigator.dart
// ============================================

import 'package:flutter/material.dart';

class AppNavigator {
  // Global navigator key
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Get current context
  static BuildContext? get context => navigatorKey.currentContext;

  // ============================================
  // Basic Navigation Methods
  // ============================================

  /// Push a new screen onto the navigation stack
  /// Returns the result when the screen is popped
  static Future<T?> push<T>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push a new screen and replace the current one
  /// Returns the result when the new screen is popped
  static Future<T?> pushReplacement<T>(Widget page) {
    return navigatorKey.currentState!.pushReplacement<T, void>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Push a new screen and remove all previous screens
  /// Use predicate to control which routes to keep
  static Future<T?> pushAndRemoveUntil<T>(
      Widget page, {
        bool Function(Route<dynamic>)? predicate,
      }) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (_) => page),
      predicate ?? (route) => false, // Remove all by default
    );
  }

  /// Pop the current screen
  /// Optionally pass a result back to the previous screen
  static void pop<T>([T? result]) {
    if (navigatorKey.currentState?.canPop() ?? false) {
      navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Pop screens until the predicate returns true
  static void popUntil(bool Function(Route<dynamic>) predicate) {
    navigatorKey.currentState!.popUntil(predicate);
  }

  /// Pop all screens until reaching the root (first screen)
  static void popToRoot() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  // ============================================
  // Named Routes Navigation (Optional)
  // ============================================

  /// Push a named route
  static Future<T?> pushNamed<T>(
      String routeName, {
        Object? arguments,
      }) {
    return navigatorKey.currentState!.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Push a named route and replace the current screen
  static Future<Future> pushReplacementNamed<T>(
      String routeName, {
        Object? arguments,
      }) async {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  /// Push a named route and remove screens based on predicate
  static Future<T?> pushNamedAndRemoveUntil<T>(
      String routeName, {
        Object? arguments,
        bool Function(Route<dynamic>)? predicate,
      }) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  // ============================================
  // Utility Methods
  // ============================================

  /// Check if we can pop the current screen
  static bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }

  /// Get the current route name (if using named routes)
  static String? getCurrentRouteName() {
    String? routeName;
    navigatorKey.currentState?.popUntil((route) {
      routeName = route.settings.name;
      return true;
    });
    return routeName;
  }

  // ============================================
  // Dialog Methods
  // ============================================

  /// Show a dialog
  static Future<T?> showDialogCustom<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }

  /// Show a bottom sheet
  static Future<T?> showBottomSheetCustom<T>({
    required Widget content,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => content,
    );
  }

  // ============================================
  // Snackbar Methods
  // ============================================

  /// Show a snackbar with a message
  static void showSnackBar(
      String message, {
        Duration duration = const Duration(seconds: 3),
        Color? backgroundColor,
        SnackBarAction? action,
      }) {
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Show an error snackbar
  static void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

/*

// 1. Setup in main.dart:
MaterialApp(
  navigatorKey: AppNavigator.navigatorKey,
  home: SplashScreen(),
)

// 2. Basic navigation:
AppNavigator.push(LoginScreen());
AppNavigator.pushReplacement(HomeScreen());
AppNavigator.pushAndRemoveUntil(HomeScreen());

// 3. Pop navigation:
AppNavigator.pop();
AppNavigator.pop(result); // Pass result back
AppNavigator.popToRoot();

// 4. Named routes (if you set up routes in MaterialApp):
AppNavigator.pushNamed('/login');
AppNavigator.pushNamed('/profile', arguments: userId);

// 5. Dialogs and sheets:
AppNavigator.showDialogCustom(
  dialog: AlertDialog(
    title: Text('Confirm'),
    content: Text('Are you sure?'),
  ),
);

AppNavigator.showBottomSheetCustom(
  content: Container(
    padding: EdgeInsets.all(20),
    child: Text('Bottom Sheet Content'),
  ),
);

// 6. Snackbars:
AppNavigator.showSnackBar('This is a message');
AppNavigator.showSuccessSnackBar('Success!');
AppNavigator.showErrorSnackBar('Error occurred');

// 7. Check if can pop:
if (AppNavigator.canPop()) {
  AppNavigator.pop();
}

// 8. Get current context:
final context = AppNavigator.context;
if (context != null) {
  // Use context
}

*/