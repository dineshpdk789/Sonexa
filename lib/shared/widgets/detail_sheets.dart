import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';

// Helper to display a standardized loading/header layout in draggable sheet
Widget _buildSheetHeader({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String imageUrl,
  required ColorScheme cs,
  required VoidCallback? onPlayAll,
  required bool isArtist,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover Image / Avatar
        ClipRRect(
          borderRadius: BorderRadius.circular(isArtist ? 60 : 16),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 100,
              height: 100,
              color: cs.surfaceContainerHighest,
              child: Icon(isArtist ? Icons.person_rounded : Icons.album_rounded, size: 40),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 100,
              height: 100,
              color: cs.surfaceContainerHighest,
              child: Icon(isArtist ? Icons.person_rounded : Icons.album_rounded, size: 40),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Title, Subtitle and Action Button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (onPlayAll != null)
                ElevatedButton.icon(
                  onPressed: onPlayAll,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Reusable list view for tracks
Widget _buildTrackList({
  required List<Song> songs,
  required ScrollController scrollController,
  required WidgetRef ref,
  required BuildContext context,
  required ColorScheme cs,
}) {
  if (songs.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text('No tracks available in this list.'),
      ),
    );
  }

  return ListView.builder(
    controller: scrollController,
    itemCount: songs.length,
    itemBuilder: (context, index) {
      final song = songs[index];
      return ListTile(
        leading: Text(
          '${index + 1}',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          Formatters.formatDuration(song.durationSeconds),
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
        onTap: () {
          ref.read(playerProvider.notifier).playSong(song, queue: songs);
          Navigator.pop(context);
        },
      );
    },
  );
}

// ── ALBUM DETAILS SHEET ───────────────────────────────────────────────────────

void showAlbumDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  String albumId,
  String title,
  String coverUrl,
  String artistString,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              FutureBuilder<Album?>(
                future: ref.read(albumRepositoryProvider).getAlbum(albumId),
                builder: (context, snapshot) {
                  final album = snapshot.data;
                  final songs = album?.songs ?? [];

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: title,
                          subtitle: album != null
                              ? '${album.artistString} • ${album.year ?? ""} • ${songs.length} songs'
                              : artistString,
                          imageUrl: coverUrl,
                          cs: cs,
                          isArtist: false,
                          onPlayAll: songs.isNotEmpty
                              ? () {
                                  ref.read(playerProvider.notifier).playSong(songs.first, queue: songs);
                                  Navigator.pop(context);
                                }
                              : null,
                        ),
                        const Divider(),
                        Expanded(
                          child: snapshot.connectionState == ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : _buildTrackList(
                                  songs: songs,
                                  scrollController: scrollController,
                                  ref: ref,
                                  context: context,
                                  cs: cs,
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// ── ARTIST DETAILS SHEET ──────────────────────────────────────────────────────

void showArtistDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  String artistId,
  String name,
  String imageUrl,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              FutureBuilder<List<Song>>(
                future: ref.read(artistRepositoryProvider).getArtistSongs(artistId),
                builder: (context, snapshot) {
                  final songs = snapshot.data ?? [];

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: name,
                          subtitle: songs.isNotEmpty
                              ? 'Popular Songs • ${songs.length} tracks'
                              : 'Popular Artist',
                          imageUrl: imageUrl,
                          cs: cs,
                          isArtist: true,
                          onPlayAll: songs.isNotEmpty
                              ? () {
                                  ref.read(playerProvider.notifier).playSong(songs.first, queue: songs);
                                  Navigator.pop(context);
                                }
                              : null,
                        ),
                        const Divider(),
                        Expanded(
                          child: snapshot.connectionState == ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : _buildTrackList(
                                  songs: songs,
                                  scrollController: scrollController,
                                  ref: ref,
                                  context: context,
                                  cs: cs,
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

// ── PLAYLIST DETAILS SHEET ────────────────────────────────────────────────────

void showPlaylistDetailsSheet(
  BuildContext context,
  WidgetRef ref,
  String playlistId,
  String title,
  String coverUrl,
  String description,
) {
  // Asynchronous loader function that also supports mood playlists via search fallback
  Future<List<Song>> fetchPlaylistTracks() async {
    if (playlistId.startsWith('mood_')) {
      String query = 'chill';
      if (playlistId == 'mood_workout') query = 'workout';
      if (playlistId == 'mood_focus') query = 'focus';
      if (playlistId == 'mood_sleep') query = 'sleep';
      return ref.read(songRepositoryProvider).searchSongs(query);
    } else {
      final playlist = await ref.read(playlistRepositoryProvider).getPlaylist(playlistId);
      return playlist?.songs ?? [];
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              FutureBuilder<List<Song>>(
                future: fetchPlaylistTracks(),
                builder: (context, snapshot) {
                  final songs = snapshot.data ?? [];

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSheetHeader(
                          context: context,
                          title: title,
                          subtitle: songs.isNotEmpty
                              ? '${songs.length} songs • $description'
                              : description,
                          imageUrl: coverUrl,
                          cs: cs,
                          isArtist: false,
                          onPlayAll: songs.isNotEmpty
                              ? () {
                                  ref.read(playerProvider.notifier).playSong(songs.first, queue: songs);
                                  Navigator.pop(context);
                                }
                              : null,
                        ),
                        const Divider(),
                        Expanded(
                          child: snapshot.connectionState == ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : _buildTrackList(
                                  songs: songs,
                                  scrollController: scrollController,
                                  ref: ref,
                                  context: context,
                                  cs: cs,
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}
