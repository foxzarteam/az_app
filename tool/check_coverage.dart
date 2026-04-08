import 'dart:io';

class _CoverageStats {
  int total = 0;
  int hit = 0;

  double get percent => total == 0 ? 0 : (hit * 100.0) / total;
}

void main(List<String> args) {
  final coveragePath = args.isNotEmpty ? args.first : 'coverage/lcov.info';
  final file = File(coveragePath);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $coveragePath');
    exit(2);
  }

  final requiredThresholds = <String, double>{
    'lib/utils/validators.dart': 85,
    'lib/utils/constants.dart': 60,
  };

  final byFile = <String, _CoverageStats>{};
  String? currentFile;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
      byFile.putIfAbsent(currentFile, _CoverageStats.new);
      continue;
    }
    if (line.startsWith('DA:') && currentFile != null) {
      final values = line.substring(3).split(',');
      if (values.length != 2) continue;
      final hits = int.tryParse(values[1]) ?? 0;
      final stats = byFile[currentFile]!;
      stats.total++;
      if (hits > 0) stats.hit++;
    }
  }

  var failed = false;
  for (final entry in requiredThresholds.entries) {
    final matched = byFile.entries.where(
      (e) => e.key.endsWith(entry.key),
    );
    if (matched.isEmpty) {
      stderr.writeln('Missing coverage data for ${entry.key}');
      failed = true;
      continue;
    }
    final merged = _CoverageStats();
    for (final fileStats in matched.map((e) => e.value)) {
      merged.total += fileStats.total;
      merged.hit += fileStats.hit;
    }
    final pct = merged.percent;
    stdout.writeln(
      '${entry.key}: ${pct.toStringAsFixed(2)}% (min ${entry.value.toStringAsFixed(0)}%)',
    );
    if (pct < entry.value) {
      failed = true;
    }
  }

  if (failed) {
    stderr.writeln('Coverage gate failed.');
    exit(1);
  }

  stdout.writeln('Coverage gate passed.');
}
