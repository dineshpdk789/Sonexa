import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sonexa/core/storage/isar_service.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

class DownloadService {
  final Dio _dio = Dio();
  final Set<String> _activeDownloads = {};

  bool isDownloading(String songId) => _activeDownloads.contains(songId);

  Future<void> downloadSong(
    Song song, {
    Function(double)? onProgress,
    Function(String)? onComplete,
    Function(String)? onError,
  }) async {
    final songId = song.id;
    if (_activeDownloads.contains(songId)) return;

    final url = song.bestDownloadUrl;
    if (url.isEmpty) {
      onError?.call('No streamable URL available for this song.');
      return;
    }

    _activeDownloads.add(songId);
    await HiveService.addDownloadTask(song);

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${docDir.path}/echo_music_downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      String ext = 'mp3';
      if (url.contains('.mp4') || url.endsWith('.mp4')) {
        ext = 'mp4';
      } else if (url.contains('.m4a') || url.endsWith('.m4a')) {
        ext = 'm4a';
      }

      final filePath = '${downloadsDir.path}/${songId}_320.$ext';

      await HiveService.updateDownloadTask(songId,
          status: 'downloading', progress: 0.0);

      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total).clamp(0.0, 1.0);
            onProgress?.call(progress);
            HiveService.updateDownloadTask(songId,
                status: 'downloading', progress: progress);
          }
        },
      );

      _activeDownloads.remove(songId);
      await HiveService.updateDownloadTask(
        songId,
        status: 'completed',
        progress: 1.0,
        filePath: filePath,
      );
      song.localFilePath = filePath;
      await IsarService.saveSong(song);
      onComplete?.call(filePath);
    } catch (e) {
      _activeDownloads.remove(songId);
      await HiveService.updateDownloadTask(songId,
          status: 'failed', progress: 0.0);
      onError?.call(e.toString());
    }
  }

  Future<void> cancelDownload(String songId) async {
    _activeDownloads.remove(songId);
    await HiveService.removeDownloadTask(songId);
  }
}
