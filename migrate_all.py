import re
import os

files_to_migrate = [
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/settings_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/theme_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/downloads/presentation/downloads_screen.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/library/presentation/library_screen.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/player/presentation/player_provider.dart",
    "e:/dinu/Learn/flutter-learn/Sonexa/lib/features/search/presentation/search_provider.dart"
]

def migrate_file(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # Generic replace
    content = content.replace("StateNotifierProvider", "NotifierProvider")
    content = content.replace("StateNotifier", "Notifier")

    # Simple provider init extraction (like in settings_provider)
    pattern1 = r"final\s+(\w+)\s*=\s*NotifierProvider<(\w+),\s*([^>]+)>\(\(ref\)\s*\{\s*([\s\S]*?)return\s+\w+\([^)]*\);\s*\}\);\s*class\s+\2\s+extends\s+Notifier<\3>\s*\{\s*\2\(super\.state\);"
    def replacer1(match):
        provider_name = match.group(1)
        name = match.group(2)
        type_ = match.group(3)
        init_logic = match.group(4)
        
        provider_code = f"final {provider_name} =\n    NotifierProvider<{name}, {type_}>({name}.new);"
        notifier_code = f"class {name} extends Notifier<{type_}> {{\n  @override\n  {type_} build() {{\n    {init_logic.strip()}\n  }}"
        return provider_code + "\n\n" + notifier_code

    content = re.sub(pattern1, replacer1, content)
    
    # Empty super constructor without state (e.g. MyNotifier() : super(init);)
    # class NameNotifier extends Notifier<Type> {
    #   NameNotifier() : super(init);
    pattern2 = r"class\s+(\w+)\s+extends\s+Notifier<([^>]+)>\s*\{\s*\1\(\)\s*:\s*super\((.*?)\);"
    def replacer2(match):
        name = match.group(1)
        type_ = match.group(2)
        init = match.group(3)
        return f"class {name} extends Notifier<{type_}> {{\n  @override\n  {type_} build() => {init};"
    
    content = re.sub(pattern2, replacer2, content)

    # Provider init for empty constructors
    # final nameProvider = NotifierProvider<NameNotifier, Type>((ref) => NameNotifier());
    pattern3 = r"final\s+(\w+)\s*=\s*NotifierProvider<(\w+),\s*([^>]+)>\(\s*\(ref\)\s*=>\s*\2\(\)\s*\);"
    def replacer3(match):
        provider_name = match.group(1)
        name = match.group(2)
        type_ = match.group(3)
        return f"final {provider_name} = NotifierProvider<{name}, {type_}>({name}.new);"
    
    content = re.sub(pattern3, replacer3, content)

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Migrated {os.path.basename(path)}")

for f in files_to_migrate:
    migrate_file(f)
