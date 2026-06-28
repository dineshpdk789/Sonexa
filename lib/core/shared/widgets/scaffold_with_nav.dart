import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/shared/widgets/mini_player.dart';
import 'package:sonexa/core/router/app_router.dart';

class ScaffoldWithNav extends ConsumerStatefulWidget {
  final Widget child;

  const ScaffoldWithNav({super.key, required this.child});

  @override
  ConsumerState<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends ConsumerState<ScaffoldWithNav> {
  double _left = 12.0;
  double _bottom = 84.0;
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    if (location.startsWith(RouteNames.search)) {
      selectedIndex = 1;
    } else if (location.startsWith(RouteNames.library)) {
      selectedIndex = 3;
    } else if (location.startsWith(RouteNames.settings)) {
      selectedIndex = 4;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final playerWidth = screenWidth - 24;

    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          // Floating Pill Navigation Bar
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: _FloatingNavBar(
              selectedIndex: selectedIndex,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go(RouteNames.home);
                    break;
                  case 1:
                    context.go(RouteNames.search);
                    break;
                  case 2:
                    _triggerVoiceSearch(context, ref);
                    break;
                  case 3:
                    context.go(RouteNames.library);
                    break;
                  case 4:
                    context.go(RouteNames.settings);
                    break;
                }
              },
            ),
          ),
          // Movable floating mini player
          Positioned(
            left: _left,
            bottom: _bottom,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _left += details.delta.dx;
                  _bottom -= details.delta.dy;

                  // Clamp to screen bounds
                  if (_left < 0) _left = 0;
                  if (_left > screenWidth - playerWidth) _left = screenWidth - playerWidth;
                  if (_bottom < 0) _bottom = 0;
                  if (_bottom > screenHeight - 100) _bottom = screenHeight - 100;
                });
              },
              child: SizedBox(
                width: playerWidth,
                child: const MiniPlayerWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerVoiceSearch(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Listening...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try saying "Romantic songs" or "Taylor Swift"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 36),
              // Animated Pulse Circle
              _VoicePulseWidget(),
              const SizedBox(height: 36),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _VoicePulseWidget extends StatefulWidget {
  @override
  State<_VoicePulseWidget> createState() => _VoicePulseWidgetState();
}

class _VoicePulseWidgetState extends State<_VoicePulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.15).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border:
              Border.all(color: cs.primary.withValues(alpha: 0.3), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 36,
          backgroundColor: cs.primary,
          child: const Icon(
            Icons.mic_rounded,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', cs),
          _buildNavItem(
              1, Icons.search_outlined, Icons.search_rounded, 'Search', cs),
          _buildMicItem(2, cs),
          _buildNavItem(3, Icons.library_music_outlined,
              Icons.library_music_rounded, 'Library', cs),
          _buildNavItem(4, Icons.more_horiz_rounded, Icons.more_horiz_rounded,
              'More', cs),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
    ColorScheme cs,
  ) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? cs.primary : Colors.white.withValues(alpha: 0.5);

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicItem(int index, ColorScheme cs) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.mic_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
