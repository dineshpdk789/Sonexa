import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sonexa/core/constants/api_constants.dart';
import 'package:sonexa/data/models/album_dto.dart';
import 'package:sonexa/data/models/song_dto.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/domain/entities/lyrics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/network/dio_client.dart';

final jiosaavnDataSourceProvider = Provider<JioSaavnApiDatasource>((ref) {
  return JioSaavnApiDatasource(ref.read(dioProvider));
});

// ── Top Level Parsers for Compute Isolate ─────────────────────────────────────

List<Map<String, dynamic>> _parseResultsList(dynamic rawData) {
  if (rawData == null) return [];
  if (rawData is List) {
    return rawData
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (rawData is Map) {
    final results = rawData['results'] ??
        rawData['songs']?['results'] ??
        rawData['albums']?['results'] ??
        rawData['artists']?['results'] ??
        rawData['playlists']?['results'] ??
        rawData['data']?['results'] ??
        rawData['data'];
    if (results is List) {
      return results
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (results is Map) {
      final innerResults = results['results'];
      if (innerResults is List) {
        return innerResults
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
  }
  return [];
}

List<Song> _parseSongsList(dynamic rawData) {
  final results = _parseResultsList(rawData);
  return results.map((e) => SongDto.fromJson(e).toEntity()).toList();
}

List<Album> _parseAlbumsList(dynamic rawData) {
  final results = _parseResultsList(rawData);
  return results.map((e) => AlbumDto.fromJson(e).toEntity()).toList();
}

List<Artist> _parseArtistsList(dynamic rawData) {
  final results = _parseResultsList(rawData);
  return results.map((e) => ArtistDto.fromJson(e).toEntity()).toList();
}

List<Playlist> _parsePlaylistsList(dynamic rawData) {
  final results = _parseResultsList(rawData);
  return results.map((e) => PlaylistDto.fromJson(e).toEntity()).toList();
}

Song? _parseSingleSong(dynamic data) {
  final songData = data['data'] as Map<String, dynamic>?;
  if (songData == null) return null;
  return SongDto.fromJson(songData).toEntity();
}

Album? _parseSingleAlbum(dynamic data) {
  final albumData = data['data'] as Map<String, dynamic>?;
  if (albumData == null) return null;
  return AlbumDto.fromJson(albumData).toEntity();
}

Artist? _parseSingleArtist(dynamic data) {
  final artistData = data['data'] as Map<String, dynamic>?;
  if (artistData == null) return null;
  return ArtistDto.fromJson(artistData).toEntity();
}

Playlist? _parseSinglePlaylist(dynamic data) {
  final playlistData = data['data'] as Map<String, dynamic>?;
  if (playlistData == null) return null;
  return PlaylistDto.fromJson(playlistData).toEntity();
}

// ── Datasource ────────────────────────────────────────────────────────────────

class JioSaavnApiDatasource {
  final Dio _dio;

  JioSaavnApiDatasource(this._dio);

  // ── Search ────────────────────────────────────────────────────────────────────

  Future<List<Song>> searchSongs(String query,
      {int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiConstants.searchSongs,
      queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseSongsList, data['data'] ?? data);
  }

  Future<List<Album>> searchAlbums(String query, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.searchAlbums,
      queryParameters: {'query': query, 'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseAlbumsList, data['data'] ?? data);
  }

  Future<List<Artist>> searchArtists(String query, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.searchArtists,
      queryParameters: {'query': query, 'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseArtistsList, data['data'] ?? data);
  }

  Future<List<Playlist>> searchPlaylists(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPlaylists,
        queryParameters: {'query': query, 'page': page},
      );
      final data = response.data as Map<String, dynamic>;
      return compute(_parsePlaylistsList, data['data'] ?? data);
    } catch (_) {
      return [];
    }
  }

  // ── Song Details ──────────────────────────────────────────────────────────────

  Future<Song?> getSongById(String id) async {
    final response = await _dio.get(
      '${ApiConstants.songDetails}/$id',
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseSingleSong, data);
  }

  Future<List<Song>> getSongsByIds(List<String> ids) async {
    try {
      final response = await _dio.get(
        ApiConstants.songDetails,
        queryParameters: {'ids': ids.join(',')},
      );
      final data = response.data as Map<String, dynamic>;
      return compute(_parseSongsList, data['data'] ?? data);
    } catch (_) {
      return [];
    }
  }

  // ── Album Details ─────────────────────────────────────────────────────────────

  Future<Album?> getAlbumById(String id) async {
    final response = await _dio.get(
      ApiConstants.albumDetails,
      queryParameters: {'id': id},
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseSingleAlbum, data);
  }

  // ── Artist Details ────────────────────────────────────────────────────────────

  Future<Artist?> getArtistById(String id) async {
    final response = await _dio.get(
      '${ApiConstants.artistDetails}/$id',
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseSingleArtist, data);
  }

  Future<List<Song>> getArtistSongs(String id,
      {int page = 1, String sort = 'latest'}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.artistDetails}/$id/songs',
        queryParameters: {'page': page, 'sortBy': sort},
      );
      final data = response.data as Map<String, dynamic>;
      return compute(_parseSongsList, data['data']?['songs'] ?? data['data'] ?? data);
    } catch (_) {
      return [];
    }
  }

  // ── Playlist Details ──────────────────────────────────────────────────────────

  Future<Playlist?> getPlaylistById(String id) async {
    final response = await _dio.get(
      ApiConstants.playlistDetails,
      queryParameters: {'id': id},
    );
    final data = response.data as Map<String, dynamic>;
    return compute(_parseSinglePlaylist, data);
  }

  // ── Lyrics ────────────────────────────────────────────────────────────────────

  Future<Lyrics?> getLyricsById(String songId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.lyrics}/$songId',
      );
      final data = response.data as Map<String, dynamic>;
      final lyricsData = data['data'] as Map<String, dynamic>?;
      if (lyricsData == null) return null;

      final lyrics = lyricsData['lyrics'] as String?;
      final syncedLyrics = lyricsData['syncedLyrics'] as List?;

      List<LyricsLine>? lines;
      if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
        lines = syncedLyrics.map((l) {
          final map = l as Map<String, dynamic>;
          return LyricsLine(
            startTimeMs: map['time']?['total'] as int? ?? 0,
            text: map['words'] as String? ?? '',
          );
        }).toList();
      }

      return Lyrics(
        songId: songId,
        plainLyrics: lyrics,
        syncedLines: lines,
        hasSynced: lines != null && lines.isNotEmpty,
        copyright: lyricsData['copyright'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  // ── Trending / Featured Content ───────────────────────────────────────────────

  Future<List<Song>> getTrendingSongs({List<String> languages = const ['hindi']}) async {
    try {
      final List<Song> allSongs = [];
      for (final lang in languages) {
        final response = await _dio.get(
          ApiConstants.searchSongs,
          queryParameters: {
            'query': 'top songs ${lang.toLowerCase()} 2026',
            'limit': 10,
          },
        );
        final data = response.data as Map<String, dynamic>;
        final songs = await compute(_parseSongsList, data['data'] ?? data);
        allSongs.addAll(songs);
      }
      allSongs.shuffle();
      return allSongs;
    } catch (_) {
      return [];
    }
  }

  Future<List<Song>> getNewReleases({List<String> languages = const ['hindi']}) async {
    try {
      final List<Song> allSongs = [];
      for (final lang in languages) {
        final response = await _dio.get(
          ApiConstants.searchSongs,
          queryParameters: {
            'query': 'new ${lang.toLowerCase()} songs 2026',
            'limit': 10,
          },
        );
        final data = response.data as Map<String, dynamic>;
        final songs = await compute(_parseSongsList, data['data'] ?? data);
        allSongs.addAll(songs);
      }
      allSongs.shuffle();
      return allSongs;
    } catch (_) {
      return [];
    }
  }

  Future<List<Album>> getFeaturedAlbums() async {
    try {
      final response = await _dio.get(
        ApiConstants.searchAlbums,
        queryParameters: {
          'query': 'best albums 2025',
          'limit': 12,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return compute(_parseAlbumsList, data['data'] ?? data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Artist>> getFeaturedArtists() async {
    try {
      final response = await _dio.get(
        ApiConstants.searchArtists,
        queryParameters: {
          'query': 'popular artists india',
          'limit': 12,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return compute(_parseArtistsList, data['data'] ?? data);
    } catch (_) {
      return [];
    }
  }
}
