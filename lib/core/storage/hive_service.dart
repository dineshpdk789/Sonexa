import 'package:hive_flutter/hive_flutter.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/domain/entities/album.dart'; // contains Playlist

class HiveService {
  static late Box _settingsBox;
  static late Box<String> _searchHistoryBox;
  static late Box _favoritesBox;
  static late Box _historyBox;
  static late Box _playlistsBox;
  static late Box _downloadsBox;

  static Future<void> init([String? path]) async {
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    _searchHistoryBox =
        await Hive.openBox<String>(AppConstants.searchHistoryBoxName);
    _favoritesBox = await Hive.openBox('favorites_box');
    _historyBox = await Hive.openBox('history_box');
    _playlistsBox = await Hive.openBox('playlists_box');
    _downloadsBox = await Hive.openBox('downloads_box');
  }

  // ── Settings ─────────────────────────────────────────────────────────────────
  static T? getSetting<T>(String key) => _settingsBox.get(key) as T?;

  static Future<void> saveSetting<T>(String key, T value) =>
      _settingsBox.put(key, value);

  // ── Search History ────────────────────────────────────────────────────────────
  static List<String> getSearchHistory() =>
      _searchHistoryBox.values.toList().reversed.toList();

  static Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    // Remove duplicate if exists
    final key = _searchHistoryBox.keys.firstWhere(
      (k) => _searchHistoryBox.get(k) == query,
      orElse: () => null,
    );
    if (key != null) await _searchHistoryBox.delete(key);
    // Keep max 20 items
    if (_searchHistoryBox.length >= 20) {
      await _searchHistoryBox.deleteAt(0);
    }
    await _searchHistoryBox.add(query);
  }

  static Future<void> clearSearchHistory() => _searchHistoryBox.clear();

  static Future<void> removeSearchQuery(String query) async {
    final key = _searchHistoryBox.keys.firstWhere(
      (k) => _searchHistoryBox.get(k) == query,
      orElse: () => null,
    );
    if (key != null) await _searchHistoryBox.delete(key);
  }

  // ── Favorites (Liked Songs) ──────────────────────────────────────────────────
  static List<Song> getFavorites() {
    return _favoritesBox.values
        .map((e) => Song.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static bool isFavorite(String songId) {
    return _favoritesBox.containsKey(songId);
  }

  static Future<void> addFavorite(Song song) async {
    song.isFavorite = true;
    await _favoritesBox.put(song.id, song.toJson());
  }

  static Future<void> removeFavorite(String songId) async {
    await _favoritesBox.delete(songId);
  }

  // ── Play History ─────────────────────────────────────────────────────────────
  static List<Song> getHistory() {
    final list = _historyBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return Song.fromJson(map);
    }).toList();
    return list.reversed.toList();
  }

  static Future<void> addToHistory(Song song) async {
    if (_historyBox.length >= 50) {
      await _historyBox.deleteAt(0);
    }
    // Remove if already in history to move to top
    final keysToDelete = [];
    for (final key in _historyBox.keys) {
      final val = _historyBox.get(key);
      if (val != null) {
        final s = Map<String, dynamic>.from(val as Map);
        if (s['id'] == song.id) {
          keysToDelete.add(key);
        }
      }
    }
    for (final key in keysToDelete) {
      await _historyBox.delete(key);
    }
    await _historyBox.add(song.toJson());
  }

  static Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // ── Playlists ────────────────────────────────────────────────────────────────
  static List<Playlist> getPlaylists() {
    return _playlistsBox.values.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      final songsList = (map['songs'] as List? ?? [])
          .map((s) => Song.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList();
      return Playlist(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        coverUrl: map['coverUrl'] as String? ?? '',
        songs: songsList,
        songCount: songsList.length,
      );
    }).toList();
  }

  static Playlist? getPlaylist(String id) {
    final data = _playlistsBox.get(id);
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data as Map);
    final songsList = (map['songs'] as List? ?? [])
        .map((s) => Song.fromJson(Map<String, dynamic>.from(s as Map)))
        .toList();
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverUrl: map['coverUrl'] as String? ?? '',
      songs: songsList,
      songCount: songsList.length,
    );
  }

  static Future<void> createPlaylist(String name, {String? description, String? coverUrl}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl ?? '',
      'songs': [],
    };
    await _playlistsBox.put(id, playlist);
  }

  static Future<void> deletePlaylist(String playlistId) async {
    await _playlistsBox.delete(playlistId);
  }

  static Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final playlistData = _playlistsBox.get(playlistId);
    if (playlistData == null) return;
    final map = Map<String, dynamic>.from(playlistData as Map);
    final songsList = List<Map<String, dynamic>>.from(
      (map['songs'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map))
    );
    if (!songsList.any((s) => s['id'] == song.id)) {
      songsList.add(song.toJson());
      map['songs'] = songsList;
      if (map['coverUrl'] == null || (map['coverUrl'] as String).isEmpty) {
        map['coverUrl'] = song.coverUrl;
      }
      await _playlistsBox.put(playlistId, map);
    }
  }

  static Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlistData = _playlistsBox.get(playlistId);
    if (playlistData == null) return;
    final map = Map<String, dynamic>.from(playlistData as Map);
    final songsList = List<Map<String, dynamic>>.from(
      (map['songs'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map))
    );
    songsList.removeWhere((s) => s['id'] == songId);
    map['songs'] = songsList;
    if (songsList.isNotEmpty && (map['coverUrl'] == null || (map['coverUrl'] as String).isEmpty)) {
      map['coverUrl'] = songsList.first['coverUrl'];
    } else if (songsList.isEmpty) {
      map['coverUrl'] = '';
    }
    await _playlistsBox.put(playlistId, map);
  }

  static Future<void> reorderPlaylistSongs(String playlistId, int oldIndex, int newIndex) async {
    final playlistData = _playlistsBox.get(playlistId);
    if (playlistData == null) return;
    final map = Map<String, dynamic>.from(playlistData as Map);
    final songsList = List<Map<String, dynamic>>.from(
      (map['songs'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map))
    );
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = songsList.removeAt(oldIndex);
    songsList.insert(newIndex, item);
    map['songs'] = songsList;
    await _playlistsBox.put(playlistId, map);
  }

  // ── Offline Downloads ────────────────────────────────────────────────────────
  static List<Song> getDownloads() {
    return _downloadsBox.values
        .map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          if (map['status'] == 'completed') {
            final songMap = Map<String, dynamic>.from(map['song'] as Map);
            final song = Song.fromJson(songMap);
            song.localFilePath = map['filePath'] as String?;
            return song;
          }
          return null;
        })
        .whereType<Song>()
        .toList();
  }

  static Map<String, dynamic>? getDownloadTask(String songId) {
    final data = _downloadsBox.get(songId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  static List<Map<String, dynamic>> getAllDownloadTasks() {
    return _downloadsBox.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> addDownloadTask(Song song) async {
    final task = {
      'id': song.id,
      'song': song.toJson(),
      'filePath': '',
      'status': 'queued',
      'progress': 0.0,
    };
    await _downloadsBox.put(song.id, task);
  }

  static Future<void> updateDownloadTask(
      String songId, {required String status, required double progress, String? filePath}) async {
    final taskData = _downloadsBox.get(songId);
    if (taskData == null) return;
    final map = Map<String, dynamic>.from(taskData as Map);
    map['status'] = status;
    map['progress'] = progress;
    if (filePath != null) {
      map['filePath'] = filePath;
    }
    await _downloadsBox.put(songId, map);
  }

  static Future<void> removeDownloadTask(String songId) async {
    await _downloadsBox.delete(songId);
  }
}
