import 'package:sonexa/data/datasources/jiosaavn_api_datasource.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/lyrics.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Abstract Interfaces ───────────────────────────────────────────────────────

abstract class SongRepository {
  Future<List<Song>> searchSongs(String query, {int page = 1});
  Future<Song?> getSong(String id);
  Future<List<Song>> getTrendingSongs();
  Future<List<Song>> getNewReleases();
}

abstract class AlbumRepository {
  Future<List<Album>> searchAlbums(String query, {int page = 1});
  Future<Album?> getAlbum(String id);
  Future<List<Album>> getFeaturedAlbums();
}

abstract class ArtistRepository {
  Future<List<Artist>> searchArtists(String query, {int page = 1});
  Future<Artist?> getArtist(String id);
  Future<List<Song>> getArtistSongs(String id, {int page = 1});
  Future<List<Artist>> getFeaturedArtists();
}

abstract class PlaylistRepository {
  Future<Playlist?> getPlaylist(String id);
  Future<List<Playlist>> searchPlaylists(String query, {int page = 1});
}

abstract class LyricsRepository {
  Future<Lyrics?> getLyrics(String songId);
}

// ── Implementations ───────────────────────────────────────────────────────────

class SongRepositoryImpl implements SongRepository {
  final JioSaavnApiDatasource _datasource;
  SongRepositoryImpl(this._datasource);

  @override
  Future<List<Song>> searchSongs(String query, {int page = 1}) async {
    try {
      return await _datasource.searchSongs(query, page: page);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Song?> getSong(String id) async {
    try {
      return await _datasource.getSongById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Song>> getTrendingSongs() async {
    return await _datasource.getTrendingSongs();
  }

  @override
  Future<List<Song>> getNewReleases() async {
    return await _datasource.getNewReleases();
  }
}

class AlbumRepositoryImpl implements AlbumRepository {
  final JioSaavnApiDatasource _datasource;
  AlbumRepositoryImpl(this._datasource);

  @override
  Future<List<Album>> searchAlbums(String query, {int page = 1}) async {
    try {
      return await _datasource.searchAlbums(query, page: page);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Album?> getAlbum(String id) async {
    try {
      return await _datasource.getAlbumById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Album>> getFeaturedAlbums() async {
    return await _datasource.getFeaturedAlbums();
  }
}

class ArtistRepositoryImpl implements ArtistRepository {
  final JioSaavnApiDatasource _datasource;
  ArtistRepositoryImpl(this._datasource);

  @override
  Future<List<Artist>> searchArtists(String query, {int page = 1}) async {
    try {
      return await _datasource.searchArtists(query, page: page);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Artist?> getArtist(String id) async {
    try {
      return await _datasource.getArtistById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Song>> getArtistSongs(String id, {int page = 1}) async {
    try {
      return await _datasource.getArtistSongs(id, page: page);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Artist>> getFeaturedArtists() async {
    return await _datasource.getFeaturedArtists();
  }
}

class PlaylistRepositoryImpl implements PlaylistRepository {
  final JioSaavnApiDatasource _datasource;
  PlaylistRepositoryImpl(this._datasource);

  @override
  Future<Playlist?> getPlaylist(String id) async {
    try {
      return await _datasource.getPlaylistById(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Playlist>> searchPlaylists(String query, {int page = 1}) async {
    try {
      return await _datasource.searchPlaylists(query, page: page);
    } catch (_) {
      return [];
    }
  }
}

class LyricsRepositoryImpl implements LyricsRepository {
  final JioSaavnApiDatasource _datasource;
  LyricsRepositoryImpl(this._datasource);

  @override
  Future<Lyrics?> getLyrics(String songId) async {
    try {
      return await _datasource.getLyricsById(songId);
    } catch (_) {
      return null;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final songRepositoryProvider = Provider<SongRepository>((ref) {
  return SongRepositoryImpl(ref.read(jiosaavnDataSourceProvider));
});

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepositoryImpl(ref.read(jiosaavnDataSourceProvider));
});

final artistRepositoryProvider = Provider<ArtistRepository>((ref) {
  return ArtistRepositoryImpl(ref.read(jiosaavnDataSourceProvider));
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(ref.read(jiosaavnDataSourceProvider));
});

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  return LyricsRepositoryImpl(ref.read(jiosaavnDataSourceProvider));
});
