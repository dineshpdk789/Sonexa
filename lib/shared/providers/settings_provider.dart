import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/core/storage/hive_service.dart';

// ── Streaming Quality ─────────────────────────────────────────────────────────
final streamingQualityProvider =
    StateNotifierProvider<StreamingQualityNotifier, String>((ref) {
  final saved = HiveService.getSetting<String>(AppConstants.qualityKey) ?? '320kbps';
  return StreamingQualityNotifier(saved);
});

class StreamingQualityNotifier extends StateNotifier<String> {
  StreamingQualityNotifier(super.state);

  Future<void> setQuality(String quality) async {
    state = quality;
    await HiveService.saveSetting(AppConstants.qualityKey, quality);
  }
}

// ── Download Quality ──────────────────────────────────────────────────────────
final downloadQualityProvider =
    StateNotifierProvider<DownloadQualityNotifier, String>((ref) {
  final saved = HiveService.getSetting<String>(AppConstants.downloadQualityKey) ?? '320kbps';
  return DownloadQualityNotifier(saved);
});

class DownloadQualityNotifier extends StateNotifier<String> {
  DownloadQualityNotifier(super.state);

  Future<void> setQuality(String quality) async {
    state = quality;
    await HiveService.saveSetting(AppConstants.downloadQualityKey, quality);
  }
}

// ── Gapless Playback ──────────────────────────────────────────────────────────
final gaplessPlaybackProvider =
    StateNotifierProvider<GaplessPlaybackNotifier, bool>((ref) {
  final saved = HiveService.getSetting<bool>(AppConstants.gaplessPlaybackKey) ?? true;
  return GaplessPlaybackNotifier(saved);
});

class GaplessPlaybackNotifier extends StateNotifier<bool> {
  GaplessPlaybackNotifier(super.state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting(AppConstants.gaplessPlaybackKey, enabled);
  }
}

// ── Crossfade Enabled ─────────────────────────────────────────────────────────
final crossfadeEnabledProvider =
    StateNotifierProvider<CrossfadeEnabledNotifier, bool>((ref) {
  final saved = HiveService.getSetting<bool>(AppConstants.crossfadeEnabledKey) ?? false;
  return CrossfadeEnabledNotifier(saved);
});

class CrossfadeEnabledNotifier extends StateNotifier<bool> {
  CrossfadeEnabledNotifier(super.state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting(AppConstants.crossfadeEnabledKey, enabled);
  }
}

// ── Crossfade Duration ────────────────────────────────────────────────────────
final crossfadeDurationProvider =
    StateNotifierProvider<CrossfadeDurationNotifier, double>((ref) {
  final saved = HiveService.getSetting<double>(AppConstants.crossfadeKey) ?? 3.0;
  return CrossfadeDurationNotifier(saved);
});

class CrossfadeDurationNotifier extends StateNotifier<double> {
  CrossfadeDurationNotifier(super.state);

  Future<void> setDuration(double duration) async {
    state = duration;
    await HiveService.saveSetting(AppConstants.crossfadeKey, duration);
  }
}

// ── Download Location ─────────────────────────────────────────────────────────
final downloadLocationProvider =
    StateNotifierProvider<DownloadLocationNotifier, String>((ref) {
  final saved = HiveService.getSetting<String>(AppConstants.downloadLocationKey) ?? 'internal';
  return DownloadLocationNotifier(saved);
});

class DownloadLocationNotifier extends StateNotifier<String> {
  DownloadLocationNotifier(super.state);

  Future<void> setLocation(String location) async {
    state = location;
    await HiveService.saveSetting(AppConstants.downloadLocationKey, location);
  }
}

// ── Echo Brain ────────────────────────────────────────────────────────────────
final echoBrainEnabledProvider =
    StateNotifierProvider<EchoBrainEnabledNotifier, bool>((ref) {
  final saved = HiveService.getSetting<bool>('echo_brain_enabled') ?? true;
  return EchoBrainEnabledNotifier(saved);
});

class EchoBrainEnabledNotifier extends StateNotifier<bool> {
  EchoBrainEnabledNotifier(super.state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting('echo_brain_enabled', enabled);
  }
}

// ── UI Density ────────────────────────────────────────────────────────────────
final uiDensityProvider =
    StateNotifierProvider<UiDensityNotifier, String>((ref) {
  final saved = HiveService.getSetting<String>('ui_density') ?? 'Medium';
  return UiDensityNotifier(saved);
});

class UiDensityNotifier extends StateNotifier<String> {
  UiDensityNotifier(super.state);

  Future<void> setDensity(String density) async {
    state = density;
    await HiveService.saveSetting('ui_density', density);
  }
}

// ── Accent Color ──────────────────────────────────────────────────────────────
final accentColorProvider =
    StateNotifierProvider<AccentColorNotifier, String>((ref) {
  final saved = HiveService.getSetting<String>('accent_color') ?? 'Purple';
  return AccentColorNotifier(saved);
});

class AccentColorNotifier extends StateNotifier<String> {
  AccentColorNotifier(super.state);

  Future<void> setColor(String color) async {
    state = color;
    await HiveService.saveSetting('accent_color', color);
  }
}

// ── Hide Videos ───────────────────────────────────────────────────────────────
final hideVideosProvider =
    StateNotifierProvider<HideVideosNotifier, bool>((ref) {
  final saved = HiveService.getSetting<bool>('hide_videos') ?? false;
  return HideVideosNotifier(saved);
});

class HideVideosNotifier extends StateNotifier<bool> {
  HideVideosNotifier(super.state);

  Future<void> setHide(bool hide) async {
    state = hide;
    await HiveService.saveSetting('hide_videos', hide);
  }
}

// ── Canvas Animations ─────────────────────────────────────────────────────────
final canvasEnabledProvider =
    StateNotifierProvider<CanvasEnabledNotifier, bool>((ref) {
  final saved = HiveService.getSetting<bool>('canvas_enabled') ?? true;
  return CanvasEnabledNotifier(saved);
});

class CanvasEnabledNotifier extends StateNotifier<bool> {
  CanvasEnabledNotifier(super.state);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await HiveService.saveSetting('canvas_enabled', enabled);
  }
}

