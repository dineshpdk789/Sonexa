import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/core/theme/app_theme.dart';
import 'package:sonexa/shared/providers/theme_provider.dart';

class SonexaApp extends ConsumerWidget {
  const SonexaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    // Determine dark theme based on mode
    ThemeData darkTheme;
    if (themeMode == AppThemeMode.amoled) {
      darkTheme = AppTheme.amoledTheme;
    } else {
      darkTheme = AppTheme.darkTheme;
    }

    return MaterialApp.router(
      title: 'SONEXA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: darkTheme,
      themeMode: notifier.themeMode,
      routerConfig: appRouter,
    );
  }
}
