import 'package:isar/isar.dart';
import 'package:sonexa/domain/entities/song.dart';

part 'song_schema.g.dart';

@collection
class SongSchema {
  Id get isarId => fastHash(id);
  
  late String id;
  late String title;
  late List<String> artists;
  String? artistId;
  late String album;
  String? albumId;
  late int durationSeconds;
  late String coverUrl;
  String? mediaUrl;
  String? downloadUrl96;
  String? downloadUrl160;
  String? downloadUrl320;
  late bool hasLyrics;
  String? year;
  String? language;
  String? label;
  late bool isFavorite;
  String? localFilePath;
  late String source;

  SongSchema();

  factory SongSchema.fromEntity(Song song) {
    return SongSchema()
      ..id = song.id
      ..title = song.title
      ..artists = song.artists
      ..artistId = song.artistId
      ..album = song.album
      ..albumId = song.albumId
      ..durationSeconds = song.durationSeconds
      ..coverUrl = song.coverUrl
      ..mediaUrl = song.mediaUrl
      ..downloadUrl96 = song.downloadUrl96
      ..downloadUrl160 = song.downloadUrl160
      ..downloadUrl320 = song.downloadUrl320
      ..hasLyrics = song.hasLyrics
      ..year = song.year
      ..language = song.language
      ..label = song.label
      ..isFavorite = song.isFavorite
      ..localFilePath = song.localFilePath
      ..source = song.source;
  }

  Song toEntity() {
    return Song(
      id: id,
      title: title,
      artists: artists,
      artistId: artistId,
      album: album,
      albumId: albumId,
      durationSeconds: durationSeconds,
      coverUrl: coverUrl,
      mediaUrl: mediaUrl,
      downloadUrl96: downloadUrl96,
      downloadUrl160: downloadUrl160,
      downloadUrl320: downloadUrl320,
      hasLyrics: hasLyrics,
      year: year,
      language: language,
      label: label,
      isFavorite: isFavorite,
      localFilePath: localFilePath,
      source: source,
    );
  }
}

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
