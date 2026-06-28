import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonexa/data/models/local/song_schema.dart';
import 'package:sonexa/domain/entities/song.dart';

class IsarService {
  static late Isar _isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [SongSchemaSchema],
      directory: dir.path,
    );
  }

  // ── Songs ──────────────────────────────────────────────────────────────────

  static Future<void> saveSong(Song song) async {
    final schema = SongSchema.fromEntity(song);
    await _isar.writeTxn(() async {
      await _isar.songSchemas.put(schema);
    });
  }
  
  static Future<void> saveSongs(List<Song> songs) async {
    final schemas = songs.map((e) => SongSchema.fromEntity(e)).toList();
    await _isar.writeTxn(() async {
      await _isar.songSchemas.putAll(schemas);
    });
  }

  static Future<Song?> getSong(String id) async {
    final isarId = fastHash(id);
    final schema = await _isar.songSchemas.get(isarId);
    return schema?.toEntity();
  }

  static Future<List<Song>> getAllSongs() async {
    final schemas = await _isar.songSchemas.where().findAll();
    return schemas.map((e) => e.toEntity()).toList();
  }
}
