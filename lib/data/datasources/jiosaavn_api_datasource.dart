import 'package:dio/dio.dart';
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

class JioSaavnApiDatasource {
  final Dio _dio;

  JioSaavnApiDatasource(this._dio);

  // ── Search Helpers ────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _parseResultsList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) {
      return rawData.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
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
        return results.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      }
      if (results is Map) {
        final innerResults = results['results'];
        if (innerResults is List) {
          return innerResults.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    }
    return [];
  }

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
    final results = _parseResultsList(data['data'] ?? data);
    return results
        .map((e) => SongDto.fromJson(e).toEntity())
        .toList();
  }

  Future<List<Album>> searchAlbums(String query, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.searchAlbums,
      queryParameters: {'query': query, 'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    final results = _parseResultsList(data['data'] ?? data);
    return results
        .map((e) => AlbumDto.fromJson(e).toEntity())
        .toList();
  }

  Future<List<Artist>> searchArtists(String query, {int page = 1}) async {
    final response = await _dio.get(
      ApiConstants.searchArtists,
      queryParameters: {'query': query, 'page': page},
    );
    final data = response.data as Map<String, dynamic>;
    final results = _parseResultsList(data['data'] ?? data);
    return results
        .map((e) => ArtistDto.fromJson(e).toEntity())
        .toList();
  }

  Future<List<Playlist>> searchPlaylists(String query, {int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPlaylists,
        queryParameters: {'query': query, 'page': page},
      );
      final data = response.data as Map<String, dynamic>;
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => PlaylistDto.fromJson(e).toEntity())
          .toList();
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
    final songData = data['data'] as Map<String, dynamic>?;
    if (songData == null) return null;
    return SongDto.fromJson(songData).toEntity();
  }

  Future<List<Song>> getSongsByIds(List<String> ids) async {
    try {
      final response = await _dio.get(
        ApiConstants.songDetails,
        queryParameters: {'ids': ids.join(',')},
      );
      final data = response.data as Map<String, dynamic>;
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => SongDto.fromJson(e).toEntity())
          .toList();
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
    final albumData = data['data'] as Map<String, dynamic>?;
    if (albumData == null) return null;
    return AlbumDto.fromJson(albumData).toEntity();
  }

  // ── Artist Details ────────────────────────────────────────────────────────────

  Future<Artist?> getArtistById(String id) async {
    final response = await _dio.get(
      '${ApiConstants.artistDetails}/$id',
    );
    final data = response.data as Map<String, dynamic>;
    final artistData = data['data'] as Map<String, dynamic>?;
    if (artistData == null) return null;
    return ArtistDto.fromJson(artistData).toEntity();
  }

  Future<List<Song>> getArtistSongs(String id,
      {int page = 1, String sort = 'latest'}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.artistDetails}/$id/songs',
        queryParameters: {'page': page, 'sortBy': sort},
      );
      final data = response.data as Map<String, dynamic>;
      final results = _parseResultsList(data['data']?['songs'] ?? data['data'] ?? data);
      return results
          .map((e) => SongDto.fromJson(e).toEntity())
          .toList();
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
    final playlistData = data['data'] as Map<String, dynamic>?;
    if (playlistData == null) return null;
    return PlaylistDto.fromJson(playlistData).toEntity();
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

  Future<List<Song>> getTrendingSongs({String language = 'hindi'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchSongs,
        queryParameters: {
          'query': 'top songs $language 2024',
          'limit': 20,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => SongDto.fromJson(e).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Song>> getNewReleases() async {
    try {
      final response = await _dio.get(
        ApiConstants.searchSongs,
        queryParameters: {
          'query': 'new hindi songs 2025',
          'limit': 20,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => SongDto.fromJson(e).toEntity())
          .toList();
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
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => AlbumDto.fromJson(e).toEntity())
          .toList();
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
      final results = _parseResultsList(data['data'] ?? data);
      return results
          .map((e) => ArtistDto.fromJson(e).toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }
}
