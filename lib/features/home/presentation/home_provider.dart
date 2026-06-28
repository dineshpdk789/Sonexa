import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/core/shared/providers/settings_provider.dart';

class HomeData {
  final List<Song> heroItems;
  final List<Song> speedDialItems;
  final List<Song> communityHits;
  final List<Artist> keepListeningArtists;
  final List<Song> keepListeningSongs;
  final List<String> moodAndGenres;
  final List<Playlist> themedPlaylists;
  final List<Song> musicVideos;
  final List<Song> charts;
  final Artist similarToArtistBase;
  final List<dynamic> similarToArtistItems; // mix of Artist and Song/Playlist
  final List<Song> newReleases;
  final List<Song> indiaHits;
  final List<Song> throwback90s;
  final List<Playlist> summerPlaylists;
  final List<Playlist> trendingCommunity;
  final List<Song> livePerformances;

  const HomeData({
    required this.heroItems,
    required this.speedDialItems,
    required this.communityHits,
    required this.keepListeningArtists,
    required this.keepListeningSongs,
    required this.moodAndGenres,
    required this.themedPlaylists,
    required this.musicVideos,
    required this.charts,
    required this.similarToArtistBase,
    required this.similarToArtistItems,
    required this.newReleases,
    required this.indiaHits,
    required this.throwback90s,
    required this.summerPlaylists,
    required this.trendingCommunity,
    required this.livePerformances,
  });
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(SelectedCategoryNotifier.new);
class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => '';
}

// Fallback mock data
List<Song> _getMockSongs() {
  return [
    Song(
      id: '1',
      title: 'Blinding Lights',
      album: 'After Hours',
      year: '2020',
      artists: ['The Weeknd'],
      coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
      durationSeconds: 200,
      language: 'English',
    ),
    Song(
      id: '2',
      title: 'Shape of You',
      album: 'Divide',
      year: '2017',
      artists: ['Ed Sheeran'],
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
      durationSeconds: 234,
      language: 'English',
    ),
    Song(
      id: '3',
      title: 'Levitating',
      album: 'Future Nostalgia',
      year: '2020',
      artists: ['Dua Lipa'],
      coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      durationSeconds: 203,
      language: 'English',
    ),
    Song(
      id: '4',
      title: 'Peaches',
      album: 'Justice',
      year: '2021',
      artists: ['Justin Bieber', 'Daniel Caesar', 'Giveon'],
      coverUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
      durationSeconds: 198,
      language: 'English',
    ),
    Song(
      id: '5',
      title: 'Stay',
      album: 'F*ck Love 3',
      year: '2021',
      artists: ['Kid LAROI', 'Justin Bieber'],
      coverUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400',
      durationSeconds: 141,
      language: 'English',
    ),
    Song(
      id: '6',
      title: 'Bad Habits',
      album: '=',
      year: '2021',
      artists: ['Ed Sheeran'],
      coverUrl: 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400',
      durationSeconds: 231,
      language: 'English',
    ),
    Song(
      id: '7',
      title: 'Save Your Tears',
      album: 'After Hours',
      year: '2020',
      artists: ['The Weeknd'],
      coverUrl: 'https://images.unsplash.com/photo-1504898770365-14faca6a7320?w=400',
      durationSeconds: 215,
      language: 'English',
    ),
    Song(
      id: '8',
      title: 'Montero',
      album: 'Montero',
      year: '2021',
      artists: ['Lil Nas X'],
      coverUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400',
      durationSeconds: 137,
      language: 'English',
    ),
    Song(
      id: '9',
      title: 'Kiss Me More',
      album: 'Planet Her',
      year: '2021',
      artists: ['Doja Cat', 'SZA'],
      coverUrl: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400',
      durationSeconds: 208,
      language: 'English',
    ),
    Song(
      id: '10',
      title: 'Good 4 U',
      album: 'SOUR',
      year: '2021',
      artists: ['Olivia Rodrigo'],
      coverUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400',
      durationSeconds: 178,
      language: 'English',
    ),
  ];
}

List<Artist> _getMockArtists() {
  return [
    Artist(
      id: 'a1',
      name: 'Arijit Singh',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    ),
    Artist(
      id: 'a2',
      name: 'Ed Sheeran',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
    ),
    Artist(
      id: 'a3',
      name: 'The Weeknd',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    ),
    Artist(
      id: 'a4',
      name: 'Dua Lipa',
      imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    ),
  ];
}

List<Playlist> _getMockPlaylists() {
  return [
    const Playlist(
      id: 'p1',
      name: 'Bollywood Sangeet',
      description: 'Tanishk Bagchi, Badshah, Neha Kakkar',
      coverUrl: 'https://images.unsplash.com/photo-1543807535-eceef0bc6599?w=400',
    ),
    const Playlist(
      id: 'p2',
      name: 'Bollywood Fire',
      description: 'Amitabh Bhattacharya',
      coverUrl: 'https://images.unsplash.com/photo-1605806616949-1e87b487bc2a?w=400',
    ),
    const Playlist(
      id: 'p3',
      name: 'Haryanvi Hits',
      description: 'Masoom Sharma',
      coverUrl: 'https://images.unsplash.com/photo-1596495578065-6e0763fa1178?w=400',
    ),
    const Playlist(
      id: 's1',
      name: '00s Chill: Tamil',
      description: 'Yuvan Shankar Raja',
      coverUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=400',
    ),
    const Playlist(
      id: 's2',
      name: 'Kannada Melodies',
      description: 'Sonu Nigam',
      coverUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400',
    ),
    const Playlist(
      id: 'c1',
      name: 'Hit songs',
      description: '199',
      coverUrl: 'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=400',
    ),
  ];
}

final homeProvider = FutureProvider<HomeData>((ref) async {
  final songRepo = ref.read(songRepositoryProvider);
  final albumRepo = ref.read(albumRepositoryProvider);
  final artistRepo = ref.read(artistRepositoryProvider);

  final languages = ref.watch(songLanguageProvider);

  List<Song> trending = [];
  List<Song> newReleases = [];
  List<Artist> featuredArtists = [];
  
  try {
    // 1. Fetch standard base data with timeout
    final results = await Future.wait([
      songRepo.getTrendingSongs(languages: languages).timeout(const Duration(seconds: 5)),
      songRepo.getNewReleases(languages: languages).timeout(const Duration(seconds: 5)),
      albumRepo.getFeaturedAlbums().timeout(const Duration(seconds: 5)),
      artistRepo.getFeaturedArtists().timeout(const Duration(seconds: 5)),
    ]).catchError((e) => [_getMockSongs(), _getMockSongs(), [], _getMockArtists()]);

    trending = results[0] as List<Song>;
    newReleases = results[1] as List<Song>;
    featuredArtists = results[3] as List<Artist>;
  } catch (e) {
    // Fallback to mock data if API fails
    trending = _getMockSongs();
    newReleases = _getMockSongs();
    featuredArtists = _getMockArtists();
  }

  // If API returns empty, use mock data
  if (trending.isEmpty) trending = _getMockSongs();
  if (newReleases.isEmpty) newReleases = _getMockSongs();
  if (featuredArtists.isEmpty) featuredArtists = _getMockArtists();

  // 2. Smart Recommendation Engine based on History
  final history = HiveService.getHistory();
  List<Song> recommendedSongs = [];
  String topArtistName = 'Arijit Singh'; // Default fallback

  if (history.isNotEmpty) {
    // Find the most frequently played artist in history
    final artistCount = <String, int>{};
    for (var song in history) {
      if (song.primaryArtist != 'Unknown') {
        artistCount[song.primaryArtist] = (artistCount[song.primaryArtist] ?? 0) + 1;
      }
    }
    
    if (artistCount.isNotEmpty) {
      var sortedArtists = artistCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topArtistName = sortedArtists.first.key;
    }
    
    try {
      // Fetch personalized recommendations
      recommendedSongs = await songRepo.searchSongs(topArtistName).timeout(const Duration(seconds: 5));
    } catch (e) {
      recommendedSongs = [];
    }
  }

  // Fallback to trending/new if recommendations are empty
  if (recommendedSongs.isEmpty) {
    recommendedSongs = [...trending, ...newReleases].toSet().toList();
    recommendedSongs.shuffle();
  }

  // Mix standard fallback songs for filling UI slots
  final allSongs = [...trending, ...newReleases].toSet().toList();
  allSongs.shuffle();
  
  // Safe helper
  Artist getSafeArtist(int idx) {
    if (featuredArtists.isEmpty) return _getMockArtists()[0];
    return featuredArtists[idx % featuredArtists.length];
  }

  final mockPlaylists = _getMockPlaylists();

  return HomeData(
    heroItems: recommendedSongs.take(3).toList(),
    speedDialItems: recommendedSongs.skip(3).take(6).toList(),
    communityHits: allSongs.skip(9).take(4).toList(),
    keepListeningArtists: featuredArtists.take(2).toList(),
    keepListeningSongs: recommendedSongs.skip(9).take(4).toList(),
    moodAndGenres: [
      'Chill', 'Focus', 'Commute', 'Gaming', 'Energize', 'Party', 'Feel good', 'Romance'
    ],
    themedPlaylists: mockPlaylists.take(3).toList(),
    musicVideos: allSongs.skip(17).take(3).toList(),
    charts: trending.take(4).toList(),
    similarToArtistBase: Artist(id: '0', name: topArtistName, imageUrl: getSafeArtist(0).imageUrl),
    similarToArtistItems: [
      ...recommendedSongs.skip(13).take(2).toList(),
      getSafeArtist(1),
    ],
    newReleases: newReleases.take(4).toList(),
    indiaHits: trending.skip(4).take(4).toList(),
    throwback90s: allSongs.skip(22).take(3).toList(),
    summerPlaylists: mockPlaylists.skip(3).take(2).toList(),
    trendingCommunity: mockPlaylists.skip(5).take(1).toList(),
    livePerformances: allSongs.skip(25).take(3).toList(),
  );
});

final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  return HiveService.getHistory();
});
