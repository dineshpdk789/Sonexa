import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          borderRadius:
              borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class SongCardShimmer extends StatelessWidget {
  const SongCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(
          width: 140,
          height: 140,
          borderRadius: BorderRadius.circular(14),
        ),
        const SizedBox(height: 8),
        ShimmerLoading(width: 120, height: 14, borderRadius: BorderRadius.circular(4)),
        const SizedBox(height: 6),
        ShimmerLoading(width: 80, height: 10, borderRadius: BorderRadius.circular(4)),
      ],
    );
  }
}

class SongListShimmer extends StatelessWidget {
  final int itemCount;
  const SongListShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const _SongListItemShimmer(),
    );
  }
}

class _SongListItemShimmer extends StatelessWidget {
  const _SongListItemShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ShimmerLoading(
              width: 52,
              height: 52,
              borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                    width: double.infinity,
                    height: 14,
                    borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 6),
                ShimmerLoading(
                    width: 140,
                    height: 10,
                    borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 180, height: 24, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SongCardShimmer(),
            ),
          ),
          const SizedBox(height: 24),
          ShimmerLoading(width: 140, height: 24, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => const SongCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }
}
