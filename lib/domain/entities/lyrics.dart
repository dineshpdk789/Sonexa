class Lyrics {
  final String songId;
  final String? plainLyrics;
  final List<LyricsLine>? syncedLines;
  final bool hasSynced;
  final String? copyright;

  const Lyrics({
    required this.songId,
    this.plainLyrics,
    this.syncedLines,
    this.hasSynced = false,
    this.copyright,
  });

  bool get hasLyrics =>
      (plainLyrics?.isNotEmpty ?? false) || (syncedLines?.isNotEmpty ?? false);
}

class LyricsLine {
  final int startTimeMs;
  final String text;

  const LyricsLine({required this.startTimeMs, required this.text});

  Duration get startTime => Duration(milliseconds: startTimeMs);
}
