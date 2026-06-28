import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/core/services/audio_player_service.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/features/home/presentation/home_provider.dart';
import 'package:sonexa/features/downloads/presentation/downloads_screen.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/domain/entities/album.dart';

class MockPlayerNotifier extends PlayerNotifier {
  MockPlayerNotifier();

  @override
  void listenToStreams() {
    // Override to do nothing, preventing background player stream listeners or timers
  }
}

void main() {
  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    await HiveService.init(tempDir.path);
  });

  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProvider.overrideWith(MockPlayerNotifier.new),
          homeProvider.overrideWith((ref) async => const HomeData(
                heroItems: [],
                speedDialItems: [],
                communityHits: [],
                keepListeningArtists: [],
                keepListeningSongs: [],
                moodAndGenres: [],
                themedPlaylists: [],
                musicVideos: [],
                charts: [],
                similarToArtistBase: Artist(id: '0', name: 'Unknown', imageUrl: ''),
                similarToArtistItems: [],
                newReleases: [],
                indiaHits: [],
                throwback90s: [],
                summerPlaylists: [],
                trendingCommunity: [],
                livePerformances: [],
              )),
          activeTasksProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const SonexaApp(),
      ),
    );
    expect(find.byType(SonexaApp), findsOneWidget);
  });
}
