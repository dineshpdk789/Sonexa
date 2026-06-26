class AppConstants {
  AppConstants._();

  static const String appName = 'SONEXA';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int searchPageSize = 10;

  // Debounce
  static const int searchDebounceMs = 300;

  // Cache
  static const int imageCacheMaxAge = 7; // days
  static const int apiCacheMaxAge = 1; // day

  // Downloads
  static const int maxConcurrentDownloads = 3;
  static const String downloadsDirName = 'echo_music_downloads';

  // Player
  static const double defaultCrossfadeDuration = 3.0; // seconds
  static const int sleepTimerDefaultMinutes = 30;

  // Hive box names
  static const String settingsBoxName = 'settings_box';
  static const String searchHistoryBoxName = 'search_history_box';

  // Hive keys
  static const String themeKey = 'theme_mode';
  static const String qualityKey = 'playback_quality';
  static const String crossfadeKey = 'crossfade_duration';
  static const String crossfadeEnabledKey = 'crossfade_enabled';
  static const String downloadQualityKey = 'download_quality';
  static const String gaplessPlaybackKey = 'gapless_playback';
  static const String downloadLocationKey = 'download_location';
}
