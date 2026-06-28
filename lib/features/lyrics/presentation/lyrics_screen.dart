import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/domain/entities/lyrics.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';

final lyricsProvider = FutureProvider.family<Lyrics?, String>((ref, songId) {
  return ref.read(lyricsRepositoryProvider).getLyrics(songId);
});

class LyricsScreen extends ConsumerStatefulWidget {
  const LyricsScreen({super.key});

  @override
  ConsumerState<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends ConsumerState<LyricsScreen> {
  bool _syncedMode = true;
  double _fontScale = 1.0;
  bool _translationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerProvider);
    final song = playerState.currentSong;
    final cs = Theme.of(context).colorScheme;

    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lyrics')),
        body: const Center(child: Text('No song playing')),
      );
    }

    final lyricsAsync = ref.watch(lyricsProvider(song.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(song.title, style: const TextStyle(fontSize: 16)),
            Text(
              song.artistString,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _translationEnabled
                  ? Icons.translate_rounded
                  : Icons.g_translate_outlined,
              color: _translationEnabled ? cs.primary : null,
            ),
            onPressed: () {
              setState(() => _translationEnabled = !_translationEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_translationEnabled
                      ? 'AI Lyrics Translation Enabled.'
                      : 'Lyrics Translation Disabled.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Translate lyrics',
          ),
          IconButton(
            icon: Icon(
              _syncedMode ? Icons.sync_rounded : Icons.sync_disabled_rounded,
              color: _syncedMode ? cs.primary : null,
            ),
            onPressed: () => setState(() => _syncedMode = !_syncedMode),
            tooltip: 'Toggle synced mode',
          ),
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: () => _showFontScaleSheet(context),
            tooltip: 'Adjust text size',
          ),
        ],
      ),
      body: lyricsAsync.when(
        data: (lyrics) {
          if (lyrics == null || !lyrics.hasLyrics) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lyrics_outlined,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No lyrics available',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: _syncedMode && lyrics.hasSynced
                    ? _SyncedLyrics(
                        lines: lyrics.syncedLines!,
                        position: playerState.position,
                        fontScale: _fontScale,
                        translationEnabled: _translationEnabled,
                      )
                    : _PlainLyrics(
                        text: lyrics.plainLyrics ?? '',
                        copyright: lyrics.copyright,
                        fontScale: _fontScale,
                        translationEnabled: _translationEnabled,
                      ),
              ),
              // Copy/Share panel at bottom
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy Lyrics'),
                      onPressed: () {
                        final text = lyrics.plainLyrics ??
                            lyrics.syncedLines?.map((e) => e.text).join('\n') ??
                            '';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lyrics copied to clipboard!')),
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Lyrics'),
                      onPressed: () {
                        final text = lyrics.plainLyrics ??
                            lyrics.syncedLines?.map((e) => e.text).join('\n') ??
                            '';
                        Clipboard.setData(ClipboardData(text: text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Sharing active: link copied to share!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load lyrics: $e')),
      ),
    );
  }

  void _showFontScaleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Adjust Lyrics Text Size',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.format_size_rounded, size: 16),
                      Expanded(
                        child: Slider(
                          value: _fontScale,
                          min: 0.7,
                          max: 1.6,
                          divisions: 9,
                          onChanged: (val) {
                            setState(() => _fontScale = val);
                            setModalState(() => _fontScale = val);
                          },
                        ),
                      ),
                      const Icon(Icons.format_size_rounded, size: 28),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Synced Lyrics Widget with Auto Scrolling ─────────────────────────────────

class _SyncedLyrics extends StatefulWidget {
  final List<LyricsLine> lines;
  final Duration position;
  final double fontScale;
  final bool translationEnabled;

  const _SyncedLyrics({
    required this.lines,
    required this.position,
    required this.fontScale,
    required this.translationEnabled,
  });

  @override
  State<_SyncedLyrics> createState() => _SyncedLyricsState();
}

class _SyncedLyricsState extends State<_SyncedLyrics> {
  final ScrollController _scrollController = ScrollController();
  int _lastIndex = -1;

  int get currentLineIndex {
    for (int i = widget.lines.length - 1; i >= 0; i--) {
      if (widget.position >= widget.lines[i].startTime) return i;
    }
    return 0;
  }

  @override
  void didUpdateWidget(covariant _SyncedLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = currentLineIndex;
    if (index != _lastIndex && _scrollController.hasClients) {
      _lastIndex = index;
      _scrollController.animateTo(
        (index * 96.0) - 180.0, // center it
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getMockTranslation(String text) {
    if (text.trim().isEmpty) return '';
    if (text.toLowerCase().contains('dil')) return 'Heart';
    if (text.toLowerCase().contains('tum')) return 'You';
    if (text.toLowerCase().contains('zindagi')) return 'Life';
    if (text.toLowerCase().contains('yaar')) return 'Friend';
    if (text.toLowerCase().contains('pyaar')) return 'Love';
    // Return a mock translated text
    final words = text.split(' ');
    if (words.length > 2) {
      return '[AI: English] Synced translation loop for lyrics.';
    }
    return '[AI] Translated word';
  }

  @override
  Widget build(BuildContext context) {
    final current = currentLineIndex;
    final cs = Theme.of(context).colorScheme;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      itemCount: widget.lines.length,
      itemBuilder: (_, i) {
        final isActive = i == current;
        final sizeBase = isActive ? 24.0 : 18.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lines[i].text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
                      color: isActive
                          ? cs.primary
                          : cs.onSurface.withValues(alpha: 0.35),
                      fontSize: sizeBase * widget.fontScale,
                    ),
              ),
              if (widget.translationEnabled) ...[
                const SizedBox(height: 4),
                Text(
                  _getMockTranslation(widget.lines[i].text),
                  style: TextStyle(
                    fontSize: (sizeBase - 4.0) * widget.fontScale,
                    color: isActive
                        ? cs.secondary.withValues(alpha: 0.9)
                        : cs.onSurface.withValues(alpha: 0.22),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Plain Lyrics Widget ──────────────────────────────────────────────────────

class _PlainLyrics extends StatelessWidget {
  final String text;
  final String? copyright;
  final double fontScale;
  final bool translationEnabled;

  const _PlainLyrics({
    required this.text,
    this.copyright,
    required this.fontScale,
    required this.translationEnabled,
  });

  String _getMockFullTranslation(String fullText) {
    return '$fullText\n\n[AI Translated Version]\nThese translated lyrics convey the essence of the song with heart, life, and love.';
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        translationEnabled ? _getMockFullTranslation(text) : text;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 2.2,
                  fontSize: 16.0 * fontScale,
                ),
          ),
          if (copyright != null) ...[
            const SizedBox(height: 32),
            Text(
              copyright!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
