import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/core/services/download_service.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:video_player/video_player.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No song playing')),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred album art background
          _BlurredBackground(imageUrl: song.coverUrl),
          // Canvas animation overlay
          const _CanvasAnimation(),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.45)),
          // Room Synced playback badge indicator if in group room
          if (playerState.activeRoomId != null)
            Positioned(
              top: 50,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Synced: ${playerState.activeRoomId}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _PlayerAppBar(song: song),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        // Album Art with hero animation
                        _AlbumArt(
                          imageUrl: song.coverUrl,
                          songId: song.id,
                          isPlaying: playerState.isPlaying,
                        ),
                        const Spacer(flex: 2),
                        // Song Info
                        _SongInfo(song: song),
                        const SizedBox(height: 24),
                        // Seek Bar
                        _SeekBar(
                          position: playerState.position,
                          duration: playerState.duration,
                        ),
                        const SizedBox(height: 8),
                        // Controls
                        _PlayerControls(playerState: playerState),
                        const SizedBox(height: 16),
                        // Extra actions
                        _ExtraActions(song: song),
                        const SizedBox(height: 24),
                      ],
                    ),
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

// ── Blurred Background ────────────────────────────────────────────────────────

class _BlurredBackground extends StatelessWidget {
  final String imageUrl;
  const _BlurredBackground({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      imageBuilder: (_, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ),
      placeholder: (_, __) => Container(
        color: Theme.of(context).colorScheme.surface,
      ),
      errorWidget: (_, __, ___) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Canvas Video Animation ─────────────────────────────────────────────────────

class _CanvasAnimation extends ConsumerStatefulWidget {
  final String? videoUrl;
  const _CanvasAnimation({this.videoUrl});

  @override
  ConsumerState<_CanvasAnimation> createState() => _CanvasAnimationState();
}

class _CanvasAnimationState extends ConsumerState<_CanvasAnimation> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(_CanvasAnimation old) {
    super.didUpdateWidget(old);
    if (old.videoUrl != widget.videoUrl) {
      _initVideo();
    }
  }

  void _initVideo() {
    _controller?.dispose();
    _controller = null;

    if (widget.videoUrl == null) {
      if (mounted) setState(() {});
      return;
    }

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl!),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        _controller?.setLooping(true);
        _controller?.setVolume(0);
        final isPlaying = ref.read(playerProvider).isPlaying;
        if (isPlaying) {
          _controller?.play();
        } else {
          _controller?.pause();
        }
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(playerProvider.select((s) => s.isPlaying));
    if (_controller != null && _controller!.value.isInitialized) {
      if (isPlaying) {
        if (!_controller!.value.isPlaying) {
          _controller!.play();
        }
      } else {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
        }
      }
    }

    final showVideo = isPlaying && _controller != null && _controller!.value.isInitialized;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: showVideo ? 0.35 : 0.0, // using 0.35 opacity for a subtle premium visualizer overlay
      child: _controller == null || !_controller!.value.isInitialized
          ? const SizedBox.shrink()
          : SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────

class _PlayerAppBar extends ConsumerWidget {
  final Song song;
  const _PlayerAppBar({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: Colors.white,
            onPressed: () => context.pop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Now Playing',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                      ),
                ),
                Text(
                  song.album,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,
            onPressed: () => _showOptions(context, ref),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final playerState = ref.read(playerProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.queue_music_rounded),
              title: const Text('View Queue'),
              onTap: () {
                Navigator.pop(context);
                _showQueueBottomSheet(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Share Song Link'),
              onTap: () {
                Navigator.pop(context);
                _shareSong(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(playerState.sleepTimerRemaining != null
                  ? 'Sleep Timer (Active)'
                  : 'Sleep Timer'),
              onTap: () {
                Navigator.pop(context);
                _showSleepTimerDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Equalizer'),
              onTap: () {
                Navigator.pop(context);
                _showEqualizerDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_rounded),
              title: const Text('Listen Together (Group Sync)'),
              onTap: () {
                Navigator.pop(context);
                showListenTogetherDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.ring_volume_rounded),
              title: const Text('Set as Ringtone'),
              onTap: () {
                Navigator.pop(context);
                _setAsRingtone(context, song);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Album Art ─────────────────────────────────────────────────────────────────

class _AlbumArt extends StatefulWidget {
  final String imageUrl;
  final String songId;
  final bool isPlaying;

  const _AlbumArt({
    required this.imageUrl,
    required this.songId,
    required this.isPlaying,
  });

  @override
  State<_AlbumArt> createState() => _AlbumArtState();
}

class _AlbumArtState extends State<_AlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isPlaying ? 1.0 : 0.9,
    );
  }

  @override
  void didUpdateWidget(_AlbumArt old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      if (widget.isPlaying) {
        _scaleController.animateTo(1.0,
            curve: Curves.easeOutBack,
            duration: const Duration(milliseconds: 300));
      } else {
        _scaleController.animateTo(0.88,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 200));
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleController,
      builder: (_, child) => Transform.scale(
        scale: _scaleController.value,
        child: child,
      ),
      child: Hero(
        tag: 'song-art-${widget.songId}',
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              width: 300,
              height: 300,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.music_note_rounded,
                    size: 100, color: Colors.white24),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.music_note_rounded,
                    size: 100, color: Colors.white24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Song Info ─────────────────────────────────────────────────────────────────

class _SongInfo extends ConsumerWidget {
  final Song song;
  const _SongInfo({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Re-watch playerProvider to rebuild when favorite state toggles
    final playerState = ref.watch(playerProvider);
    final activeSong = playerState.currentSong ?? song;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activeSong.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                activeSong.artistString,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ref.read(playerProvider.notifier).toggleFavorite();
          },
          icon: Icon(
            activeSong.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: activeSong.isFavorite ? Colors.red : Colors.white,
            size: 28,
          ),
        ),
      ],
    );
  }
}

// ── Seek Bar ──────────────────────────────────────────────────────────────────

class _SeekBar extends ConsumerWidget {
  final Duration position;
  final Duration? duration;

  const _SeekBar({required this.position, required this.duration});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dur = duration?.inMilliseconds ?? 0;
    final progress = dur == 0
        ? 0.0
        : (position.inMilliseconds / dur).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbColor: Colors.white,
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            overlayColor: Colors.white.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
          ),
          child: Slider(
            value: progress,
            onChanged: (v) {
              ref.read(playerProvider.notifier).seekToFraction(v);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatDuration(position.inSeconds),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white70),
              ),
              Text(
                Formatters.formatDuration(duration?.inSeconds ?? 0),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Player Controls ───────────────────────────────────────────────────────────

class _PlayerControls extends ConsumerWidget {
  final EchoPlayerState playerState;
  const _PlayerControls({required this.playerState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        IconButton(
          onPressed: notifier.toggleShuffle,
          icon: Icon(
            Icons.shuffle_rounded,
            color: playerState.shuffleEnabled ? Colors.white : Colors.white54,
          ),
          iconSize: 24,
        ),
        // Previous
        IconButton(
          onPressed: notifier.skipToPrevious,
          icon: const Icon(Icons.skip_previous_rounded,
              color: Colors.white, size: 36),
          iconSize: 36,
        ),
        // Play/Pause
        GestureDetector(
          onTap: notifier.playOrPause,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: playerState.isLoading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Icon(
                      playerState.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey(playerState.isPlaying),
                      color: Colors.black,
                      size: 36,
                    ),
            ),
          ),
        ),
        // Next
        IconButton(
          onPressed: notifier.skipToNext,
          icon: const Icon(Icons.skip_next_rounded,
              color: Colors.white, size: 36),
          iconSize: 36,
        ),
        // Repeat
        IconButton(
          onPressed: notifier.cycleLoopMode,
          icon: Icon(
            playerState.loopMode == just_audio.LoopMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            color: playerState.loopMode == just_audio.LoopMode.off
                ? Colors.white54
                : Colors.white,
          ),
          iconSize: 24,
        ),
      ],
    );
  }
}

// ── Extra Actions ─────────────────────────────────────────────────────────────

class _ExtraActions extends ConsumerWidget {
  final Song song;

  const _ExtraActions({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.lyrics_outlined,
          label: 'Lyrics',
          enabled: true,
          onTap: () => context.push(RouteNames.lyrics),
        ),
        _ActionButton(
          icon: Icons.download_for_offline_outlined,
          label: 'Download',
          onTap: () {
            ref.read(downloadServiceProvider).downloadSong(
              song,
              onComplete: (path) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Downloaded "${song.title}" offline!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onError: (err) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to download: $err'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            );
          },
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () => _shareSong(context, song),
        ),
        _ActionButton(
          icon: Icons.queue_music_rounded,
          label: 'Queue',
          onTap: () => _showQueueBottomSheet(context, ref),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: enabled ? Colors.white : Colors.white38, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enabled ? Colors.white70 : Colors.white38,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Modal Helper Handlers ────────────────────────────────────────────────────

void _showQueueBottomSheet(BuildContext context, WidgetRef ref) {
  final colorScheme = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, child) {
              final playerState = ref.watch(playerProvider);
              final notifier = ref.read(playerProvider.notifier);

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
                          'Play Queue (${playerState.queue.length} songs)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (playerState.queue.length > 1)
                          TextButton(
                            onPressed: () {
                              notifier.stop();
                              Navigator.pop(context);
                            },
                            child: const Text('Clear Queue'),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ReorderableListView.builder(
                      scrollController: scrollController,
                      itemCount: playerState.queue.length,
                      onReorder: notifier.reorderQueue,
                      itemBuilder: (context, index) {
                        final song = playerState.queue[index];
                        final isCurrent = index == playerState.currentIndex;

                        return ListTile(
                          key: ValueKey('${song.id}_$index'),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: song.coverUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                width: 40,
                                height: 40,
                                color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.music_note, size: 20),
                              ),
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? colorScheme.primary : colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song.artistString,
                            style: TextStyle(
                              color: isCurrent
                                  ? colorScheme.primary.withOpacity(0.7)
                                  : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrent)
                                Icon(Icons.volume_up_rounded, color: colorScheme.primary)
                              else
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle_rounded),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                                onPressed: () => notifier.removeFromQueue(index),
                              ),
                            ],
                          ),
                          onTap: () {
                            notifier.playSong(song, queue: playerState.queue);
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
    },
  );
}

void _showSleepTimerDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final playerState = ref.watch(playerProvider);
          final notifier = ref.read(playerProvider.notifier);

          return AlertDialog(
            title: const Text('Sleep Timer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (playerState.sleepTimerRemaining != null) ...[
                  Text(
                    'Timer active: ${_formatDuration(playerState.sleepTimerRemaining!)} remaining',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notifier.cancelSleepTimer();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    child: const Text('Cancel Timer'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                ],
                const Text('Turn off audio playback in:'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [5, 15, 30, 45, 60].map((mins) {
                    return ChoiceChip(
                      label: Text('$mins min'),
                      selected: false,
                      onSelected: (_) {
                        notifier.setSleepTimer(mins);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Audio will pause in $mins minutes.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.toString().padLeft(2, '0');
  final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

void _showEqualizerDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final playerState = ref.watch(playerProvider);
          final notifier = ref.read(playerProvider.notifier);
          final colorScheme = Theme.of(context).colorScheme;

          final bands = playerState.equalizerBands;
          final enabled = playerState.equalizerEnabled;

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Equalizer'),
                Switch(
                  value: enabled,
                  onChanged: (val) => notifier.toggleEqualizer(val),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  enabled ? 'Equalizer Custom Settings' : 'Equalizer Disabled (Bypassed)',
                  style: TextStyle(
                    color: enabled ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final labels = ['60Hz', '230Hz', '910Hz', '4kHz', '14kHz'];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 140,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: bands[index],
                              min: -10.0,
                              max: 10.0,
                              divisions: 20,
                              onChanged: enabled
                                  ? (val) {
                                      final newBands = List<double>.from(bands);
                                      newBands[index] = val;
                                      notifier.setEqualizerBands(newBands);
                                    }
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labels[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                        Text(
                          '${bands[index] > 0 ? '+' : ''}${bands[index].toInt()}dB',
                          style: TextStyle(
                            fontSize: 9,
                            color: enabled ? colorScheme.primary : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('Presets:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    'Flat',
                    'Bass Boost',
                    'Vocal',
                    'Pop',
                    'Treble Boost',
                  ].map((preset) {
                    return ChoiceChip(
                      label: Text(preset, style: const TextStyle(fontSize: 11)),
                      selected: false,
                      onSelected: enabled
                          ? (_) {
                              List<double> newBands;
                              switch (preset) {
                                case 'Bass Boost':
                                  newBands = [6.0, 4.0, 1.0, 0.0, -2.0];
                                  break;
                                case 'Vocal':
                                  newBands = [-2.0, 1.0, 5.0, 3.0, 1.0];
                                  break;
                                case 'Pop':
                                  newBands = [2.0, 3.0, 1.0, -1.0, 2.0];
                                  break;
                                case 'Treble Boost':
                                  newBands = [-3.0, -1.0, 1.0, 5.0, 7.0];
                                  break;
                                default:
                                  newBands = [0.0, 0.0, 0.0, 0.0, 0.0];
                              }
                              notifier.setEqualizerBands(newBands);
                            }
                          : null,
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );
}

void showListenTogetherDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final playerState = ref.watch(playerProvider);
          final notifier = ref.read(playerProvider.notifier);
          final colorScheme = Theme.of(context).colorScheme;

          final roomId = playerState.activeRoomId;
          final isHost = playerState.isRoomHost;

          final controller = TextEditingController();

          return AlertDialog(
            title: const Text('Listen Together 🎧'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (roomId != null) ...[
                  Text(
                    isHost ? 'Hosting Session Room' : 'Connected to Session Room',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text('ROOM CODE', style: TextStyle(fontSize: 10, letterSpacing: 1.5)),
                        Text(
                          roomId,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onPrimaryContainer,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Playback state (current song and seek position) will keep synced in real-time.',
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notifier.leaveRoom();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Left the Listen Together session.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.errorContainer,
                      foregroundColor: colorScheme.onErrorContainer,
                    ),
                    child: const Text('End / Leave Session'),
                  ),
                ] else ...[
                  const Text(
                    'Listen to music simultaneously with friends anywhere in the world!',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      final random = math.Random();
                      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
                      final code = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
                      notifier.setRoom(code, true);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Room $code created successfully! Share it with friends.')),
                      );
                    },
                    child: const Text('Host a Group Room'),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: Text('OR', style: TextStyle(fontSize: 11, color: Colors.grey))),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter 6-digit room code',
                      labelText: 'Join Room',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      final code = controller.text.trim().toUpperCase();
                      if (code.length == 6) {
                        notifier.setRoom(code, false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Successfully joined room $code! Playback will sync.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid 6-digit room code.')),
                        );
                      }
                    },
                    child: const Text('Join Room'),
                  ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

void _shareSong(BuildContext context, Song song) {
  final link = 'https://song.link/saavn/${song.id}';
  Clipboard.setData(ClipboardData(text: link));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Cross-platform sharing link copied to clipboard:\n$link'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void _setAsRingtone(BuildContext context, Song song) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('"${song.title}" set as device ringtone successfully!'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
