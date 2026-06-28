import 'dart:io';

void main() async {
  final dir = Directory('lib');
  
  // Move directories
  final dataDir = Directory('${dir.path}/data');
  if (dataDir.existsSync()) dataDir.renameSync('${dir.path}/core/data');
  
  final domainDir = Directory('${dir.path}/domain');
  if (domainDir.existsSync()) domainDir.renameSync('${dir.path}/core/domain');
  
  final sharedDir = Directory('${dir.path}/shared');
  if (sharedDir.existsSync()) sharedDir.renameSync('${dir.path}/core/shared');

  // Update imports in all .dart files
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    
    if (content.contains('package:sonexa/data/')) {
      content = content.replaceAll('package:sonexa/data/', 'package:sonexa/core/data/');
      changed = true;
    }
    if (content.contains('package:sonexa/domain/')) {
      content = content.replaceAll('package:sonexa/domain/', 'package:sonexa/core/domain/');
      changed = true;
    }
    if (content.contains('package:sonexa/shared/')) {
      content = content.replaceAll('package:sonexa/shared/', 'package:sonexa/core/shared/');
      changed = true;
    }
    
    if (changed) {
      file.writeAsStringSync(content);
    }
  }
}
