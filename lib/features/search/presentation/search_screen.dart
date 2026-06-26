import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/storage/hive_service.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';
import 'package:sonexa/features/search/presentation/search_provider.dart';
import 'package:sonexa/shared/widgets/music_cards.dart';
import 'package:sonexa/shared/widgets/shimmer_loading.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() {
      final hasText = _controller.text.isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
      ref.read(searchNotifierProvider.notifier).search(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchNotifierProvider);
    final searchHistory = HiveService.getSearchHistory();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _hasText
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            ref.read(searchNotifierProvider.notifier).clear();
                          },
                        )
                      : const Icon(Icons.mic_rounded),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (q) {
                  if (q.isNotEmpty) {
                    HiveService.addSearchQuery(q);
                  }
                },
              ),
            ),
            // Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _hasText
                    ? _SearchResultsView(results: searchResults)
                    : _SearchHistoryView(
                        history: searchHistory,
                        onTap: (q) {
                          _controller.text = q;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: q.length),
                          );
                        },
                        onDelete: (q) {
                          HiveService.removeSearchQuery(q);
                          setState(() {});
                        },
                        onClear: () {
                          HiveService.clearSearchHistory();
                          setState(() {});
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results View ──────────────────────────────────────────────────────────────

class _SearchResultsView extends ConsumerWidget {
  final SearchResults results;
  const _SearchResultsView({required this.results});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (results.isLoading) {
      return const SongListShimmer();
    }

    if (results.isEmpty && !results.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Songs (${results.songs.length})'),
              Tab(text: 'Albums (${results.albums.length})'),
              Tab(text: 'Artists (${results.artists.length})'),
              Tab(text: 'Playlists (${results.playlists.length})'),
            ],
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Songs tab
                ListView.builder(
                  itemCount: results.songs.length,
                  padding: const EdgeInsets.only(bottom: 160),
                  itemBuilder: (_, i) => SongCard(
                    song: results.songs[i],
                    compact: true,
                    onTap: () => ref.read(playerProvider.notifier).playSong(
                          results.songs[i],
                          queue: results.songs,
                        ),
                  ),
                ),
                // Albums tab
                GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: results.albums.length,
                  itemBuilder: (_, i) {
                    final album = results.albums[i];
                    return AlbumCard(
                      id: album.id,
                      title: album.title,
                      artist: album.artistString,
                      coverUrl: album.coverUrl,
                      year: album.year,
                    );
                  },
                ),
                // Artists tab
                GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: results.artists.length,
                  itemBuilder: (_, i) {
                    final artist = results.artists[i];
                    return ArtistCard(
                      id: artist.id,
                      name: artist.name,
                      imageUrl: artist.imageUrl,
                    );
                  },
                ),
                // Playlists tab
                GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: results.playlists.length,
                  itemBuilder: (_, i) {
                    final playlist = results.playlists[i];
                    return PlaylistCard(
                      id: playlist.id,
                      title: playlist.name,
                      description: playlist.description ?? '',
                      coverUrl: playlist.coverUrl,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── History View ──────────────────────────────────────────────────────────────

class _SearchHistoryView extends StatelessWidget {
  final List<String> history;
  final void Function(String) onTap;
  final void Function(String) onDelete;
  final VoidCallback onClear;

  const _SearchHistoryView({
    required this.history,
    required this.onTap,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final trendingQueries = [
      'Top Hindi Songs 2025 ⚡',
      'Lo-Fi Study Mix ☕',
      'Workout Power Beats 💪',
      'Arijit Singh Hits 🎤',
      'Chill Vibes Synthwave 🌌',
      'EDM Party Mix 🕺',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Trending section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
          child: Text(
            '🔥 Trending Searches',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trendingQueries.map((q) {
              return ActionChip(
                label: Text(q, style: const TextStyle(fontSize: 12)),
                onPressed: () => onTap(q.substring(0, q.length - 2).trim()),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),

        // History section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (history.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Clear all'),
                ),
            ],
          ),
        ),
        Expanded(
          child: history.isEmpty
              ? const Center(
                  child: Text(
                    'No recent searches',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text(history[i]),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => onDelete(history[i]),
                    ),
                    onTap: () => onTap(history[i]),
                  ),
                ),
        ),
      ],
    );
  }
}
