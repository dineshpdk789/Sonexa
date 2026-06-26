import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonexa/core/services/audio_player_service.dart';
import 'package:sonexa/core/services/echo_brain_service.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/domain/entities/song.dart';

// ── State ─────────────────────────────────────────────────────────────────────

@immutable
class EchoPlayerState {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration? duration;
  final bool shuffleEnabled;
  final LoopMode loopMode;
  final double volume;
  final Duration? sleepTimerRemaining;
  final List<double> equalizerBands;
  final bool equalizerEnabled;
  final String? activeRoomId;
  final bool isRoomHost;

  const EchoPlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration,
    this.shuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.volume = 1.0,
    this.sleepTimerRemaining,
    this.equalizerBands = const [0.0, 0.0, 0.0, 0.0, 0.0],
    this.equalizerEnabled = false,
    this.activeRoomId,
    this.isRoomHost = false,
  });

  EchoPlayerState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    bool? shuffleEnabled,
    LoopMode? loopMode,
    double? volume,
    Duration? sleepTimerRemaining,
    List<double>? equalizerBands,
    bool? equalizerEnabled,
    String? activeRoomId,
    bool? isRoomHost,
    bool clearCurrentSong = false,
    bool clearSleepTimer = false,
    bool clearRoom = false,
  }) =>
      EchoPlayerState(
        currentSong: clearCurrentSong ? null : (currentSong ?? this.currentSong),
        queue: queue ?? this.queue,
        currentIndex: currentIndex ?? this.currentIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
        loopMode: loopMode ?? this.loopMode,
        volume: volume ?? this.volume,
        sleepTimerRemaining: clearSleepTimer ? null : (sleepTimerRemaining ?? this.sleepTimerRemaining),
        equalizerBands: equalizerBands ?? this.equalizerBands,
        equalizerEnabled: equalizerEnabled ?? this.equalizerEnabled,
        activeRoomId: clearRoom ? null : (activeRoomId ?? this.activeRoomId),
        isRoomHost: clearRoom ? false : (isRoomHost ?? this.isRoomHost),
      );

  double get progress {
    final dur = duration?.inMilliseconds ?? 0;
    if (dur == 0) return 0;
    return (position.inMilliseconds / dur).clamp(0.0, 1.0);
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PlayerNotifier extends StateNotifier<EchoPlayerState> {
  final AudioPlayerService _service;
  final List<StreamSubscription> _subscriptions = [];
  Timer? _sleepTimer;

  PlayerNotifier(this._service) : super(const EchoPlayerState()) {
    listenToStreams();
  }

  void listenToStreams() {
    _subscriptions.addAll([
      _service.positionStream.listen((pos) {
        state = state.copyWith(position: pos);
      }),
      _service.durationStream.listen((dur) {
        state = state.copyWith(duration: dur);
      }),
      _service.playerStateStream.listen((playerState) {
        state = state.copyWith(
          isPlaying: playerState.playing,
          isLoading: playerState.processingState == ProcessingState.loading ||
              playerState.processingState == ProcessingState.buffering,
        );
      }),
      _service.currentIndexStream.listen((idx) {
        if (idx != null && idx < state.queue.length) {
          final activeSong = state.queue[idx];
          // Check if song is favorite in Hive and update flag
          activeSong.isFavorite = HiveService.isFavorite(activeSong.id);
          state = state.copyWith(
            currentIndex: idx,
            currentSong: activeSong,
          );
          // Save play history
          HiveService.addToHistory(activeSong);
        }
      }),
      _service.shuffleModeStream.listen((enabled) {
        state = state.copyWith(shuffleEnabled: enabled);
      }),
      _service.loopModeStream.listen((mode) {
        state = state.copyWith(loopMode: mode);
      }),
    ]);
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    final songQueue = queue ?? [song];
    final idx = songQueue.indexWhere((s) => s.id == song.id);
    final finalIdx = idx >= 0 ? idx : 0;

    song.isFavorite = HiveService.isFavorite(song.id);

    state = state.copyWith(
      currentSong: song,
      queue: songQueue,
      currentIndex: finalIdx,
      isLoading: true,
    );

    try {
      await _service.setQueue(songQueue, finalIdx);
    } catch (e) {
      // ignore: avoid_print
      print('Playback Error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> playOrPause() async {
    if (state.isPlaying) {
      await _service.pause();
    } else {
      await _service.play();
    }
  }

  Future<void> pause() => _service.pause();
  Future<void> play() => _service.play();
  Future<void> stop() => _service.stop();

  Future<void> seekTo(Duration position) => _service.seek(position);

  Future<void> seekToFraction(double fraction) {
    final dur = state.duration ?? Duration.zero;
    final target = Duration(
        milliseconds: (dur.inMilliseconds * fraction.clamp(0.0, 1.0)).toInt());
    return _service.seek(target);
  }

  Future<void> skipToNext() => _service.skipToNext();
  Future<void> skipToPrevious() => _service.skipToPrevious();

  Future<void> toggleShuffle() async {
    await _service.setShuffleMode(!state.shuffleEnabled);
  }

  Future<void> cycleLoopMode() async {
    LoopMode next;
    switch (state.loopMode) {
      case LoopMode.off:
        next = LoopMode.all;
        break;
      case LoopMode.all:
        next = LoopMode.one;
        break;
      case LoopMode.one:
        next = LoopMode.off;
        break;
    }
    await _service.setLoopMode(next);
  }

  Future<void> setVolume(double volume) => _service.setVolume(volume);

  void addToQueue(Song song) {
    // Avoid duplicate insertions
    if (state.queue.any((s) => s.id == song.id)) return;
    final newQueue = [...state.queue, song];
    state = state.copyWith(queue: newQueue);
    _service.updateQueue(newQueue, state.currentIndex);
  }

  void removeFromQueue(int index) {
    if (index == state.currentIndex) {
      skipToNext();
    }
    final newQueue = List<Song>.from(state.queue)..removeAt(index);
    int newIdx = state.currentIndex;
    if (index < state.currentIndex) {
      newIdx = state.currentIndex - 1;
    }
    state = state.copyWith(
      queue: newQueue,
      currentIndex: newIdx.clamp(0, newQueue.isEmpty ? 0 : newQueue.length - 1),
    );
    _service.updateQueue(newQueue, state.currentIndex);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newQueue = List<Song>.from(state.queue);
    final song = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, song);

    int currentIdx = state.currentIndex;
    if (state.currentSong != null) {
      currentIdx = newQueue.indexWhere((s) => s.id == state.currentSong!.id);
    }

    state = state.copyWith(
      queue: newQueue,
      currentIndex: currentIdx >= 0 ? currentIdx : 0,
    );
    _service.updateQueue(newQueue, state.currentIndex);
  }

  // ── Sleep Timer ─────────────────────────────────────────────────────────────

  void setSleepTimer(int minutes) {
    cancelSleepTimer();
    if (minutes <= 0) return;

    state = state.copyWith(sleepTimerRemaining: Duration(minutes: minutes));
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 1) {
        timer.cancel();
        pause();
        state = state.copyWith(clearSleepTimer: true);
      } else {
        state = state.copyWith(
            sleepTimerRemaining: remaining - const Duration(seconds: 1));
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(clearSleepTimer: true);
  }

  // ── Equalizer ───────────────────────────────────────────────────────────────

  void setEqualizerBands(List<double> bands) {
    state = state.copyWith(equalizerBands: bands);
    HiveService.saveSetting('equalizer_bands', bands);
  }

  void toggleEqualizer(bool enabled) {
    state = state.copyWith(equalizerEnabled: enabled);
    HiveService.saveSetting('equalizer_enabled', enabled);
  }

  // ── Favorites (Liked Songs) ──────────────────────────────────────────────────

  Future<void> toggleFavorite() async {
    final song = state.currentSong;
    if (song == null) return;
    
    final isFav = HiveService.isFavorite(song.id);
    if (isFav) {
      await HiveService.removeFavorite(song.id);
      song.isFavorite = false;
    } else {
      await HiveService.addFavorite(song);
      song.isFavorite = true;
    }
    
    state = state.copyWith(
      currentSong: song.copyWith(isFavorite: !isFav),
      // Update song object inside the queue as well
      queue: state.queue.map((s) {
        if (s.id == song.id) {
          return s.copyWith(isFavorite: !isFav);
        }
        return s;
      }).toList(),
    );
  }

  // ── Listen Together (Room syncing) ──────────────────────────────────────────

  void setRoom(String roomId, bool isHost) {
    state = state.copyWith(activeRoomId: roomId, isRoomHost: isHost);
  }

  void leaveRoom() {
    state = state.copyWith(clearRoom: true);
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final playerProvider =
    StateNotifierProvider<PlayerNotifier, EchoPlayerState>((ref) {
  final notifier = PlayerNotifier(AudioPlayerService.instance);
  ref.listenSelf((previous, next) {
    if (next.currentSong != null) {
      ref.read(echoBrainServiceProvider).checkAndInject(next, notifier);
    }
  });
  return notifier;
});
