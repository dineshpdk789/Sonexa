import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/core/theme/app_theme.dart';
import 'package:sonexa/core/shared/providers/theme_provider.dart';

import 'package:sonexa/core/services/audio_player_service.dart';

class SonexaApp extends ConsumerStatefulWidget {
  const SonexaApp({super.key});

  @override
  ConsumerState<SonexaApp> createState() => _SonexaAppState();
}

class _SonexaAppState extends ConsumerState<SonexaApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // Cleanly dispose of audio player isolate to prevent ANR and orphaned background processes
      AudioPlayerService.instance.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
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
