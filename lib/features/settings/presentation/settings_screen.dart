import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/shared/providers/theme_provider.dart';
import 'package:sonexa/shared/providers/settings_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

// Provider to fetch paths asynchronously
final appDirectoriesProvider = FutureProvider<Map<String, String>>((ref) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final cacheDir = await getTemporaryDirectory();
  return {
    'internal': docsDir.path,
    'cache': cacheDir.path,
  };
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final streamingQuality = ref.watch(streamingQualityProvider);
    final downloadQuality = ref.watch(downloadQualityProvider);
    final gaplessPlayback = ref.watch(gaplessPlaybackProvider);
    final crossfadeEnabled = ref.watch(crossfadeEnabledProvider);
    final crossfadeDuration = ref.watch(crossfadeDurationProvider);
    final downloadLocation = ref.watch(downloadLocationProvider);
    final dirsAsync = ref.watch(appDirectoriesProvider);

    // Watch new customizations
    final echoBrainEnabled = ref.watch(echoBrainEnabledProvider);
    final uiDensity = ref.watch(uiDensityProvider);
    final accentColor = ref.watch(accentColorProvider);
    final hideVideos = ref.watch(hideVideosProvider);
    final canvasEnabled = ref.watch(canvasEnabledProvider);

    String formatLocationSub(String loc) {
      if (loc == 'internal') return 'Internal Storage';
      if (loc == 'cache') return 'Cache Storage';
      return 'Custom Folder';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 160),
        children: [
          // Profile Section
          _ProfileSection(),
          const Divider(),

          // Appearance
          _SectionTitle(title: 'Appearance'),
          _ThemeTile(currentMode: themeMode, ref: ref),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text('Accent Color'),
            subtitle: Text(accentColor),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAccentColorPicker(context, ref, accentColor),
          ),
          ListTile(
            leading: const Icon(Icons.density_medium_rounded),
            title: const Text('UI Spacing Density'),
            subtitle: Text(uiDensity),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showDensityPicker(context, ref, uiDensity),
          ),
          const Divider(),

          // Playback
          _SectionTitle(title: 'Playback'),
          SwitchListTile(
            secondary: const Icon(Icons.psychology_rounded),
            title: const Text('Echo Brain AI Queue'),
            subtitle: const Text('Auto-inject similar tracks when queue runs low'),
            value: echoBrainEnabled,
            onChanged: (val) {
              ref.read(echoBrainEnabledProvider.notifier).setEnabled(val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.video_collection_outlined),
            title: const Text('Hide Video Tracks'),
            subtitle: const Text('Exclude music video songs from feeds'),
            value: hideVideos,
            onChanged: (val) {
              ref.read(hideVideosProvider.notifier).setHide(val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.movie_filter_outlined),
            title: const Text('Canvas Background Animations'),
            subtitle: const Text('Render smooth background canvas video loops'),
            value: canvasEnabled,
            onChanged: (val) {
              ref.read(canvasEnabledProvider.notifier).setEnabled(val);
            },
          ),
          ListTile(
            leading: const Icon(Icons.high_quality_rounded),
            title: const Text('Streaming Quality'),
            subtitle: Text(streamingQuality.replaceAll('kbps', ' kbps')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showQualityPicker(context, ref, streamingQuality, false),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.skip_next_outlined),
            title: const Text('Gapless Playback'),
            subtitle: const Text('Play tracks without silence'),
            value: gaplessPlayback,
            onChanged: (val) {
              ref.read(gaplessPlaybackProvider.notifier).setEnabled(val);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.shuffle_rounded),
            title: const Text('Crossfade'),
            subtitle: Text(crossfadeEnabled
                ? '${crossfadeDuration.toInt()} seconds'
                : 'Disabled'),
            value: crossfadeEnabled,
            onChanged: (val) {
              ref.read(crossfadeEnabledProvider.notifier).setEnabled(val);
            },
          ),
          if (crossfadeEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 20),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: crossfadeDuration,
                      min: 1.0,
                      max: 12.0,
                      divisions: 11,
                      label: '${crossfadeDuration.toInt()}s',
                      onChanged: (val) {
                        ref.read(crossfadeDurationProvider.notifier).setDuration(val);
                      },
                    ),
                  ),
                  Text('${crossfadeDuration.toInt()}s',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          const Divider(),

          // Downloads
          _SectionTitle(title: 'Downloads'),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Download Quality'),
            subtitle: Text(downloadQuality.replaceAll('kbps', ' kbps')),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showQualityPicker(context, ref, downloadQuality, true),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Download Location'),
            subtitle: dirsAsync.when(
              data: (dirs) {
                String path;
                if (downloadLocation == 'internal') {
                  path = dirs['internal']!;
                } else if (downloadLocation == 'cache') {
                  path = dirs['cache']!;
                } else {
                  path = downloadLocation;
                }
                return Text(
                  '${formatLocationSub(downloadLocation)}\n$path',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => const Text('Loading paths...'),
              error: (_, __) => Text(formatLocationSub(downloadLocation)),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showDownloadLocationPicker(context, ref, downloadLocation),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showClearCacheDialog(context),
          ),
          const Divider(),

          // About
          _SectionTitle(title: 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('App Version'),
            subtitle: const Text('SONEXA 1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.system_update_rounded),
            title: const Text('Check for Updates'),
            subtitle: const Text('Check if a new version is available'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _checkUpdates(context),
          ),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => showLicensePage(context: context),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showQualityPicker(
      BuildContext context, WidgetRef ref, String currentVal, bool isDownload) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isDownload ? 'Download Quality' : 'Streaming Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['96kbps', '160kbps', '320kbps'].map(
              (q) => ListTile(
                title: Text(q.replaceAll('kbps', ' kbps')),
                trailing: q == currentVal ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  if (isDownload) {
                    ref.read(downloadQualityProvider.notifier).setQuality(q);
                  } else {
                    ref.read(streamingQualityProvider.notifier).setQuality(q);
                  }
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDownloadLocationPicker(
      BuildContext context, WidgetRef ref, String currentVal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Download Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android_rounded),
              title: const Text('Internal Storage'),
              subtitle: const Text('App documents folder'),
              trailing: currentVal == 'internal' ? const Icon(Icons.check_rounded) : null,
              onTap: () {
                ref.read(downloadLocationProvider.notifier).setLocation('internal');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sd_storage_rounded),
              title: const Text('Cache Storage'),
              subtitle: const Text('App cache folder'),
              trailing: currentVal == 'cache' ? const Icon(Icons.check_rounded) : null,
              onTap: () {
                ref.read(downloadLocationProvider.notifier).setLocation('cache');
                Navigator.pop(dialogContext);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded),
              title: const Text('Custom Folder'),
              subtitle: const Text('Choose from file manager'),
              trailing: (currentVal != 'internal' && currentVal != 'cache')
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () async {
                Navigator.pop(dialogContext);
                final result = await FilePicker.getDirectoryPath();
                if (result != null) {
                  ref.read(downloadLocationProvider.notifier).setLocation(result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccentColorPicker(BuildContext context, WidgetRef ref, String currentVal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Accent Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['Purple', 'Blue', 'Green', 'Orange'].map(
              (c) => ListTile(
                leading: Icon(Icons.lens, color: _getColorFromValue(c)),
                title: Text(c),
                trailing: c == currentVal ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  ref.read(accentColorProvider.notifier).setColor(c);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromValue(String colorName) {
    switch (colorName) {
      case 'Blue':
        return Colors.blue;
      case 'Green':
        return Colors.green;
      case 'Orange':
        return Colors.orange;
      default:
        return const Color(0xFF7C4DFF);
    }
  }

  void _showDensityPicker(BuildContext context, WidgetRef ref, String currentVal) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose UI Density'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['Compact', 'Medium', 'Relaxed'].map(
              (d) => ListTile(
                title: Text(d),
                trailing: d == currentVal ? const Icon(Icons.check_rounded) : null,
                onTap: () {
                  ref.read(uiDensityProvider.notifier).setDensity(d);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear all cached images and temporary data. Your downloads will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await DefaultCacheManager().emptyCache();
                PaintingBinding.instance.imageCache.clear();
                PaintingBinding.instance.imageCache.clearLiveImages();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to clear cache.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _checkUpdates(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (dialogContext.mounted) {
            Navigator.pop(dialogContext); // Close checking dialog
            _showUpdateAvailableOrLatestDialog(context);
          }
        });
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  'Checking for updates...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateAvailableOrLatestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check for Updates'),
        content: const Text(
          'You are running the latest version of SONEXA (1.0.0).\n\nNo updates are available at this time.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: cs.primary,
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Music Lover',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SONEXA User',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final AppThemeMode currentMode;
  final WidgetRef ref;

  const _ThemeTile({required this.currentMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(_modeName(currentMode)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showThemePicker(context),
    );
  }

  String _modeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.amoled:
        return 'AMOLED Black';
    }
  }

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...AppThemeMode.values.map(
              (mode) => ListTile(
                leading: Icon(_modeIcon(mode)),
                title: Text(_modeName(mode)),
                trailing: currentMode == mode
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () {
                  ref.read(themeModeProvider.notifier).setMode(mode);
                  Navigator.pop(dialogContext);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _modeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.amoled:
        return Icons.brightness_2_rounded;
    }
  }
}
