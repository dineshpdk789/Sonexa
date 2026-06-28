import 'package:flutter_riverpod/flutter_riverpod.dart'; // Just checking valid syntax? Wait, this is a scratch script

import 'dart:io';

void main() {
  final libDir = Directory('lib');
  final files = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('showModalBottomSheet(') && !content.contains('useRootNavigator: true')) {
      content = content.replaceAll(
        'showModalBottomSheet(',
        'showModalBottomSheet(\n      useRootNavigator: true,'
      );
      file.writeAsStringSync(content);
      print('Fixed \${file.path}');
    }
  }
}
