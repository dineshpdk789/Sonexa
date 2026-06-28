# Executive Summary

This prompt guides an AI assistant to perform a **comprehensive audit and optimization** of the “Sonexa” Flutter music app (GitHub: `dineshpdk789/Sonexa`).  It covers all stages: cloning the repo, reproducing errors on each platform, static analysis, dependency checks, code refactoring, performance tuning, architecture improvements, platform-specific fixes, security enhancements, and testing.  We instruct the agent to produce detailed deliverables: tables of current vs. recommended dependency versions, a prioritized issue list (with effort/risk estimates), code diff examples for key fixes, a sample GitHub Actions CI/CD YAML, and a remediation report.  The prompt emphasizes **official best practices** and tools.  For example, we recommend enabling strict type-checks in `analysis_options.yaml`, using `ListView.builder` for long lists, caching network images (via `cached_network_image`/`flutter_cache_manager`), and integrating **just_audio + just_audio_background** for robust background audio.  We suggest refactoring to **Clean Architecture** (e.g. `lib/core/`, `lib/features/…/data/domain/presentation` structure) and using **Riverpod** for state and **GoRouter** for navigation (Flutter docs now recommend declarative routing packages like go_router over named routes).  Security best practices are cited: use HTTPS and certificate pinning, avoid hardcoding API keys (use env files or backend proxy), obfuscate release builds with `--obfuscate`, and store tokens with `flutter_secure_storage`.  We also direct the agent to add unit/widget/integration tests (using `integration_test`) and to automate checks (formatting, analysis, tests, builds) via scripts/CI.  The final answer should be a self-contained **“master prompt”** combining these instructions and requiring the agent to output the requested tables and code snippets, with references to authoritative sources throughout.

---

## 1. Environment Setup & Reproduction

- **Clone and build:** Instruct the agent to run: `git clone https://github.com/dineshpdk789/Sonexa.git` and open the project. Ensure **Flutter SDK** and platform tools are up-to-date (`flutter --version`, `flutter doctor`).  
- **Check Flutter channel:** Verify the project’s Flutter channel (stable recommended). Migrate to the latest stable if needed.
- **Run analyzer/tests:** Execute `flutter pub get`, then `flutter analyze` and capture *all errors and warnings*. Run `flutter test` to list failing tests. Build the app on all targets: **Android (APK/Bundle), iOS (simulator and Archive), Web (debug profile), Desktop (Windows/macOS/Linux)** using `flutter build <platform>`. Document any build errors or runtime crashes (e.g. missing assets, AndroidX migration issues, iOS code signing issues).  
- **Reproduce issues:** On each platform, run the app in debug/profile/release modes to reproduce UI glitches or performance bottlenecks (e.g. jank, excessive memory). Log console output and screenshot errors. This initial triage provides a baseline of issues to address.

## 2. Static Analysis and Linting

- **Analysis options:** Add an `analysis_options.yaml` at the repo root (with `pubspec.yaml`) to enforce strong static checks. For example, enable **strict-casts, strict-inference, strict-raw-types** to catch implicit `dynamic` usages. Include a recommended lint set: use the [`flutter_lints`](https://pub.dev/packages/flutter_lints) package (superset of Dart team’s lints) and/or Google’s [recommended lints]. For example:
  ```yaml
  include: package:flutter_lints/flutter.yaml
  analyzer:
    language:
      strict-casts: true
      strict-inference: true
      strict-raw-types: true
  linter:
    rules:
      # enable Flutter/Dart best practice rules, e.g.:
      - avoid_print
      - prefer_final_fields
      - unnecessary_null_in_if_null_operators
      - unused_import
      # ... (add more from flutter_lints or effective_dart)
  ```
  Use `dart fix --apply` where safe to automatically correct style issues (e.g. unused imports, deprecated APIs).
- **Formatting:** Ensure consistent code style with `dart format .` (or `flutter format .`). Add a pre-commit hook or CI script to enforce formatting.  
- **Custom analysis:** Disable any irrelevant rules (e.g. if auto-generated code triggers warnings). Use `// ignore:` pragmas sparingly, and only after confirming the risk.

## 3. Dependency Audit

- **Current vs. latest:** Run `flutter pub outdated` (or `dart pub outdated`) to list all dependencies and check for newer versions. Prepare a **table** (Markdown) with columns: *Package*, *Current Version*, *Latest Compatible Version* (and *Latest Published* if different). Example row:

  | Package        | Current     | Latest     | Notes                        |
  | -------------- | ----------- | ---------- | ---------------------------- |
  | flutter        | 3.x.x       | 3.y.z      | (Flutter SDK itself)         |
  | cupertino_icons| ^1.0.2      | ^1.0.5     | minor patch available        |
  | dio            | ^4.0.0      | ^5.0.0     | [pub.dev] migration needed   |
  | shared_preferences | ^2.0.5  | ^2.0.15    |                              |
  | ...            | ...         | ...        | ...                          |

  Use pub.dev’s Changelogs or documentation to note breaking changes (e.g. migrating Dio to null-safe, moving from `shared_preferences` to `shared_preferences_plus`, etc.).  
- **Null-safety:** Ensure all direct dependencies are **null-safe**. If any old packages remain, either remove/replace them or upgrade to null-safe versions. (Flutter 3+ and Dart 3.0+ assume null safety.) Use the Dart migration tool (`dart migrate`) if needed.  
- **Dependency vulnerabilities:** Check for known security issues (e.g. outdated `crypto`, `http`). Remove unused dependencies. For any native plugin (e.g. for ads or analytics), verify it’s AndroidX and null-safe.  
- **Migration steps:** For each outdated package, document the update path: e.g. update `dio` to latest v5 (may require code changes for its new JSON serialization), `audio_service` v0.x to v1.x (the API changed), etc. Note in the prompt that the agent should include *migration notes* and any code diffs needed.

## 4. Code Refactoring & Fixes

- **Dart idioms:** Fix common issues reported by analyzer: avoid `async`/`await` misuse (e.g. use `async` only when awaiting, remove unnecessary `async` if the function doesn’t use `await`). Add `await` where missing (e.g. on navigation or I/O). Fix type casts and null checks per linter. Use null-safe operators (`?`, `!`) properly.  
- **Legacy APIs:** Replace any deprecated Flutter APIs (deprecated widgets, APIs) with modern equivalents. E.g., replace any `FlatButton`/`RaisedButton` with `TextButton`/`ElevatedButton` (per Material 3), or `OutlinedButton`.  
- **State management:** If the code uses old `setState`, Provider or GetX, refactor to **Riverpod** (as recommended). For example, convert a `StatefulWidget` that fetches data into a `FutureProvider` or `StateNotifierProvider`. Provide a sample refactor: e.g., original
  ```dart
  class _HomePageState extends State<HomePage> {
    Future<List<Song>> songs;
    @override void initState() {
      super.initState();
      songs = SongRepository().fetchSongs();
    }
    @override Widget build(BuildContext context) {
      return FutureBuilder<List<Song>>(...);
    }
  }
  ```
  becomes (using Riverpod’s `AsyncNotifier`):
  ```dart
  final songListProvider = AsyncNotifierProvider<SongListNotifier, List<Song>>(() => SongListNotifier());
  class SongListNotifier extends AsyncNotifier<List<Song>> {
    @override Future<List<Song>> build() async {
      return await SongRepository().fetchSongs();
    }
  }
  ```
  in the widget: `ref.watch(songListProvider)`. (Such examples should be included as snippets in the prompt.)  
- **Widget performance:** Add `const` constructors to stateless widgets where possible to reduce rebuild cost. Use `RepaintBoundary` around expensive subtrees (e.g. canvas animations or heavy images) to limit repaint scope. Avoid redundant `setState`; use `Listenable`/`StreamBuilder` where appropriate.  
- **Large widget rebuilds:** Identify heavy `build` methods (e.g. complex list items). Extract and memoize sub-widgets. Avoid `MediaQuery.of(context)` inside frequently rebuilding widgets.  
- **Asynchronous code:** Ensure streams and controllers are properly closed/canceled (e.g. in `dispose`). Use `StreamProvider` or `StateNotifier` for continuous data.  
- **Navigation:** Refactor imperative navigation (e.g. `Navigator.pushNamed`) to use **GoRouter** with URL-based routes, enabling deep links and web support. For example, define routes in `GoRouter(routes: [...])` and use `context.go('/player')`.  
- **Error handling:** Add try/catch around network calls. Show user-friendly messages or retry options on errors. Validate nulls in JSON parsing.

## 5. UI & Theming

- **Material 3:** Migrate to Material 3 (Flutter’s latest design spec) via `useMaterial3: true` in `ThemeData`, and update colors/shapes accordingly.  
- **Responsive UI:** Ensure layouts adapt to different screen sizes/orientations. Replace any hard-coded sizes with `MediaQuery` or relative layouts. For desktop, ensure window resizing works.  
- **Accessibility:** Add semantic labels to images/icons. Verify sufficient contrast in Dark/Light themes.  
- **SVG and icons:** Use vector assets or `IconData` rather than large bitmaps. If dozens of icons are in code, use Flutter’s built-in `Icons` or a font-based approach to reduce app size.

## 6. Image & Media Caching

- **Network images:** Replace any plain `Image.network(...)` with `CachedNetworkImage` (uses `flutter_cache_manager`) to cache downloaded artwork and album covers. Example:
  ```dart
  CachedNetworkImage(
    imageUrl: song.artUrl,
    placeholder: (c,u) => CircularProgressIndicator(),
    errorWidget: (c,u,e) => Icon(Icons.error),
  )
  ```
  This avoids re-downloading on scroll and speeds up UI.  
- **Video/Canvas:** If album visuals use video or heavy canvas, ensure you stop/pause them on navigation to save CPU.  
- **Audio caching:** If streaming audio, consider pre-fetching or caching segments (depending on license). Use `flutter_cache_manager` to store MP3 files if offline playback is needed.
  
## 7. Performance Profiling & Optimization

- **DevTools:** Instruct the agent to use Flutter’s DevTools Performance page and **Performance Overlay** to identify jank. Record any frames >16ms.  
- **CPU vs GPU:** If jank appears on the UI graph (red bars), optimize Dart code (expensive loops, builders). If on the GPU graph, simplify painting: avoid excessive `saveLayer` or clip operations, and use `RepaintBoundary` to isolate animations.  
- **Frame budget:** Ensure animations (e.g. canvas effects, splash screens) complete under 16ms. For static content, pre-cache shaders or images.  
- **Lists:** Convert any `ListView` with many children to `ListView.builder` and use `itemExtent` or `prototypeItem` for fixed-height items (improves scroll performance).  
- **Concurrency:** Offload heavy computations (e.g. JSON parsing, image processing) to isolates if needed. Instruct agent to profile with `Timeline` or Observatory for memory leaks.  
- **Tree shaking:** Remove unused widget icons by using `Icons` instead of `ImageIcon`. Enable `--tree-shake-icons` in release builds to reduce APK size.  
- **Deferred Components (Android):** If the app is very large, consider splitting infrequently used features into dynamic feature modules (Android App Bundle).

## 8. Architecture & Project Structure

- **Clean Architecture:** Restructure the project into logical layers (as per Uncle Bob). For example:
  ```
  lib/
    core/          # utils, constants, theme, API services, error types
    features/
      home/        # home screen feature (data, domain, presentation)
      search/
      album/
      artist/
      playlist/
      player/
      settings/
      ...
    main.dart
  ```
  In each feature, use subfolders: `data/models`, `data/datasources`, `data/repositories`; `domain/entities`, `domain/repositories`, `domain/usecases`; and `presentation/widgets`, `presentation/pages`, `presentation/controllers` (or providers).  
- **Dependency Injection:** Use Riverpod for DI: provide repositories and use cases via `Provider`. Avoid singletons; pass dependencies via constructors/providers.  
- **Navigation:** Put route definitions (with GoRouter) in a central file (e.g. `router.dart`). Use nested navigation if needed (bottom tab navigation + per-tab stack).  
- **Testing strategy:** Create test folders mirroring this structure: `test/features/...`, `test/core/...`. Unit-test pure domain logic, widget-test UI components (e.g. feed, search bar), and integration-test flows (login, playback). Use mocking for network via `mockito` or `http_mock_adapter`.  
- **CI/CD pipeline:** Add a GitHub Actions workflow YAML that:
  - Checks out code
  - Sets up Flutter (latest stable) on runner (use `subosito/flutter-action`)
  - Runs `flutter pub get`, `flutter analyze`, `flutter test --coverage`
  - Builds for Android (`flutter build apk`) and iOS (`flutter build ios --no-codesign`)
  - Optionally builds Web and Desktop
  - Reports lint/test results. 
  Include matrix for multiple OSes. (E.g. run on ubuntu-latest, macos-latest).  
  *Example snippet:*  
  ```yaml
  name: Flutter CI
  on: [push, pull_request]
  jobs:
    build:
      runs-on: ubuntu-latest
      strategy:
        matrix:
          platform: [linux, macos]  # android and iOS builds
      steps:
        - uses: actions/checkout@v3
        - uses: subosito/flutter-action@v2
          with: {channel: 'stable'}
        - run: flutter pub get
        - run: flutter analyze
        - run: flutter test --coverage
        - run: flutter build apk --release
        - name: Upload coverage report
          uses: actions/upload-artifact@v3
          with:
            name: coverage-report
            path: coverage/lcov.info
  ```
  (A full workflow YAML should be output by the AI agent as requested.)

## 9. Platform-Specific Configurations

- **Android:** Ensure **AndroidX** compatibility (update any old support library references). Set `minSdkVersion` to at least 21 or higher for newer plugins. Add required permissions (e.g. `<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>` for audio). Configure a proper Android `notification_channel` (ID/name) for playback notifications (matching what `just_audio_background` expects). In `AndroidManifest.xml`, add the AudioService activity, service, and receiver as per `just_audio_background` setup. Target the latest compile SDK (currently 33+).  
- **iOS:** Update iOS deployment target (e.g. 13.0+) in `Podfile`. Enable background modes for audio (in Xcode Capabilities or `Info.plist` add `UIBackgroundModes = audio`). Ensure CocoaPods is up-to-date and run `pod install`. Handle iOS-specific APIs (e.g. requesting microphone or photo library permissions if used).  
- **Desktop:** If targeting desktop (Windows/macOS/Linux), ensure embedding uses latest Flutter. For Windows, enable high-DPI support. For macOS, sign & notarize builds if distributing.  
- **Localization:** If any text is hard-coded, consider internationalization (use `intl` package, ARB files).  
- **Deep Links/Intents:** Set up Android intent filters or iOS URL schemes if needed for deep linking into the app.

## 10. Security and Privacy

- **Network Security:** Enforce HTTPS for all API calls (no plain HTTP). Consider implementing certificate pinning to trust only specific SSL certificates.  
- **API Keys:** **Do not** hard-code any secret keys in code or strings. Use a `.env` file or CI-secret injection (with `flutter_dotenv`) for API keys, or better yet, proxy sensitive API requests through a secure backend. For example, instruct: `final apiKey = dotenv.env['API_KEY'];`.  
- **Secure storage:** Store user tokens or credentials in `flutter_secure_storage` or platform keystore/keychain (not in plain `SharedPreferences`). Clear sensitive data on logout.  
- **Obfuscation:** For release builds, enable Dart obfuscation to deter reverse engineering:  
  ```
  flutter build apk --release --obfuscate --split-debug-info=/<dir>
  ```  
  This makes decompiled code harder to read. Note it doesn’t fully prevent reverse-engineering, but is a recommended practice.  
- **Least privileges:** Only request needed Android permissions. For example, if using a file download, only request WRITE_EXTERNAL_STORAGE on Android 10-, and use scoped storage APIs otherwise.  
- **Input validation:** If the app sends user input (e.g. search queries), ensure it’s sanitized server-side to prevent injection.

## 11. Testing and Quality Assurance

- **Unit tests:** Write unit tests for all non-UI logic: data models, use cases, repository methods (use fake or in-memory data sources).  
- **Widget tests:** For key UI widgets (e.g. player controls, search bar, list items), write widget tests to verify they render correctly given various states (empty, loading, error).  
- **Integration tests:** Using Flutter’s [`integration_test`](https://docs.flutter.dev/cookbook/testing/integration/introduction) package (or a tool like [Patrol](https://pub.dev/packages/patrol)), create end-to-end tests. For example, test flows like “search for a song, play it, verify background controls”. Automation should run on a device emulator/simulator.  
- **Coverage:** Measure test coverage (e.g. via `flutter test --coverage`). Aim for high coverage on critical logic.  
- **CI test steps:** Add test execution to CI (as above). Fail the build on lint errors, analysis warnings (treat warnings as errors if possible), or test failures.

## 12. Deliverables and Reporting

- **Issue tracker:** Instruct the agent to compile all found problems into a **prioritized issue list** (Markdown table). Include columns: *Issue Description*, *Location/File*, *Severity (High/Med/Low)*, *Effort Estimate (S/M/L)*, *Risk (Impact of fix)*. For example:

  | Issue                               | File(s)             | Severity | Effort | Risk  |
  | ------------------------------------|-------------------- | -------- | ------ | ----- |
  | Null-dereference risk (missing ?)  | `player.dart:123`   | High     | S      | Medium|
  | Unused import, lint warning        | `home_page.dart`    | Low      | S      | Low   |
  | Outdated `dio` (requires v5)      | `pubspec.yaml`      | High     | M      | High  |
  | No Android Foreground permission   | `AndroidManifest.xml`| High     | S      | Medium|
  | ...                                | ...                 | ...      | ...    | ...   |

  The agent should mark which issues are *showstoppers* vs *nice-to-have*, and categorize by impact (e.g. crashes = high, style fixes = low). 

- **Dependency table:** As above, a table of dependencies *current vs recommended* (with version numbers and maybe notes linking to pub.dev for details).  
- **Code patches/snippets:** Provide code diffs or snippets for typical fixes:
  - Example `analysis_options.yaml` (with lints and strict modes).
  - Sample `pubspec.yaml` updates (e.g. bumping versions, adding `flutter_lints`).
  - Refactoring a widget to Riverpod (shown above).
  - Setting up Dio with interceptors (e.g. attaching auth token) and example code for exponential backoff on retries.
  - Integrating `just_audio` with `AudioService`/`just_audio_background` (initialization code in `main()`, setting up media items).
- **CI workflow:** A complete GitHub Actions YAML workflow as a code block, covering at least the Android+web path (and iOS if on macOS runner).  

- **Remediation report:** Instruct the agent to conclude with a **detailed remediation report** or changelog, summarizing all applied fixes, with references where relevant. For example: “Fixed #123 (nullable return type) by adding `?`. Upgraded `dio` to 5.0.0 and replaced deprecated `BaseOptions` fields (see [dio docs]). Added `flutter_lints` per Dart style guide…”.

## 13. Commands and Automation

Include commands/scripts to automate routine fixes:  
- **Formatting:** `flutter format .`  
- **Analysis:** `flutter analyze` (fail CI on warnings), or `dart analyze .`  
- **Linting:** `flutter pub run flutter_lints` or simply rely on `analyze` + strict settings.  
- **Code fixes:** `dart fix --apply` (for allowed fixes).  
- **Dependency upgrade:** `flutter pub upgrade --major-versions` (after updating `pubspec.yaml`).  
- **Build:** `flutter build apk --release`, `flutter build ios --no-codesign`, `flutter build web`, etc.  
- **Tests:** `flutter test`, `flutter test integration_test` (if configured).  

## References

Throughout, use authoritative sources to justify recommendations.  For example, include references to the official Dart/Flutter docs and pub.dev pages as given above (e.g. static analysis rules, list performance, image caching, background audio, architecture, navigation, security best practices, testing frameworks, and dependency management). These citations should appear in the prompt to guide the AI agent’s decisions. 

**Output Requirements:** The AI’s answer should be structured (e.g. Markdown) and include:
- An **executive summary** of findings (this section).
- Step-by-step **audit plan** (as detailed above).
- **Tables** for dependencies and issues.
- **Code blocks/snippets** for example fixes and CI config.
- A **remediation log** summarizing all changes.
All advice must be concrete and actionable, citing official Flutter/Dart resources where appropriate. 

