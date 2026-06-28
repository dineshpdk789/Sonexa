import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/domain/entities/song.dart';
import 'package:sonexa/core/shared/widgets/detail_sheets.dart';

class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool compact;

  const SongCard({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _compactCard(context);
    return _verticalCard(context);
  }

  Widget _buildSourceBadge(BuildContext context, String source) {
    Color badgeColor;
    String label = source;
    switch (source.toLowerCase()) {
      case 'spotify':
        badgeColor = const Color(0xFF1DB954);
        label = 'Spotify';
        break;
      case 'youtube music':
      case 'ytmusic':
      case 'youtube':
        badgeColor = const Color(0xFFFF0000);
        label = 'YT Music';
        break;
      case 'jiosaavn':
      case 'saavn':
      default:
        badgeColor = const Color(0xFF800080);
        label = 'JioSaavn';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        border:
            Border.all(color: badgeColor.withValues(alpha: 0.4), width: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // Vertical card (for horizontal lists on home)
  Widget _verticalCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: song.coverUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(140, cs),
                errorWidget: (_, __, ___) => _placeholder(140, cs),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildSourceBadge(context, song.source),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    song.artistString,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Compact list tile (for search results)
  Widget _compactCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: song.coverUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: (_, __) => _placeholder(52, cs),
          errorWidget: (_, __, ___) => _placeholder(52, cs),
        ),
      ),
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            _buildSourceBadge(context, song.source),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${song.artistString} • ${Formatters.formatDuration(song.durationSeconds)}',
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: onMoreTap,
        iconSize: 20,
      ),
    );
  }

  Widget _placeholder(double size, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size < 80 ? 8 : 14),
      ),
<<<<<<< HEAD:lib/shared/widgets/music_cards.dart
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(
          'assets/images/sonexa_logo.png',
          color: cs.onSurfaceVariant.withOpacity(0.3),
          colorBlendMode: BlendMode.srcIn,
        ),
=======
      child: Icon(
        Icons.music_note_rounded,
        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        size: size * 0.35,
>>>>>>> 8e6970c6074979b74fcf39fdb9a5b3f71c6f13ff:lib/core/shared/widgets/music_cards.dart
      ),
    );
  }
}

class AlbumCard extends ConsumerWidget {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String? year;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.year,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap ??
          () =>
              showAlbumDetailsSheet(context, ref, id, title, coverUrl, artist),
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'album-$id',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: coverUrl,
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 120,
                    height: 160,
                    color: cs.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Image.asset('assets/images/sonexa_logo.png'),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 120,
                    height: 160,
                    color: cs.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Image.asset('assets/images/sonexa_logo.png'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              year != null ? '$artist • $year' : artist,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistCard extends ConsumerWidget {
  final String id;
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;

  const ArtistCard({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap ??
          () => showArtistDetailsSheet(context, ref, id, name, imageUrl),
      child: SizedBox(
        width: 110,
        child: Column(
          children: [
            Hero(
              tag: 'artist-$id',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: cs.surfaceContainerHighest,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset('assets/images/sonexa_logo.png'),
                    ),
                    errorWidget: (_, __, ___) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset('assets/images/sonexa_logo.png'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistCard extends ConsumerWidget {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap ??
          () => showPlaylistDetailsSheet(
              context, ref, id, title, coverUrl, description),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: coverUrl,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 140,
                  height: 140,
                  color: cs.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Image.asset('assets/images/sonexa_logo.png'),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 140,
                  height: 140,
                  color: cs.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Image.asset('assets/images/sonexa_logo.png'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
