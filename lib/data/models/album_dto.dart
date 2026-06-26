import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/data/models/song_dto.dart';

class AlbumDto {
  final String id;
  final String name;
  final String? year;
  final List<Map<String, dynamic>> artists;
  final List<Map<String, dynamic>> image;
  final List<Map<String, dynamic>> songs;
  final String? description;

  const AlbumDto({
    required this.id,
    required this.name,
    this.year,
    required this.artists,
    required this.image,
    required this.songs,
    this.description,
  });

  static List<Map<String, dynamic>> _parseArtists(dynamic artistsJson) {
    if (artistsJson == null) return [];
    if (artistsJson is String) {
      return [
        {'name': artistsJson, 'id': ''}
      ];
    }
    if (artistsJson is List) {
      return artistsJson
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (artistsJson is Map) {
      final primary = artistsJson['primary'];
      if (primary is List) {
        return primary
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      final all = artistsJson['all'];
      if (all is List) {
        return all
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseImageList(dynamic val) {
    if (val is List) {
      return val.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  static List<Map<String, dynamic>> _parseSongsList(dynamic val) {
    if (val is List) {
      return val.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  factory AlbumDto.fromJson(Map<String, dynamic> json) {
    return AlbumDto(
      id: json['id'] as String? ?? '',
      name: Formatters.decodeHtmlEntities((json['name'] ?? json['title']) as String? ?? ''),
      year: json['year']?.toString(),
      artists: _parseArtists(json['artists'] ?? json['artist']),
      image: _parseImageList(json['image']),
      songs: _parseSongsList(json['songs']),
      description: json['description'] as String?,
    );
  }

  String get _bestImage {
    if (image.isEmpty) return '';
    return Formatters.upgradeImageQuality(
        image.last['url'] as String? ?? '');
  }

  Album toEntity() => Album(
        id: id,
        title: name,
        artists: artists
            .map((a) =>
                Formatters.decodeHtmlEntities(a['name'] as String? ?? ''))
            .toList(),
        coverUrl: _bestImage,
        year: year,
        songCount: songs.length,
        songs: songs.map((s) => SongDto.fromJson(s).toEntity()).toList(),
        description: description,
      );
}

class ArtistDto {
  final String id;
  final String name;
  final List<Map<String, dynamic>> image;
  final String? bio;
  final int? followerCount;

  const ArtistDto({
    required this.id,
    required this.name,
    required this.image,
    this.bio,
    this.followerCount,
  });

  factory ArtistDto.fromJson(Map<String, dynamic> json) {
    return ArtistDto(
      id: json['id'] as String? ?? '',
      name: Formatters.decodeHtmlEntities(json['name'] as String? ?? ''),
      image: AlbumDto._parseImageList(json['image']),
      bio: json['bio'] as String?,
      followerCount: json['followerCount'] as int?,
    );
  }

  String get _bestImage {
    if (image.isEmpty) return '';
    return Formatters.upgradeImageQuality(
        image.last['url'] as String? ?? '');
  }

  Artist toEntity() => Artist(
        id: id,
        name: name,
        imageUrl: _bestImage,
        bio: bio,
        followerCount: followerCount,
      );
}

class PlaylistDto {
  final String id;
  final String name;
  final String? description;
  final List<Map<String, dynamic>> image;
  final List<Map<String, dynamic>> songs;
  final int? songCount;

  const PlaylistDto({
    required this.id,
    required this.name,
    this.description,
    required this.image,
    required this.songs,
    this.songCount,
  });

  factory PlaylistDto.fromJson(Map<String, dynamic> json) {
    return PlaylistDto(
      id: json['id'] as String? ?? '',
      name: Formatters.decodeHtmlEntities(json['name'] as String? ?? ''),
      description: json['description'] as String?,
      image: AlbumDto._parseImageList(json['image']),
      songs: AlbumDto._parseSongsList(json['songs']),
      songCount: json['songCount'] as int?,
    );
  }

  String get _bestImage {
    if (image.isEmpty) return '';
    return Formatters.upgradeImageQuality(
        image.last['url'] as String? ?? '');
  }

  Playlist toEntity() => Playlist(
        id: id,
        name: name,
        description: description,
        coverUrl: _bestImage,
        songs: songs.map((s) => SongDto.fromJson(s).toEntity()).toList(),
        songCount: songCount ?? songs.length,
      );
}
