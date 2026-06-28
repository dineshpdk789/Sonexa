import 'dart:io';

void main() {
  final dir = Directory('e:/dinu/Learn/flutter-learn/Sonexa/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  final imagePattern = RegExp(r'Image\.network\(([^,]+)(.*?)\)');
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('Image.network(')) {
      content = content.replaceAllMapped(imagePattern, (match) {
        return 'CachedNetworkImage(imageUrl: ${match.group(1)}${match.group(2)})';
      });
      
      if (!content.contains('package:cached_network_image/cached_network_image.dart')) {
        content = "import 'package:cached_network_image/cached_network_image.dart';\n" + content;
      }
      
      file.writeAsStringSync(content);
      print('Fixed Image.network in ${file.path}');
    }
  }
}
