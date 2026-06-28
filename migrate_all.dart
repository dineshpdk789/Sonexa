import 'dart:io';

void main() {
  final files = [
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/settings_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/theme_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/downloads/presentation/downloads_screen.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/library/presentation/library_screen.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/player/presentation/player_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/search/presentation/search_provider.dart"
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();

    // Generic replace
    content = content.replaceAll("StateNotifierProvider", "NotifierProvider");
    content = content.replaceAll("StateNotifier", "Notifier");

    // Pattern 1: settings_provider init extraction
    final pattern1 = RegExp(r"final\s+(\w+)\s*=\s*NotifierProvider<(\w+),\s*([^>]+)>\(\(ref\)\s*\{\s*([\s\S]*?)return\s+\w+\([^)]*\);\s*\}\);\s*class\s+\2\s+extends\s+Notifier<\3>\s*\{\s*\2\(super\.state\);");
    content = content.replaceAllMapped(pattern1, (match) {
      final providerName = match.group(1)!;
      final name = match.group(2)!;
      final type = match.group(3)!;
      final initLogic = match.group(4)!;
      
      return "final $providerName =\n    NotifierProvider<$name, $type>($name.new);\n\nclass $name extends Notifier<$type> {\n  @override\n  $type build() {\n    ${initLogic.trim()}\n  }";
    });

    // Pattern 2: Empty super constructor
    final pattern2 = RegExp(r"class\s+(\w+)\s+extends\s+Notifier<([^>]+)>\s*\{\s*\1\(\)\s*:\s*super\((.*?)\);");
    content = content.replaceAllMapped(pattern2, (match) {
      final name = match.group(1)!;
      final type = match.group(2)!;
      final init = match.group(3)!;
      return "class $name extends Notifier<$type> {\n  @override\n  $type build() => $init;";
    });

    // Pattern 3: Provider init for empty constructors
    final pattern3 = RegExp(r"final\s+(\w+)\s*=\s*NotifierProvider<(\w+),\s*([^>]+)>\(\s*\(ref\)\s*=>\s*\2\(\)\s*\);");
    content = content.replaceAllMapped(pattern3, (match) {
      final providerName = match.group(1)!;
      final name = match.group(2)!;
      final type = match.group(3)!;
      return "final $providerName = NotifierProvider<$name, $type>($name.new);";
    });

    file.writeAsStringSync(content);
    print("Migrated $path");
  }
}
