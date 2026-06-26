import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/core/services/download_service.dart';
import 'package:path_provider/path_provider.dart';

// ── State Providers ──────────────────────────────────────────────────────────

final downloadedSongsProvider =
    StateNotifierProvider<DownloadedSongsNotifier, List<Song>>((ref) {
  return DownloadedSongsNotifier();
});

class DownloadedSongsNotifier extends StateNotifier<List<Song>> {
  DownloadedSongsNotifier() : super([]) {
    load();
  }

  void load() {
    state = HiveService.getDownloads();
  }

  Future<void> deleteDownload(Song song) async {
    try {
      final filePath = song.localFilePath;
      if (filePath != null && filePath.isNotEmpty) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await HiveService.removeDownloadTask(song.id);
      load();
    } catch (_) {}
  }
}

final activeTasksProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  bool running = true;
  ref.onDispose(() => running = false);
  while (running) {
    await Future.delayed(const Duration(seconds: 1));
    if (!running) break;
    yield HiveService.getAllDownloadTasks()
        .where((t) => t['status'] == 'downloading' || t['status'] == 'queued')
        .toList();
  }
});

final storageInfoProvider = FutureProvider<Map<String, double>>((ref) async {
  try {
    final docDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${docDir.path}/echo_music_downloads');
    double totalBytes = 0;
    if (await downloadsDir.exists()) {
      await for (final file in downloadsDir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          totalBytes += await file.length();
        }
      }
    }
    // Return MBs
    return {
      'used': totalBytes / (1024 * 1024),
      'limit': 1000.0, // 1GB mock storage warning limit
    };
  } catch (_) {
    return {'used': 0.0, 'limit': 1000.0};
  }
});

// ── Presentation Screen ────────────────────────────────────────────────────────

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final downloads = ref.watch(downloadedSongsProvider);
    final activeTasksAsync = ref.watch(activeTasksProvider);
    final storageInfoAsync = ref.watch(storageInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(downloadedSongsProvider.notifier).load();
              ref.invalidate(storageInfoProvider);
            },
            tooltip: 'Refresh list',
          ),
        ],
      ),
      body: Column(
        children: [
          // Storage info card
          storageInfoAsync.when(
            data: (stats) {
              final used = stats['used'] ?? 0.0;
              final limit = stats['limit'] ?? 1000.0;
              final progress = (used / limit).clamp(0.0, 1.0);
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storage_rounded, color: cs.primary, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Storage Consumption',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${used.toStringAsFixed(1)} MB used',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: cs.onPrimaryContainer.withOpacity(0.12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Limit: ${limit.toInt()} MB (Offline Cache Mode)',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Active Downloads Section
          activeTasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        'DOWNLOADING (${tasks.length})',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final songMap = Map<String, dynamic>.from(task['song'] as Map);
                        final song = Song.fromJson(songMap);
                        final progress = task['progress'] as double? ?? 0.0;
                        final status = task['status'] as String? ?? 'queued';

                        return ListTile(
                          leading: const CircularProgressIndicator(strokeWidth: 3),
                          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${(progress * 100).toInt()}% • ${status.toUpperCase()}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            onPressed: () {
                              ref.read(downloadServiceProvider).cancelDownload(song.id);
                              ref.invalidate(activeTasksProvider);
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Downloads List
          Expanded(
            child: downloads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.download_for_offline_outlined,
                            size: 40,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Downloads Yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Download tracks from player screen\nto play music offline without internet.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: downloads.length,
                    padding: const EdgeInsets.only(bottom: 120),
                    itemBuilder: (context, index) {
                      final song = downloads[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.coverUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: cs.surfaceContainerHighest,
                              child: const Icon(Icons.music_note),
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          song.artistString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          onPressed: () {
                            ref.read(downloadedSongsProvider.notifier).deleteDownload(song);
                            ref.invalidate(storageInfoProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${song.title}" from local storage.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          ref.read(playerProvider.notifier).playSong(song, queue: downloads);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
