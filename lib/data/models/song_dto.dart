import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/domain/entities/song.dart';

/// DTO for JioSaavn song response (saavn.dev API format)
class SongDto {
  final String id;
  final String name;
  final String? year;
  final bool hasLyrics;
  final String? label;
  final List<Map<String, dynamic>> artists;
  final Map<String, dynamic>? album;
  final int duration;
  final List<Map<String, dynamic>> image;
  final List<Map<String, dynamic>> downloadUrl;
  final String? language;
  final String source;

  const SongDto({
    required this.id,
    required this.name,
    this.year,
    required this.hasLyrics,
    this.label,
    required this.artists,
    this.album,
    required this.duration,
    required this.image,
    required this.downloadUrl,
    this.language,
    this.source = 'JioSaavn',
  });

  factory SongDto.fromJson(Map<String, dynamic> json) {
    return SongDto(
      id: json['id'] as String? ?? '',
      name: Formatters.decodeHtmlEntities(json['name'] as String? ?? ''),
      year: json['year'] as String?,
      hasLyrics: json['hasLyrics'] == true || json['hasLyrics'] == 'true',
      label: json['label'] as String?,
      artists: _parseArtists(json),
      album: json['album'] as Map<String, dynamic>?,
      duration: _parseDuration(json['duration']),
      image: _parseImageList(json['image']),
      downloadUrl: _parseDownloadList(json['downloadUrl']),
      language: json['language'] as String?,
      source: json['source'] as String? ?? 'JioSaavn',
    );
  }

  static List<Map<String, dynamic>> _parseArtists(Map<String, dynamic> json) {
    final primary = json['artists']?['primary'] as List?;
    if (primary != null) {
      return primary.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  static int _parseDuration(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  static List<Map<String, dynamic>> _parseImageList(dynamic val) {
    if (val is List) {
      return val.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseDownloadList(dynamic val) {
    if (val is List) {
      return val.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  String get _bestImage {
    if (image.isEmpty) return '';
    // Prefer highest quality
    final quality500 = image.where((e) => e['quality'] == '500x500').toList();
    if (quality500.isNotEmpty) return quality500.first['url'] as String? ?? '';
    return Formatters.upgradeImageQuality(
        image.last['url'] as String? ?? '');
  }

  String? _urlForQuality(String quality) {
    for (final item in downloadUrl) {
      if (item['quality'] == quality) return item['url'] as String?;
    }
    return null;
  }

  Song toEntity() => Song(
        id: id,
        title: name,
        artists: artists.map((a) => Formatters.decodeHtmlEntities(a['name'] as String? ?? '')).toList(),
        artistId: artists.isNotEmpty ? artists.first['id'] as String? : null,
        album: Formatters.decodeHtmlEntities(album?['name'] as String? ?? ''),
        albumId: album?['id'] as String?,
        durationSeconds: duration,
        coverUrl: _bestImage,
        downloadUrl96: _urlForQuality('96kbps'),
        downloadUrl160: _urlForQuality('160kbps'),
        downloadUrl320: _urlForQuality('320kbps'),
        mediaUrl: _urlForQuality('320kbps') ?? _urlForQuality('160kbps'),
        hasLyrics: hasLyrics,
        year: year,
        language: language,
        label: label,
        source: source,
      );
}

/// DTO for search results wrapper
class SearchResultDto<T> {
  final List<T> results;
  final int total;
  final int start;

  const SearchResultDto({
    required this.results,
    required this.total,
    required this.start,
  });
}
