import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'theme_state.dart';
import 'widgets/chitra_logo.dart';
import 'app_icons.dart';

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

/// Light and dark themes share one builder so they stay in step.
ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(
    seedColor: brandBlue,
    brightness: brightness,
  );
  final scheme = isDark
      ? base.copyWith(
          surface: brandNavy,
          surfaceContainerHigh: const Color(0xFF1A1F36),
          surfaceContainerHighest: const Color(0xFF232944),
        )
      : base.copyWith(
          surface: const Color(0xFFF7F7FC),
          surfaceContainerHigh: Colors.white,
        );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
    ),
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => const Icon(AppIcons.caretLeft),
      closeButtonIconBuilder: (context) => const Icon(AppIcons.x),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: scheme.onSurface),
      actionTextColor: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class ChitraApp extends StatelessWidget {
  const ChitraApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: appThemeMode,
    builder: (context, mode, child) => MaterialApp(
      title: 'Chitra AI',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      navigatorObservers: [_ClearSnackBarsObserver()],
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const OnboardingScreen(),
    ),
  );
}
