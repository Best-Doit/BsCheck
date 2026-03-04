import 'dart:async';

import '../../domain/entities/banknote_serial.dart';
import '../../domain/entities/rule_range.dart';
import '../../domain/entities/validation_result.dart';
import '../../domain/repositories/rules_repository.dart';
import '../datasources/rules_local_datasource.dart';

class RulesRepositoryImpl implements RulesRepository {
  RulesRepositoryImpl(this._localDataSource);

  final RulesLocalDataSource _localDataSource;

  List<RuleRange>? _cachedRules;

  @override
  Future<void> loadRules() async {
    _cachedRules = await _localDataSource.loadRules();
  }

  @override
  BanknoteSerial? parseSerial({
    required String rawSerial,
    required int denomination,
    required String series,
  }) {
    final cleaned = rawSerial.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 7 || cleaned.length > 9) {
      return null;
    }
    final value = int.tryParse(cleaned);
    if (value == null) {
      return null;
    }
    return BanknoteSerial(
      value: value,
      denomination: denomination,
      series: series,
    );
  }

  @override
  Future<ValidationResult> validateSerial({
    required String rawSerial,
    required int denomination,
    required String series,
  }) async {
    _cachedRules ??= await _localDataSource.loadRules();
    final rules = _cachedRules!;

    final serial = parseSerial(
      rawSerial: rawSerial,
      denomination: denomination,
      series: series,
    );
    if (serial == null) {
      return ValidationResult(
        status: ValidationStatus.notRecognized,
        serial: rawSerial,
      );
    }

    final filtered = rules
        .where(
          (r) =>
              r.denomination == serial.denomination &&
              r.series == serial.series,
        )
        .toList();

    if (filtered.isEmpty) {
      return ValidationResult(
        status: ValidationStatus.valid,
        serial: serial.value.toString(),
      );
    }

    filtered.sort((a, b) => a.start.compareTo(b.start));

    final isDisabled = _binarySearchInRanges(filtered, serial.value);

    return ValidationResult(
      status: isDisabled ? ValidationStatus.disabled : ValidationStatus.valid,
      serial: serial.value.toString(),
    );
  }

  bool _binarySearchInRanges(List<RuleRange> ranges, int serial) {
    var low = 0;
    var high = ranges.length - 1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final range = ranges[mid];

      if (range.contains(serial)) {
        return true;
      }
      if (serial < range.start) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    return false;
  }
}
