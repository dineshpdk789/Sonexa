# 🎵 Echo Music Next

A premium cross-platform Flutter music streaming app built from scratch with Clean Architecture, Material 3 design, and a rich set of features.

![Flutter](https://img.shields.io/badge/Flutter-3.41.0-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.11.0-blue?logo=dart)
![License](https://img.shields.io/badge/license-MIT-green)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20macOS%20%7C%20Linux-brightgreen)

## ✨ Features   ddd

### 🎵 Music Discovery
- **Home Screen** — Trending songs, New Releases, Featured Albums, Popular Artists
- **Search** — Real-time debounced search across songs, albums, artists with history
- **Library** — Liked songs, Downloads, History, Playlists

### 🎧 Playback
- **Full Player** — Beautiful full-screen player with blurred album art background
- **Canvas Animation** — Moving audio-reactive blob animation behind controls
- **Mini Player** — Persistent bottom bar with progress indicator
- **Queue Management** — Add to queue, reorder, shuffle, repeat modes
- **Background Playback** — Continues playing when app is minimized
- **Notification Controls** — Media controls in notification shade

### 📝 Lyrics
- **Synced Lyrics** — Auto-scrolling with current line highlighted
- **Plain Lyrics** — Full text lyrics view with toggle

### 📥 Downloads
- **Offline Mode** — Download songs for offline listening
- **Download Manager** — Progress tracking, pause/resume/cancel

### 🎨 Design
- **Material 3** — Latest Material Design with dynamic color
- **Three Themes** — Light, Dark, AMOLED Black
- **Shimmer Loading** — Beautiful skeleton loading states
- **Hero Animations** — Shared element transitions on album art
- **Glassmorphism** — Premium visual effects

## 🏗️ Architecture

```
lib/
├── core/
│   ├── config/        # App config
│   ├── constants/     # App + API constants
│   ├── theme/         # Material 3 theme (Light/Dark/AMOLED)
│   ├── utils/         # Debouncer, formatters
│   ├── services/      # AudioPlayerService
│   ├── network/       # Dio client with interceptors
│   ├── error/         # Exception hierarchy
│   ├── storage/       # Hive storage service
│   └── router/        # GoRouter navigation
├── features/
│   ├── home/          # Home screen + provider
│   ├── search/        # Search screen + provider
│   ├── player/        # Full player + state notifier
│   ├── library/       # Library tabs
│   ├── downloads/     # Downloads screen
│   ├── lyrics/        # Lyrics screen
│   └── settings/      # Settings screen
├── shared/
│   ├── widgets/       # SongCard, AlbumCard, ArtistCard, MiniPlayer, Shimmer
│   └── providers/     # ThemeProvider
├── domain/
│   ├── entities/      # Song, Album, Artist, Playlist, Lyrics
│   ├── repositories/  # Abstract interfaces
│   └── usecases/      # Business logic
└── data/
    ├── models/        # DTOs (SongDto, AlbumDto, ArtistDto, PlaylistDto)
    ├── repositories/  # Concrete implementations
    └── datasources/   # JioSaavn API datasource
```

## 🔧 Tech Stack

| Category | Library |
|----------|---------|
| **State Management** | `flutter_riverpod` |
| **Navigation** | `go_router` |
| **Networking** | `dio` (with retry/logging interceptors) |
| **Audio** | `just_audio` + `audio_service` |
| **Local Storage** | `hive_flutter` |
| **Images** | `cached_network_image` |
| **Animations** | Custom `Canvas` + `shimmer` + `lottie` |
| **UI** | Material 3 + Google Fonts (Outfit) |

## 🌐 API

Uses the **JioSaavn public API** (`https://saavn.dev/api`) as the primary music data source.

| Endpoint | Description |
|----------|-------------|
| `GET /search/songs` | Search songs |
| `GET /search/albums` | Search albums |
| `GET /search/artists` | Search artists |
| `GET /songs/:id` | Get song details |
| `GET /albums?id=` | Get album details |
| `GET /artists/:id` | Get artist details |
| `GET /playlists?id=` | Get playlist details |
| `GET /lyrics/:id` | Get song lyrics |

## 🚀 Getting Started

### Prerequisites
- Flutter 3.41.0+
- Dart 3.11.0+
- Android Studio / VS Code

### Run the App
```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release
```

## 📱 Permissions (Android)

- `INTERNET` — Stream music from API
- `READ_MEDIA_AUDIO` — Access local audio files
- `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` — Background playback
- `POST_NOTIFICATIONS` — Playback notification
- `WAKE_LOCK` — Keep screen on during playback

## ⚠️ Legal Notice

This app uses an unofficial JioSaavn API for educational purposes. All music content belongs to its respective rights holders. This app does not store or redistribute any copyrighted content.

## 🙏 Acknowledgments

- [saavn.dev](https://saavn.dev) — JioSaavn API
- [Echo Music](https://github.com/EchoMusicApp/Echo-Music) — UI inspiration
- Flutter community for amazing packages
