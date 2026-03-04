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
      final timestampRaw = data['timestamp'];
      final serialRaw = data['serial'];
      final denominationRaw = data['denomination'];
      final seriesRaw = data['series'];
      final resultTypeRaw = data['resultType'];

      if (timestampRaw is! String ||
          serialRaw is! String ||
          seriesRaw is! String) {
        continue;
      }

      final timestamp = DateTime.tryParse(timestampRaw);
      final denomination = _toInt(denominationRaw);
      if (timestamp == null || denomination == null) {
        continue;
      }

      final resultType = resultTypeRaw is String
          ? HistoryResultType.values.firstWhere(
              (e) => e.name == resultTypeRaw,
              orElse: () => HistoryResultType.notRecognized,
            )
          : HistoryResultType.notRecognized;

      entries.add(
        HistoryEntry(
          timestamp: timestamp,
          serial: serialRaw,
          denomination: denomination,
          series: seriesRaw,
          resultType: resultType,
        ),
      );
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
