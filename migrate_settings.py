import re

path = "e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/settings_provider.dart"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Pattern for Provider:
# final nameProvider =
#     StateNotifierProvider<NameNotifier, Type>((ref) {
#   final saved = <init_code>;
#   return NameNotifier(saved);
# });
#
# Pattern for Notifier:
# class NameNotifier extends StateNotifier<Type> {
#   NameNotifier(super.state);
#
#   ... methods ...
# }

# We can replace StateNotifierProvider with NotifierProvider
content = content.replace("StateNotifierProvider", "NotifierProvider")
content = content.replace("StateNotifier", "Notifier")

# We need to extract the initialization logic and move it to build()
def replacer(match):
    name = match.group(1)
    type_ = match.group(2)
    init_logic = match.group(3)
    
    provider_code = f"final {name.lower()[0] + name[1:].replace('Notifier', 'Provider')} =\n    NotifierProvider<{name}, {type_}>({name}.new);"
    
    notifier_code = f"class {name} extends Notifier<{type_}> {{\n  @override\n  {type_} build() {{\n    {init_logic.strip()}\n  }}"
    
    return provider_code + "\n\n" + notifier_code

pattern = r"final\s+\w+\s*=\s*NotifierProvider<(\w+),\s*([^>]+)>\(\(ref\)\s*\{\s*([\s\S]*?)return\s+\w+\([^)]+\);\s*\}\);\s*class\s+\1\s+extends\s+Notifier<\2>\s*\{\s*\1\(super\.state\);"

new_content = re.sub(pattern, replacer, content)

with open(path, "w", encoding="utf-8") as f:
    f.write(new_content)
print("Updated settings_provider.dart")
