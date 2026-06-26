import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonexa/features/home/presentation/home_screen.dart';
import 'package:sonexa/features/search/presentation/search_screen.dart';
import 'package:sonexa/features/library/presentation/library_screen.dart';
import 'package:sonexa/features/settings/presentation/settings_screen.dart';
import 'package:sonexa/features/player/presentation/full_player_screen.dart';
import 'package:sonexa/features/lyrics/presentation/lyrics_screen.dart';
import 'package:sonexa/features/downloads/presentation/downloads_screen.dart';
import 'package:sonexa/shared/widgets/scaffold_with_nav.dart';

class RouteNames {
  static const home = '/';
  static const search = '/search';
  static const library = '/library';
  static const settings = '/settings';
  static const player = '/player';
  static const lyrics = '/lyrics';
  static const downloads = '/downloads';
}

final appRouter = GoRouter(
  initialLocation: RouteNames.home,
  routes: [
    // Shell route for bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNav(child: child);
      },
      routes: [
        GoRoute(
          path: RouteNames.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.search,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SearchScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.library,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LibraryScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    // Full player screen (modal)
    GoRoute(
      path: RouteNames.player,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const FullPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
      },
    ),
    // Lyrics screen
    GoRoute(
      path: RouteNames.lyrics,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const LyricsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    // Downloads screen
    GoRoute(
      path: RouteNames.downloads,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const DownloadsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);
