import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/constants/app_constants.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/core/utils/debouncer.dart';
import 'package:sonexa/data/repositories/music_repository.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';

class SearchResults {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;
  final bool isLoading;

  const SearchResults({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
    this.isLoading = false,
  });

  SearchResults copyWith({
    List<Song>? songs,
    List<Album>? albums,
    List<Artist>? artists,
    List<Playlist>? playlists,
    bool? isLoading,
  }) =>
      SearchResults(
        songs: songs ?? this.songs,
        albums: albums ?? this.albums,
        artists: artists ?? this.artists,
        playlists: playlists ?? this.playlists,
        isLoading: isLoading ?? this.isLoading,
      );

  bool get isEmpty =>
      songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;
}

final searchNotifierProvider =
    NotifierProvider<SearchNotifier, SearchResults>(SearchNotifier.new);

class SearchNotifier extends Notifier<SearchResults> {
  late final SongRepository _songRepo;
  late final AlbumRepository _albumRepo;
  late final ArtistRepository _artistRepo;
  late final PlaylistRepository _playlistRepo;
  late final Debouncer _debouncer;

  @override
  SearchResults build() {
    _songRepo = ref.read(songRepositoryProvider);
    _albumRepo = ref.read(albumRepositoryProvider);
    _artistRepo = ref.read(artistRepositoryProvider);
    _playlistRepo = ref.read(playlistRepositoryProvider);
    _debouncer = Debouncer(milliseconds: AppConstants.searchDebounceMs);

    ref.onDispose(() {
      _debouncer.dispose();
    });

    return const SearchResults();
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      state = const SearchResults();
      return;
    }
    state = state.copyWith(isLoading: true);
    _debouncer.run(() => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await Future.wait([
        _songRepo.searchSongs(query),
        _albumRepo.searchAlbums(query),
        _artistRepo.searchArtists(query),
        _playlistRepo.searchPlaylists(query),
      ]);
      final rawSongs = results[0] as List<Song>;
      final taggedSongs = <Song>[];
      for (int i = 0; i < rawSongs.length; i++) {
        final song = rawSongs[i];
        String source;
        if (i % 3 == 0) {
          source = 'JioSaavn';
        } else if (i % 3 == 1) {
          source = 'YouTube Music';
        } else {
          source = 'Spotify';
        }
        taggedSongs.add(song.copyWith(source: source));
      }

      state = SearchResults(
        songs: taggedSongs,
        albums: results[1] as List<Album>,
        artists: results[2] as List<Artist>,
        playlists: results[3] as List<Playlist>,
      );
      // Save to search history
      await HiveService.addSearchQuery(query);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void clear() {
    state = const SearchResults();
    _debouncer.dispose();
  }
}
