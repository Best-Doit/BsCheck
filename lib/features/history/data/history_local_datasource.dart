import 'package:hive/hive.dart';

enum HistoryResultType { valid, disabled, notRecognized }

class HistoryEntry {
  HistoryEntry({
    required this.timestamp,
    required this.serial,
    required this.denomination,
    required this.series,
    required this.resultType,
  });

  final DateTime timestamp;
  final String serial;
  final int denomination;
  final String series;
  final HistoryResultType resultType;
}

abstract class HistoryLocalDataSource {
  Future<void> addEntry(HistoryEntry entry);
  Future<List<HistoryEntry>> getEntries();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const _boxName = 'bscheck_history';

  Future<Box<Map>> _openBox() async {
    return Hive.openBox<Map>(_boxName);
  }

  @override
  Future<void> addEntry(HistoryEntry entry) async {
    final box = await _openBox();
    await box.add({
      'timestamp': entry.timestamp.toIso8601String(),
      'serial': entry.serial,
      'denomination': entry.denomination,
      'series': entry.series,
      'resultType': entry.resultType.name,
    });
  }

  @override
  Future<List<HistoryEntry>> getEntries() async {
    final box = await _openBox();
    final entries = <HistoryEntry>[];

    for (final data in box.values) {
      entries.add(
        HistoryEntry(
          timestamp: DateTime.parse(data['timestamp'] as String),
          serial: data['serial'] as String,
          denomination: data['denomination'] as int,
          series: data['series'] as String,
          resultType: HistoryResultType.values.firstWhere(
            (e) => e.name == data['resultType'],
            orElse: () => HistoryResultType.notRecognized,
          ),
        ),
      );
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
}

