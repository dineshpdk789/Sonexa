import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/core/services/spotify_import_service.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final likedSongsProvider =
    StateNotifierProvider<LikedSongsNotifier, List<Song>>((ref) {
  return LikedSongsNotifier();
});

class LikedSongsNotifier extends StateNotifier<List<Song>> {
  LikedSongsNotifier() : super([]) {
    load();
  }

  void load() {
    state = HiveService.getFavorites();
  }
}

final historySongsProvider =
    StateNotifierProvider<HistorySongsNotifier, List<Song>>((ref) {
  return HistorySongsNotifier();
});

class HistorySongsNotifier extends StateNotifier<List<Song>> {
  HistorySongsNotifier() : super([]) {
    load();
  }

  void load() {
    state = HiveService.getHistory();
  }

  Future<void> clear() async {
    await HiveService.clearHistory();
    load();
  }
}

final customPlaylistsProvider =
    StateNotifierProvider<CustomPlaylistsNotifier, List<Playlist>>((ref) {
  return CustomPlaylistsNotifier();
});

class CustomPlaylistsNotifier extends StateNotifier<List<Playlist>> {
  CustomPlaylistsNotifier() : super([]) {
    load();
  }

  void load() {
    state = HiveService.getPlaylists();
  }

  Future<void> create(String name) async {
    await HiveService.createPlaylist(name);
    load();
  }

  Future<void> delete(String id) async {
    await HiveService.deletePlaylist(id);
    load();
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                ref.read(likedSongsProvider.notifier).load();
                ref.read(historySongsProvider.notifier).load();
                ref.read(customPlaylistsProvider.notifier).load();
              },
              tooltip: 'Refresh library',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Liked Songs'),
              Tab(text: 'History'),
              Tab(text: 'Playlists'),
              Tab(text: 'Downloads'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _LikedSongsTab(),
            _HistoryTab(),
            _PlaylistsTab(),
            _DownloadsTab(),
          ],
        ),
      ),
    );
  }
}

// ── Liked Songs Tab ───────────────────────────────────────────────────────────

class _LikedSongsTab extends ConsumerWidget {
  const _LikedSongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(likedSongsProvider);
    final cs = Theme.of(context).colorScheme;

    if (songs.isEmpty) {
      return _EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No liked songs yet',
        subtitle: 'Songs you mark as favorite will appear here',
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      padding: const EdgeInsets.only(bottom: 120),
      itemBuilder: (context, index) {
        final song = songs[index];
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
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            ref.read(playerProvider.notifier).playSong(song, queue: songs);
          },
        );
      },
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(historySongsProvider);
    final cs = Theme.of(context).colorScheme;

    if (songs.isEmpty) {
      return _EmptyState(
        icon: Icons.history_rounded,
        title: 'No listening history',
        subtitle: 'Songs you play will appear here',
      );
    }

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined),
          title: const Text('Clear Listening History'),
          onTap: () async {
            await ref.read(historySongsProvider.notifier).clear();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listening history cleared.')),
              );
            }
          },
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            padding: const EdgeInsets.only(bottom: 120),
            itemBuilder: (context, index) {
              final song = songs[index];
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
                title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  ref.read(playerProvider.notifier).playSong(song, queue: songs);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Playlists Tab with Spotify Import ─────────────────────────────────────────

class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(customPlaylistsProvider);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCreatePlaylist(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Playlist'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showSpotifyImportDialog(context, ref),
                  icon: const Icon(Icons.import_export_rounded),
                  label: const Text('Import Spotify'),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: playlists.isEmpty
              ? _EmptyState(
                  icon: Icons.playlist_play_rounded,
                  title: 'No playlists yet',
                  subtitle: 'Create local playlists or import from Spotify',
                )
              : ListView.builder(
                  itemCount: playlists.length,
                  padding: const EdgeInsets.only(bottom: 120),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: playlist.coverUrl.isNotEmpty
                            ? Image.network(
                                playlist.coverUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 48,
                                  height: 48,
                                  color: cs.surfaceContainerHighest,
                                  child: const Icon(Icons.playlist_play_rounded),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: cs.primaryContainer,
                                child: Icon(Icons.playlist_play_rounded, color: cs.onPrimaryContainer),
                              ),
                      ),
                      title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${playlist.songCount ?? playlist.songs.length} songs'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => ref.read(customPlaylistsProvider.notifier).delete(playlist.id),
                      ),
                      onTap: () => _showPlaylistSongs(context, ref, playlist),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCreatePlaylist(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name',
            labelText: 'Playlist Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(customPlaylistsProvider.notifier).create(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showSpotifyImportDialog(BuildContext context, WidgetRef ref) {
    final linkController = TextEditingController();
    final nameController = TextEditingController(text: 'My Spotify Import');

    showDialog(
      context: context,
      builder: (dialogContext) {
        double progressVal = 0.0;
        bool isImporting = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Import from Spotify 🚀'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isImporting) ...[
                    const Text(
                      'Paste Spotify Playlist URL to automatically sync tracks to JioSaavn.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: 'Spotify Playlist Link',
                        hintText: 'https://open.spotify.com/playlist/...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Imported Playlist Title',
                      ),
                    ),
                  ] else ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Resolving Spotify tracks to JioSaavn...\n${(progressVal * 100).toInt()}% completed',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progressVal),
                  ],
                ],
              ),
              actions: [
                if (!isImporting) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      final url = linkController.text.trim();
                      final title = nameController.text.trim();
                      if (url.isNotEmpty && title.isNotEmpty) {
                        setDialogState(() => isImporting = true);
                        ref.read(spotifyImportServiceProvider).importPlaylist(
                          url,
                          title,
                          onProgress: (p) {
                            setDialogState(() => progressVal = p);
                          },
                          onComplete: () {
                            ref.read(customPlaylistsProvider.notifier).load();
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Spotify Playlist imported successfully!')),
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Import'),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  void _showPlaylistSongs(BuildContext context, WidgetRef ref, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        playlist.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${playlist.songs.length} songs',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: playlist.songs.isEmpty
                      ? const Center(child: Text('This playlist is empty'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: playlist.songs.length,
                          itemBuilder: (context, idx) {
                            final song = playlist.songs[idx];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  song.coverUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 40,
                                    height: 40,
                                    color: colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.music_note),
                                  ),
                                ),
                              ),
                              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                onPressed: () async {
                                  await HiveService.removeSongFromPlaylist(playlist.id, song.id);
                                  ref.read(customPlaylistsProvider.notifier).load();
                                  if (context.mounted) {
                                    Navigator.pop(context); // close sheet to refresh
                                  }
                                },
                              ),
                              onTap: () {
                                ref.read(playerProvider.notifier).playSong(song, queue: playlist.songs);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Downloads Tab ─────────────────────────────────────────────────────────────

class _DownloadsTab extends ConsumerWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = HiveService.getDownloads();
    final cs = Theme.of(context).colorScheme;

    if (downloads.isEmpty) {
      return _EmptyState(
        icon: Icons.download_outlined,
        title: 'No downloads yet',
        subtitle: 'Download songs from player to play offline',
      );
    }

    return ListView.builder(
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
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            ref.read(playerProvider.notifier).playSong(song, queue: downloads);
          },
        );
      },
    );
  }
}

// ── Empty State Widget ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
