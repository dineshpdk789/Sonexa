import 'dart:io';

void main() {
  final file = File('e:/dinu/Learn/flutter-learn/Sonexa/lib/core/shared/providers/settings_provider.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"(final saved =[^;]+;)\s*\}"), r"\1\n    return saved;\n  }");
  
  file.writeAsStringSync(content);
  print('Fixed settings_provider.dart');
}
