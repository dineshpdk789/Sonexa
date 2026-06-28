import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/core/router/app_router.dart';
import 'package:sonexa/features/home/presentation/home_provider.dart';
import 'package:sonexa/features/home/presentation/widgets/home_components.dart';
import 'package:sonexa/core/shared/widgets/shimmer_loading.dart';
import 'package:sonexa/features/search/presentation/search_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
<<<<<<< HEAD
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(homeProvider.future);
        },
        child: CustomScrollView(
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
=======
      backgroundColor: const Color(0xFF121212), // Deep dark theme as in screenshot
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            elevation: 0,
            title: const Text(
              'Sonexa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white70),
                onPressed: () => context.push(RouteNames.library),
              ),
              IconButton(
                icon: const Icon(Icons.cast_connected_rounded, color: Colors.white70),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined, color: Colors.white70),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: () => context.push(RouteNames.settings),
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
                    final categories = ['Relax', 'Romance', 'Feel good', 'Party'];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              ref.read(selectedCategoryProvider.notifier).state = selected ? cat : '';
                              if (selected) {
                                ref.read(searchNotifierProvider.notifier).search(cat);
                                context.push(RouteNames.search);
                              }
                            },
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            selectedColor: Colors.white,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.transparent),
                            ),
>>>>>>> 8e6970c6074979b74fcf39fdb9a5b3f71c6f13ff
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
<<<<<<< HEAD
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
=======
              ),
            ),
          ),
          homeAsync.when(
            data: (data) {
              return SliverList(
                delegate: SliverChildListDelegate([
                  _HomeContent(data: data),
                ]),
              );
            },
            loading: () => const SliverToBoxAdapter(child: HomeShimmer()),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(e.toString(), style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          // Bottom padding for mini player + nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 180)),
        ],
>>>>>>> 8e6970c6074979b74fcf39fdb9a5b3f71c6f13ff
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeData data;
  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        if (data.echoBrain.isNotEmpty) ...[
          _SectionHeader(title: '🧠 Echo Brain Recommends'),
          _HorizontalSongList(songs: data.echoBrain, ref: ref),
          const SizedBox(height: 24),
        ],
        if (history.isNotEmpty) ...[
          _SectionHeader(title: '⏰ Recently Played'),
          _HorizontalSongList(songs: history, ref: ref),
=======
        // Hero Carousel
        if (data.heroItems.isNotEmpty)
          SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: data.heroItems.length,
              itemBuilder: (context, i) => HeroCarouselCard(song: data.heroItems[i]),
            ),
          ),
        const SizedBox(height: 24),

        // Speed Dial -> Your Usuals
        if (data.speedDialItems.isNotEmpty) ...[
          const _SectionTitle('Your usuals'),
          SpeedDialGrid(items: data.speedDialItems),
>>>>>>> 8e6970c6074979b74fcf39fdb9a5b3f71c6f13ff
          const SizedBox(height: 24),
        ],

        // From the community
        if (data.communityHits.isNotEmpty) ...[
          const _SectionTitle('From your community'),
          CommunityCard(hits: data.communityHits),
          const SizedBox(height: 24),
        ],

        // Keep listening -> Popular artist
        if (data.keepListeningArtists.isNotEmpty && data.keepListeningSongs.isNotEmpty) ...[
          const _SectionTitle('Popular artist'),
          KeepListeningSection(artists: data.keepListeningArtists, songs: data.keepListeningSongs),
          const SizedBox(height: 24),
        ],
<<<<<<< HEAD
        if (data.moods.isNotEmpty) ...[
          _SectionHeader(title: '🎵 Mood & Genre Playlists'),
          _HorizontalPlaylistList(playlists: data.moods),
          const SizedBox(height: 24),
        ],
        if (data.newReleases.isNotEmpty) ...[
          _SectionHeader(title: '✨ New Releases'),
          _HorizontalSongList(songs: data.newReleases, ref: ref),
          const SizedBox(height: 24),
=======

        // Mood and Genres -> Made for your mode
        if (data.moodAndGenres.isNotEmpty) ...[
          const _SectionTitle('Made for your mode', showTrailing: true),
          MoodAndGenresGrid(items: data.moodAndGenres),
          const SizedBox(height: 32),
>>>>>>> 8e6970c6074979b74fcf39fdb9a5b3f71c6f13ff
        ],

        // Charts -> Hot hits language wise
        if (data.charts.isNotEmpty) ...[
          const _SectionTitle('Latest hits language wise', showTrailing: true),
          HorizontalCardList(items: data.charts, isSquare: true),
          const SizedBox(height: 24),
        ],

        // New Releases -> Latest language wise
        if (data.newReleases.isNotEmpty) ...[
          const _SectionTitle('Latest songs language wise', showTrailing: true),
          HorizontalCardList(items: data.newReleases, isSquare: true),
          const SizedBox(height: 24),
        ],
        // Similar to Artist
        if (data.similarToArtistItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: data.similarToArtistBase.imageUrl.isNotEmpty
                      ? NetworkImage(data.similarToArtistBase.imageUrl)
                      : null,
                  child: data.similarToArtistBase.imageUrl.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Similar to', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(data.similarToArtistBase.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HorizontalCardList(items: data.similarToArtistItems, isSquare: false),
          const SizedBox(height: 24),
        ],

        // India's biggest hits
        if (data.indiaHits.isNotEmpty) ...[
          const _SuperTitle("MUSIC THAT'S HOT AND HAPPENING!"),
          const _SectionTitle("India's biggest hits"),
          HorizontalCardList(items: data.indiaHits, isSquare: false),
          const SizedBox(height: 24),
        ],
        
        // 90s Throwback Fun
        if (data.throwback90s.isNotEmpty) ...[
          const _SuperTitle("FROM THE WEIRD TO THE WONDERFUL. RELIVE THE MAGIC OF THE 90S"),
          const _SectionTitle("90s Throwback Fun"),
          HorizontalCardList(items: data.throwback90s, isSquare: false),
          const SizedBox(height: 24),
        ],

        // Summer Playlists
        if (data.summerPlaylists.isNotEmpty) ...[
          const _SuperTitle("PLAYLISTS FOR THE SEASON"),
          const _SectionTitle("Hello, Summer! ☀️🍉"),
          HorizontalCardList(items: data.summerPlaylists, isSquare: true),
          const SizedBox(height: 24),
        ],

        // Trending community playlists
        if (data.trendingCommunity.isNotEmpty) ...[
          const _SectionTitle('Trending community playlists'),
          HorizontalCardList(items: data.trendingCommunity, isSquare: true),
          const SizedBox(height: 24),
        ],

        // Live performances
        if (data.livePerformances.isNotEmpty) ...[
          const _SectionTitle('Live performances', actionText: 'Play all'),
          MusicVideosList(items: data.livePerformances),
          const SizedBox(height: 32),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool showTrailing;
  final String? actionText;

  const _SectionTitle(this.title, {this.showTrailing = false, this.actionText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (showTrailing)
            const Icon(Icons.arrow_forward_rounded, color: Colors.white70)
          else if (actionText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(actionText!, style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
        ],
      ),
    );
  }
}

class _SuperTitle extends StatelessWidget {
  final String text;
  const _SuperTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
