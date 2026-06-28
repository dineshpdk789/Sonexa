import 'dart:io';

void main() {
  final dir = Directory('e:/dinu/Learn/flutter-learn/Sonexa/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final opacityPattern = RegExp(r'\.withOpacity\(([^)]+)\)');
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('.withOpacity(')) {
      content = content.replaceAllMapped(opacityPattern, (match) {
        return '.withValues(alpha: ${match.group(1)})';
      });
      file.writeAsStringSync(content);
      print('Fixed opacity in ${file.path}');
    }
  }
}
