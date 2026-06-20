import 'dart:io';

const int maxFileLines = 400;
const int maxMainFileLines = 200;
const int maxBuildMethodLines = 100;

void main() {
  final Directory libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Expected to run from the Flutter app root. Missing lib/.');
    exitCode = 2;
    return;
  }

  final List<String> failures = <String>[];
  final List<File> dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File file) => file.path.endsWith('.dart'))
      .where((File file) => !file.path.endsWith('.g.dart'))
      .where((File file) => !file.path.endsWith('.freezed.dart'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  for (final File file in dartFiles) {
    final String relativePath = _relativePath(file.path);
    final List<String> lines = file.readAsLinesSync();
    final int fileLineLimit =
        relativePath == 'lib/main.dart' ? maxMainFileLines : maxFileLines;

    if (lines.length > fileLineLimit) {
      failures.add(
        '$relativePath has ${lines.length} lines '
        '(limit: $fileLineLimit).',
      );
    }

    failures.addAll(
      _findBuildMethodViolations(
        relativePath: relativePath,
        lines: lines,
      ),
    );
  }

  if (failures.isEmpty) {
    stdout.writeln('Structural lint passed.');
    return;
  }

  stderr.writeln('Structural lint failed:\n');
  for (final String failure in failures) {
    stderr.writeln('- $failure');
  }

  stderr.writeln(
    '\nThresholds: '
    'main.dart <= $maxMainFileLines lines, '
    'other files <= $maxFileLines lines, '
    'build() bodies <= $maxBuildMethodLines lines.',
  );
  exitCode = 1;
}

List<String> _findBuildMethodViolations({
  required String relativePath,
  required List<String> lines,
}) {
  final List<String> violations = <String>[];
  final RegExp buildPattern =
      RegExp(r'^\s*Widget\s+build\s*\(\s*BuildContext\s+\w+\s*\)\s*\{');

  for (int index = 0; index < lines.length; index += 1) {
    if (!buildPattern.hasMatch(lines[index])) {
      continue;
    }

    final int startLine = index + 1;
    final int? endLine = _findMethodEndLine(lines, index);
    if (endLine == null) {
      violations.add(
        '$relativePath:$startLine has a build() method that could not be parsed.',
      );
      continue;
    }

    final int methodLength = endLine - startLine + 1;
    if (methodLength > maxBuildMethodLines) {
      violations.add(
        '$relativePath:$startLine build() spans $methodLength lines '
        '(limit: $maxBuildMethodLines).',
      );
    }
  }

  return violations;
}

int? _findMethodEndLine(List<String> lines, int startIndex) {
  int braceDepth = 0;
  bool seenOpeningBrace = false;

  for (int lineIndex = startIndex; lineIndex < lines.length; lineIndex += 1) {
    final String line = lines[lineIndex];
    for (int charIndex = 0; charIndex < line.length; charIndex += 1) {
      final String char = line[charIndex];
      if (char == '{') {
        braceDepth += 1;
        seenOpeningBrace = true;
      } else if (char == '}') {
        braceDepth -= 1;
        if (seenOpeningBrace && braceDepth == 0) {
          return lineIndex + 1;
        }
      }
    }
  }

  return null;
}

String _relativePath(String path) {
  return path.replaceFirst(
      '${Directory.current.path}${Platform.pathSeparator}', '');
}
