import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final echoBrainServiceProvider = Provider<EchoBrainService>((ref) {
  return EchoBrainService(ref);
});

class EchoBrainService {
  final Ref _ref;
  bool _isProcessing = false;

  EchoBrainService(this._ref);

  Future<void> checkAndInject(
      EchoPlayerState state, PlayerNotifier notifier) async {
    final enabled = HiveService.getSetting<bool>('echo_brain_enabled') ?? true;
    if (!enabled) return;

    if (_isProcessing) return;

    // Trigger injection if remaining tracks in queue fall below 2
    final remaining = state.queue.length - (state.currentIndex + 1);
    if (remaining < 2 && state.queue.isNotEmpty) {
      _isProcessing = true;
      try {
        final currentSong = state.currentSong;
        if (currentSong != null) {
          final query = currentSong.artists.isNotEmpty
              ? currentSong.artists.first
              : currentSong.album;
          final songRepo = _ref.read(songRepositoryProvider);

          final recommendations = await songRepo.searchSongs(query);
          int injectedCount = 0;

          for (final song in recommendations) {
            // Check if track is already in the play queue
            if (!state.queue.any((s) => s.id == song.id) &&
                song.id != currentSong.id) {
              final aiSong = song.copyWith(
                label:
                    'AI: Match artist interest "${currentSong.primaryArtist}"',
              );
              notifier.addToQueue(aiSong);
              injectedCount++;
              if (injectedCount >= 3) break;
            }
          }
        }
      } catch (_) {
      } finally {
        _isProcessing = false;
      }
    }
  }
}
