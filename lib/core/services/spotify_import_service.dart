import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spotifyImportServiceProvider = Provider<SpotifyImportService>((ref) {
  return SpotifyImportService(ref.read(songRepositoryProvider));
});

class SpotifyImportService {
  final SongRepository _songRepo;

  SpotifyImportService(this._songRepo);

  Future<void> importPlaylist(
    String spotifyLink,
    String newPlaylistName, {
    Function(double)? onProgress,
    Function()? onComplete,
  }) async {
    // Create new playlist container
    await HiveService.createPlaylist(newPlaylistName);
    final playlists = HiveService.getPlaylists();
    final newPlaylist = playlists.firstWhere((p) => p.name == newPlaylistName, orElse: () => playlists.last);

    // Mock Spotify tracks list extracted from parsing URL link
    final mockSpotifyTracks = [
      {'title': 'Perfect', 'artist': 'Ed Sheeran'},
      {'title': 'Blinding Lights', 'artist': 'The Weeknd'},
      {'title': 'Kesariya', 'artist': 'Arijit Singh'},
      {'title': 'Stay', 'artist': 'Kid LAROI'},
    ];

    int processed = 0;
    for (final track in mockSpotifyTracks) {
      final query = '${track['title']} ${track['artist']}';
      try {
        final results = await _songRepo.searchSongs(query);
        if (results.isNotEmpty) {
          // Resolve best match song and add to playlist box
          await HiveService.addSongToPlaylist(newPlaylist.id, results.first);
        }
      } catch (_) {}
      processed++;
      onProgress?.call(processed / mockSpotifyTracks.length);
      await Future.delayed(const Duration(milliseconds: 500)); // Rate limit pause
    }
    onComplete?.call();
  }
}
