import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sonexa/domain/entities/album.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/features/player/presentation/player_provider.dart';

// --- Helper widget for cached images ---
Widget _buildCachedImage(String url, {double? width, double? height, BoxFit fit = BoxFit.cover, BorderRadius? borderRadius}) {
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.music_note, color: Colors.white54, size: 24),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54, size: 24),
        ),
      ),
    ),
  );
}

// --- Hero Carousel Card ---
class HeroCarouselCard extends ConsumerWidget {
  final Song song;
  const HeroCarouselCard({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(playerProvider.notifier).playSong(song);
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Stack(
          children: [
            SizedBox.expand(
              child: _buildCachedImage(
                song.coverUrl,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                ),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artistString,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Speed Dial Section ---
class SpeedDialGrid extends ConsumerWidget {
  final List<Song> items;
  const SpeedDialGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.more_horiz_rounded, size: 32, color: Colors.white54),
            ),
          );
        }
        
        final song = items[index];
        return GestureDetector(
          onTap: () {
            ref.read(playerProvider.notifier).playSong(song, queue: items);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                SizedBox.expand(
                  child: _buildCachedImage(
                    song.coverUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Community Section ---
class CommunityCard extends ConsumerWidget {
  final List<Song> hits;
  const CommunityCard({super.key, required this.hits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (hits.isEmpty) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _buildCachedImage(
                hits[0].coverUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2026 Hits',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '925 views',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...hits.skip(1).take(3).map((song) => GestureDetector(
            onTap: () {
              ref.read(playerProvider.notifier).playSong(song, queue: hits);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildCachedImage(
                    song.coverUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(playerProvider.notifier).playSong(hits.first, queue: hits);
                },
                child: _buildCircleBtn(Icons.play_arrow_rounded, true)
              ),
              const SizedBox(width: 16),
              _buildCircleBtn(Icons.sensors_rounded, false),
              const SizedBox(width: 16),
              _buildCircleBtn(Icons.add_rounded, false),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCircleBtn(IconData icon, bool primary) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primary ? const Color(0xFF657843) : Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: primary ? Colors.white : Colors.white70),
    );
  }
}

// --- Keep Listening Section ---
class KeepListeningSection extends ConsumerWidget {
  final List<Artist> artists;
  final List<Song> songs;
  const KeepListeningSection({super.key, required this.artists, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(artists[i].imageUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: const Icon(Icons.person, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  Text(artists[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final song = songs[i];
              return GestureDetector(
                onTap: () {
                  ref.read(playerProvider.notifier).playSong(song, queue: songs);
                },
                child: SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildCachedImage(
                            song.coverUrl,
                            width: 140,
                            height: 100,
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Mood and Genres Grid ---
class MoodAndGenresGrid extends StatelessWidget {
  final List<String> items;
  const MoodAndGenresGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            items[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        );
      },
    );
  }
}

// --- Music Videos Vertical List ---
class MusicVideosList extends ConsumerWidget {
  final List<Song> items;
  const MusicVideosList({super.key, required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final song = items[i];
        return GestureDetector(
          onTap: () {
            ref.read(playerProvider.notifier).playSong(song, queue: items);
          },
          child: Row(
            children: [
              _buildCachedImage(
                song.coverUrl,
                width: 60,
                height: 40,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(song.artistString, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert_rounded, color: Colors.white54),
            ],
          ),
        );
      },
    );
  }
}

// --- Generic Horizontal Card List (Charts / Releases / Hits) ---
class HorizontalCardList extends ConsumerWidget {
  final List<dynamic> items; // Can be Song or Playlist
  final bool isSquare;
  const HorizontalCardList({super.key, required this.items, this.isSquare = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final item = items[i];
          final String title = item is Song ? item.title : (item is Playlist ? item.name : '');
          final String subtitle = item is Song ? item.artistString : (item is Playlist ? item.description ?? '' : '');
          final String img = item is Song ? item.coverUrl : (item is Playlist ? item.coverUrl : '');

          return GestureDetector(
            onTap: () {
              if (item is Song) {
                // Play song
                final songList = items.whereType<Song>().toList();
                ref.read(playerProvider.notifier).playSong(item, queue: songList);
              }
              // For Playlist, we'd navigate to playlist screen, but since it's not fully implemented 
              // we can just leave it as is or do a placeholder action.
            },
            child: SizedBox(
              width: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCachedImage(
                    img,
                    width: 130,
                    height: isSquare ? 130 : 100,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
