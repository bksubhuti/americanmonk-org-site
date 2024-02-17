import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart add_featured_image.dart <directory>');
    exit(1);
  }

  final directoryPath = arguments[0];
  final directory = Directory(directoryPath);

  if (!directory.existsSync()) {
    print('Error: Directory not found.');
    exit(1);
  }

  directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .forEach((file) {
    final lines = file.readAsLinesSync();
    final result = processFile(lines);

    if (result != null) {
      file.writeAsStringSync(result['content']);
      print('${file.path} updated: ${result['message']}');
    }
  });
}

Map<String, dynamic>? processFile(List<String> lines) {
  bool modified = false;
  String message = '';
  List<String> newLines = [];

  for (var line in lines) {
    // Correctly handle image and featured_image in the header
    if (line.startsWith('image:')) {
      String newPath = line.replaceFirst('assets/', '/');
      newLines.add(newPath);
      newLines.add('featured_image: ' + newPath.split('image: ').last);
      modified = true;
      message += 'Header image updated; ';
    } else {
      // Correctly update image paths in the content
      if (line.contains('![](assets/')) {
        line = line.replaceFirst('assets/', '/');
        modified = true;
      }
      newLines.add(line);
    }
  }

  // If modifications were made, return the updated content and a message
  if (modified) {
    return {
      'content': newLines.join('\n'),
      'message': message.isNotEmpty ? message : 'Content images updated.'
    };
  }

  return null;
}
