import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/core/services/audio_player_service.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/features/home/presentation/home_provider.dart';
import 'package:sonexa/features/downloads/presentation/downloads_screen.dart';

class MockPlayerNotifier extends PlayerNotifier {
  MockPlayerNotifier() : super(AudioPlayerService.instance);

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
          playerProvider.overrideWith((ref) => MockPlayerNotifier()),
          homeProvider.overrideWith((ref) async => const HomeData(
                trending: [],
                newReleases: [],
                featuredAlbums: [],
                featuredArtists: [],
                charts: [],
                moods: [],
                echoBrain: [],
                suggested: [],
              )),
          activeTasksProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const SonexaApp(),
      ),
    );
    expect(find.byType(SonexaApp), findsOneWidget);
  });
}
