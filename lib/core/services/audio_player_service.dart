import 'package:audio_service/audio_service.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static AudioPlayerService? _instance;
  static AudioPlayerService get instance =>
      _instance ??= AudioPlayerService._();

  AudioPlayerService._();

  late final AudioPlayer _player;
  bool _initialized = false;

  AudioPlayer get player => _player;

  Future<void> init() async {
    if (_initialized) return;
    _player = AudioPlayer();
    _initialized = true;

    // Listen to position stream to apply crossfade / volume fading transitions
    _player.positionStream.listen((position) {
      _applyCrossfade(position);
    });
  }

  void _applyCrossfade(Duration position) {
    try {
      final enabled = HiveService.getSetting<bool>(AppConstants.crossfadeEnabledKey) ?? false;
      if (!enabled) {
        if (_player.volume != 1.0) {
          _player.setVolume(1.0);
        }
        return;
      }

      final duration = _player.duration;
      if (duration == null || duration == Duration.zero) {
        _player.setVolume(1.0);
        return;
      }

      final fadeSeconds = HiveService.getSetting<double>(AppConstants.crossfadeKey) ?? 3.0;
      if (fadeSeconds <= 0) {
        _player.setVolume(1.0);
        return;
      }

      final posMs = position.inMilliseconds;
      final durMs = duration.inMilliseconds;
      final fadeMs = (fadeSeconds * 1000).toInt();

      double volume = 1.0;

      if (posMs < fadeMs) {
        // Fade in at the start of the song
        volume = posMs / fadeMs;
      } else if (durMs - posMs < fadeMs) {
        // Fade out at the end of the song
        volume = (durMs - posMs) / fadeMs;
      }

      final targetVolume = volume.clamp(0.0, 1.0);
      // Avoid excessive bridge calls by only updating if there is a noticeable difference
      if ((_player.volume - targetVolume).abs() > 0.01) {
        _player.setVolume(targetVolume);
      }
    } catch (_) {
      // Prevent exceptions from crashing the stream listener
    }
  }

  Future<void> playSong(Song song) async {
    var url = song.localFilePath ?? song.bestDownloadUrl;
    if (url.isEmpty) return;
    
    // Force HTTPS for streaming URLs to avoid cleartext issues on mobile platforms
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }
    
    await _player.stop();
    await _player.setUrl(
      url, 
      tag: _toMediaItem(song), 
      preload: true,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
        'Referer': 'https://www.jiosaavn.com/',
      },
    );
    await _player.play();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> setQueue(List<Song> songs, int index) async {
    final sources = songs.map((s) {
      var url = s.localFilePath ?? s.bestDownloadUrl;
      if (url.startsWith('http://')) {
        url = url.replaceFirst('http://', 'https://');
      }
      return AudioSource.uri(
        Uri.parse(url), 
        tag: _toMediaItem(s),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Referer': 'https://www.jiosaavn.com/',
        },
      );
    }).toList();

    final playlist = ConcatenatingAudioSource(children: sources);
    await _player.setAudioSource(playlist, initialIndex: index);
    await _player.play();
  }

  Future<void> updateQueue(List<Song> songs, int index) async {
    try {
      final isPlaying = _player.playing;
      final currentPos = _player.position;
      final sources = songs.map((s) {
        var url = s.localFilePath ?? s.bestDownloadUrl;
        if (url.startsWith('http://')) {
          url = url.replaceFirst('http://', 'https://');
        }
        return AudioSource.uri(
          Uri.parse(url), 
          tag: _toMediaItem(s),
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            'Referer': 'https://www.jiosaavn.com/',
          },
        );
      }).toList();

      final playlist = ConcatenatingAudioSource(children: sources);
      await _player.setAudioSource(playlist, initialIndex: index, initialPosition: currentPos);
      if (isPlaying) {
        await _player.play();
      }
    } catch (_) {}
  }

  Future<void> skipToNext() => _player.seekToNext();
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get shuffleModeStream => _player.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  Duration? get duration => _player.duration;
  Duration get position => _player.position;
  bool get isPlaying => _player.playing;
  bool get shuffleEnabled => _player.shuffleModeEnabled;
  LoopMode get loopMode => _player.loopMode;

  void dispose() {
    _player.dispose();
    _initialized = false;
  }

  MediaItem _toMediaItem(Song song) => MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artistString,
        album: song.album,
        artUri: song.coverUrl.isNotEmpty ? Uri.parse(song.coverUrl) : null,
        duration: Duration(seconds: song.durationSeconds),
      );
}
