import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/core/storage/hive_service.dart';

class HomeData {
  final List<Song> trending;
  final List<Song> newReleases;
  final List<Album> featuredAlbums;
  final List<Artist> featuredArtists;
  final List<Song> charts;
  final List<Playlist> moods;
  final List<Song> echoBrain;
  final List<Song> suggested;

  const HomeData({
    required this.trending,
    required this.newReleases,
    required this.featuredAlbums,
    required this.featuredArtists,
    required this.charts,
    required this.moods,
    required this.echoBrain,
    required this.suggested,
  });
}

final selectedCategoryProvider = StateProvider<String>((ref) => '');

final homeProvider = FutureProvider<HomeData>((ref) async {
  final songRepo = ref.read(songRepositoryProvider);
  final albumRepo = ref.read(albumRepositoryProvider);
  final artistRepo = ref.read(artistRepositoryProvider);
  final category = ref.watch(selectedCategoryProvider);

  final results = await Future.wait([
    songRepo.getTrendingSongs(),
    songRepo.getNewReleases(),
    albumRepo.getFeaturedAlbums(),
    artistRepo.getFeaturedArtists(),
  ]);

  var trending = results[0] as List<Song>;
  var newReleases = results[1] as List<Song>;
  final featuredAlbums = results[2] as List<Album>;
  final featuredArtists = results[3] as List<Artist>;

  if (category.isNotEmpty) {
    try {
      final categorySongs = await songRepo.searchSongs(category);
      if (categorySongs.isNotEmpty) {
        trending = categorySongs.take(8).toList();
        newReleases = categorySongs.skip(8).take(8).toList();
      }
    } catch (_) {}
  }

  final charts = trending.take(8).toList();

  final moods = [
    Playlist(
      id: 'mood_chill',
      name: 'Lo-Fi Chillout ☕',
      description: 'Relax and unwind with soft beats.',
      coverUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400',
    ),
    Playlist(
      id: 'mood_workout',
      name: 'Gym Motivation ⚡',
      description: 'High energy beats for your workout.',
      coverUrl: 'https://images.unsplash.com/photo-1605296867304-46d5465a25f1?w=400',
    ),
    Playlist(
      id: 'mood_focus',
      name: 'Deep Focus 🧠',
      description: 'Ambient sounds to supercharge focus.',
      coverUrl: 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=400',
    ),
    Playlist(
      id: 'mood_sleep',
      name: 'Peaceful Sleep 🌙',
      description: 'Drift away with soothing melodies.',
      coverUrl: 'https://images.unsplash.com/photo-1511295742364-92767fc4a09a?w=400',
    ),
  ];

  final echoBrain = [...newReleases, ...trending].toList()..shuffle();

  // History-aware song suggestions logic
  List<Song> suggested = [];
  final history = HiveService.getHistory();
  if (history.isNotEmpty) {
    final lastPlayed = history.first;
    try {
      // 1. Suggest by primary artist
      final artistResults = await songRepo.searchSongs(lastPlayed.primaryArtist);
      suggested = artistResults.where((s) => s.id != lastPlayed.id).toList();
    } catch (_) {}

    // 2. Suggest by language if not enough results
    if (suggested.length < 5 && lastPlayed.language != null && lastPlayed.language!.isNotEmpty) {
      try {
        final langResults = await songRepo.searchSongs(lastPlayed.language!);
        for (final s in langResults) {
          if (s.id != lastPlayed.id && !suggested.any((element) => element.id == s.id)) {
            suggested.add(s);
          }
        }
      } catch (_) {}
    }
  }

  // Fallback to trending/releases if history is empty or suggestions are not found
  if (suggested.isEmpty) {
    suggested = [...trending, ...newReleases].take(8).toList()..shuffle();
  } else {
    suggested = suggested.take(8).toList();
  }

  return HomeData(
    trending: trending,
    newReleases: newReleases,
    featuredAlbums: featuredAlbums,
    featuredArtists: featuredArtists,
    charts: charts,
    moods: moods,
    echoBrain: echoBrain.take(6).toList(),
    suggested: suggested,
  );
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  return HiveService.getHistory();
});
