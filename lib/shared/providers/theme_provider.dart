import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/core/storage/hive_service.dart';

enum AppThemeMode { light, dark, amoled }

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
  final saved = HiveService.getSetting<String>(AppConstants.themeKey);
  final initial = AppThemeMode.values.firstWhere(
    (e) => e.name == saved,
    orElse: () => AppThemeMode.dark,
  );
  return ThemeModeNotifier(initial);
});

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier(super.state);

  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    await HiveService.saveSetting(AppConstants.themeKey, mode.name);
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }
}
