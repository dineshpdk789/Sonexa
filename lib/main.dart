import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sonexa/app.dart';
import 'package:sonexa/core/services/audio_player_service.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/core/storage/isar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize background audio playback
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.sonexa.channel.audio',
      androidNotificationChannelName: 'SONEXA Playback',
      androidNotificationOngoing: true,
    );
  } catch (_) {}

  // Try to set system UI style
  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  } catch (_) {}

  // Initialize Hive storage
  await HiveService.init();

  // Initialize Isar storage
  await IsarService.init();

  // Initialize audio player
  await AudioPlayerService.instance.init();

  runApp(
    const ProviderScope(
      child: SonexaApp(),
    ),
  );
}
