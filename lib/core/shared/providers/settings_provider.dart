import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/core/storage/hive_service.dart';

// ── Streaming Quality ─────────────────────────────────────────────────────────
final streamingQualityProvider = NotifierProvider<StreamingQualityNotifier, String>(StreamingQualityNotifier.new);
class StreamingQualityNotifier extends Notifier<String> {
  @override
  String build() => HiveService.getSetting(AppConstants.qualityKey) ?? 'High';
  Future<void> setQuality(String quality) async {
    state = quality;
    await HiveService.saveSetting(AppConstants.qualityKey, quality);
  }
}

// ── Download Quality ──────────────────────────────────────────────────────────
final downloadQualityProvider = NotifierProvider<DownloadQualityNotifier, String>(DownloadQualityNotifier.new);
class DownloadQualityNotifier extends Notifier<String> {
  @override
  String build() => HiveService.getSetting(AppConstants.downloadQualityKey) ?? 'High';
  Future<void> setQuality(String quality) async {
    state = quality;
    await HiveService.saveSetting(AppConstants.downloadQualityKey, quality);
  }
}

// ── Gapless Playback ──────────────────────────────────────────────────────────
final gaplessPlaybackProvider = NotifierProvider<GaplessPlaybackNotifier, bool>(GaplessPlaybackNotifier.new);
class GaplessPlaybackNotifier extends Notifier<bool> {
  @override
  bool build() => HiveService.getSetting(AppConstants.gaplessPlaybackKey) ?? false;
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting(AppConstants.gaplessPlaybackKey, enabled);
  }
}

// ── Crossfade Enabled ─────────────────────────────────────────────────────────
final crossfadeEnabledProvider = NotifierProvider<CrossfadeEnabledNotifier, bool>(CrossfadeEnabledNotifier.new);
class CrossfadeEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => HiveService.getSetting(AppConstants.crossfadeEnabledKey) ?? false;
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting(AppConstants.crossfadeEnabledKey, enabled);
  }
}

// ── Crossfade Duration ────────────────────────────────────────────────────────
final crossfadeDurationProvider = NotifierProvider<CrossfadeDurationNotifier, double>(CrossfadeDurationNotifier.new);
class CrossfadeDurationNotifier extends Notifier<double> {
  @override
  double build() => HiveService.getSetting(AppConstants.crossfadeKey) ?? 0.0;
  Future<void> setDuration(double duration) async {
    state = duration;
    await HiveService.saveSetting(AppConstants.crossfadeKey, duration);
  }
}

// ── Download Location ─────────────────────────────────────────────────────────
final downloadLocationProvider = NotifierProvider<DownloadLocationNotifier, String>(DownloadLocationNotifier.new);
class DownloadLocationNotifier extends Notifier<String> {
  @override
  String build() => HiveService.getSetting(AppConstants.downloadLocationKey) ?? 'Default';
  Future<void> setLocation(String location) async {
    state = location;
    await HiveService.saveSetting(AppConstants.downloadLocationKey, location);
  }
}

// ── Echo Brain ────────────────────────────────────────────────────────────────
final echoBrainEnabledProvider = NotifierProvider<EchoBrainEnabledNotifier, bool>(EchoBrainEnabledNotifier.new);
class EchoBrainEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => HiveService.getSetting('echo_brain_enabled') ?? false;
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting('echo_brain_enabled', enabled);
  }
}

// ── UI Density ────────────────────────────────────────────────────────────────
final uiDensityProvider = NotifierProvider<UiDensityNotifier, String>(UiDensityNotifier.new);
class UiDensityNotifier extends Notifier<String> {
  @override
  String build() => HiveService.getSetting('ui_density') ?? 'comfortable';
  Future<void> setDensity(String density) async {
    state = density;
    await HiveService.saveSetting('ui_density', density);
  }
}

// ── Accent Color ──────────────────────────────────────────────────────────────
final accentColorProvider = NotifierProvider<AccentColorNotifier, String>(AccentColorNotifier.new);
class AccentColorNotifier extends Notifier<String> {
  @override
  String build() => HiveService.getSetting('accent_color') ?? '#FF2196F3';
  Future<void> setColor(String color) async {
    state = color;
    await HiveService.saveSetting('accent_color', color);
  }
}

// ── Hide Videos ───────────────────────────────────────────────────────────────
final hideVideosProvider = NotifierProvider<HideVideosNotifier, bool>(HideVideosNotifier.new);
class HideVideosNotifier extends Notifier<bool> {
  @override
  bool build() => HiveService.getSetting('hide_videos') ?? false;
  Future<void> setHide(bool hide) async {
    state = hide;
    await HiveService.saveSetting('hide_videos', hide);
  }
}

// ── Canvas Animations ─────────────────────────────────────────────────────────
final canvasEnabledProvider = NotifierProvider<CanvasEnabledNotifier, bool>(CanvasEnabledNotifier.new);
class CanvasEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => HiveService.getSetting('canvas_enabled') ?? true;
  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting('canvas_enabled', enabled);
  }
}

// ── Song Language ─────────────────────────────────────────────────────────────
final songLanguageProvider = NotifierProvider<SongLanguageNotifier, List<String>>(SongLanguageNotifier.new);
class SongLanguageNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => HiveService.getStringListSetting('song_language') ?? ['English'];
  Future<void> setLanguage(List<String> languages) async {
    state = languages;
    await HiveService.saveSetting('song_language', languages);
  }
}
