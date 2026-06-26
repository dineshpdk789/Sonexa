import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/features/home/presentation/home_provider.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/features/player/presentation/full_player_screen.dart';
import 'package:sonexa/shared/widgets/music_cards.dart';
import 'package:sonexa/shared/widgets/shimmer_loading.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Redesigned premium SliverAppBar
          SliverAppBar(
            expandedHeight: 160,
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 2,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.08),
                      cs.tertiary.withOpacity(0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sonexa_logo.png',
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SONEXA',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                          letterSpacing: -0.5,
                        ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 62),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded),
                tooltip: 'Listening History',
                onPressed: () {
                  context.push(RouteNames.library);
                },
              ),
              IconButton(
                icon: const Icon(Icons.insights_rounded),
                tooltip: 'Insights & Charts',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insights: Analysing your music profile...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.people_outline_rounded),
                tooltip: 'Listen Together',
                onPressed: () {
                  showListenTogetherDialog(context, ref);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: 'Settings',
                onPressed: () {
                  context.push(RouteNames.settings);
                },
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                height: 48,
                padding: const EdgeInsets.only(bottom: 8),
                alignment: Alignment.centerLeft,
                child: Consumer(
                  builder: (context, ref, _) {
                    final selectedCategory = ref.watch(selectedCategoryProvider);
                    final categories = ['Romance', 'Workout', 'Feel good', 'Party'];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categories.length,
                      itemBuilder: (context, idx) {
                        final cat = categories[idx];
                        final isSelected = selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              ref.read(selectedCategoryProvider.notifier).state =
                                  selected ? cat : '';
                            },
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected ? cs.onPrimary : cs.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedColor: cs.primary,
                            backgroundColor: cs.surfaceContainerHigh,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? cs.primary : cs.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          homeAsync.when(
            data: (data) {
              if (data.trending.isEmpty &&
                  data.newReleases.isEmpty &&
                  data.featuredAlbums.isEmpty &&
                  data.featuredArtists.isEmpty) {
                return SliverToBoxAdapter(
                  child: _ErrorSection(
                    message: 'No music content found. Please check your internet connection.',
                    onRetry: () => ref.refresh(homeProvider),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildListDelegate([
                  _HomeContent(data: data),
                ]),
              );
            },
            loading: () => const SliverToBoxAdapter(child: HomeShimmer()),
            error: (e, _) => SliverToBoxAdapter(
              child: _ErrorSection(
                message: e.toString(),
                onRetry: () => ref.refresh(homeProvider),
              ),
            ),
          ),
          // Bottom padding for mini player + nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final HomeData data;
  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(recentlyPlayedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (history.isNotEmpty) ...[
          _SectionHeader(title: '⏰ Recently Played'),
          _HorizontalSongList(songs: history, ref: ref),
          const SizedBox(height: 24),
        ],
        if (data.suggested.isNotEmpty) ...[
          _SectionHeader(title: '✨ Suggested for You'),
          _HorizontalSongList(songs: data.suggested, ref: ref),
          const SizedBox(height: 24),
        ],
        // Replace trending list with 3-column "Speed Dial" grid section
        if (data.trending.isNotEmpty) ...[
          _SectionHeader(title: '⚡ Speed Dial (Trending)'),
          _SpeedDialGrid(songs: data.trending.take(6).toList(), ref: ref),
          const SizedBox(height: 24),
        ],
        if (data.echoBrain.isNotEmpty) ...[
          _SectionHeader(title: '🧠 Echo Brain Recommends'),
          _HorizontalSongList(songs: data.echoBrain, ref: ref),
          const SizedBox(height: 24),
        ],
        if (data.moods.isNotEmpty) ...[
          _SectionHeader(title: '🎵 Mood & Genre Playlists'),
          _HorizontalPlaylistList(playlists: data.moods),
          const SizedBox(height: 24),
        ],
        if (data.newReleases.isNotEmpty) ...[
          _SectionHeader(title: '✨ New Releases'),
          _HorizontalSongList(songs: data.newReleases, ref: ref),
          const SizedBox(height: 24),
        ],
        if (data.charts.isNotEmpty) ...[
          _SectionHeader(title: '📊 Top Charts'),
          _HorizontalSongList(songs: data.charts, ref: ref),
          const SizedBox(height: 24),
        ],
        if (data.featuredAlbums.isNotEmpty) ...[
          _SectionHeader(title: '💿 Featured Albums'),
          _HorizontalAlbumList(albums: data.featuredAlbums),
          const SizedBox(height: 24),
        ],
        if (data.featuredArtists.isNotEmpty) ...[
          _SectionHeader(title: '🎤 Popular Artists'),
          _HorizontalArtistList(artists: data.featuredArtists),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See all'),
            ),
        ],
      ),
    );
  }
}

class _HorizontalSongList extends StatelessWidget {
  final List<Song> songs;
  final WidgetRef ref;

  const _HorizontalSongList({required this.songs, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => SongCard(
          song: songs[i],
          onTap: () => ref.read(playerProvider.notifier).playSong(
                songs[i],
                queue: songs,
              ),
        ),
      ),
    );
  }
}

class _HorizontalAlbumList extends StatelessWidget {
  final List<Album> albums;
  const _HorizontalAlbumList({required this.albums});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: albums.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final album = albums[i];
          return AlbumCard(
            id: album.id,
            title: album.title,
            artist: album.artistString,
            coverUrl: album.coverUrl,
            year: album.year,
          );
        },
      ),
    );
  }
}

class _SpeedDialGrid extends StatelessWidget {
  final List<Song> songs;
  final WidgetRef ref;
  const _SpeedDialGrid({required this.songs, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return GestureDetector(
          onTap: () {
            ref.read(playerProvider.notifier).playSong(song, queue: songs);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(song.coverUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    song.artistString,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HorizontalArtistList extends StatelessWidget {
  final List<Artist> artists;
  const _HorizontalArtistList({required this.artists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final artist = artists[i];
          return ArtistCard(
            id: artist.id,
            name: artist.name,
            imageUrl: artist.imageUrl,
          );
        },
      ),
    );
  }
}

class _HorizontalPlaylistList extends StatelessWidget {
  final List<Playlist> playlists;
  const _HorizontalPlaylistList({required this.playlists});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: playlists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final playlist = playlists[i];
          return PlaylistCard(
            id: playlist.id,
            title: playlist.name,
            description: playlist.description ?? '',
            coverUrl: playlist.coverUrl,
          );
        },
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorSection({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load content',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
