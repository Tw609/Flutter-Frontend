import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'theme_state.dart';

/// Clears any snackbar when the app moves to another page, so a message from
/// one screen (like "Share is coming soon") never shows on the next one.
class _ClearSnackBarsObserver extends NavigatorObserver {
  void _clear(Route<dynamic> route) {
    // Dialogs, menus and sheets are not pages, so they keep their snackbars.
    if (route is! PageRoute) return;
    final context = navigator?.context;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _clear(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _clear(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _clear(newRoute);
  }
}

class ImagineAiApp extends StatelessWidget {
  const ImagineAiApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appThemeMode,
    builder: (context, mode, child) => MaterialApp(
      title: 'Imagine AI',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      navigatorObservers: [_ClearSnackBarsObserver()],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315BFF)),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F89FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: const OnboardingScreen(),
    ),
  );
}
