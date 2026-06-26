import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sonexa/app.dart';
import 'package:sonexa/core/services/audio_player_service.dart';
import 'package:sonexa/core/storage/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background audio playback
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.sonexa.channel.audio',
    androidNotificationChannelName: 'SONEXA Playback',
    androidNotificationOngoing: true,
  );

  // Request notification permissions for background playback on Android 13+
  try {
    await Permission.notification.request();
  } catch (_) {}

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Enable edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Hive storage
  await HiveService.init();

  // Initialize audio player
  await AudioPlayerService.instance.init();

  runApp(
    const ProviderScope(
      child: SonexaApp(),
    ),
  );
}
