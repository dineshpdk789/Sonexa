class Formatters {
  Formatters._();

  /// Format seconds to mm:ss
  static String formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Format large numbers (e.g. 1200000 → 1.2M)
  static String formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Fix HTML entities and special characters in strings
  static String decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&apos;', "'");
  }

  /// Upgrade image URL from 150x150 to 500x500
  static String upgradeImageQuality(String url) {
    return url
        .replaceAll('150x150', '500x500')
        .replaceAll('50x50', '500x500');
  }
}
