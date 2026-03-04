import '../entities/banknote_serial.dart';
import '../entities/validation_result.dart';

abstract class RulesRepository {
  Future<void> loadRules();

  /// Validates the given [serial] and returns a [ValidationResult].
  ///
  /// [rawSerial] is the numeric string as obtained from OCR or manual input.
  /// [denomination] and [series] are used to filter ranges (MVP: fixed series "B").
  Future<ValidationResult> validateSerial({
    required String rawSerial,
    required int denomination,
    required String series,
  });

  /// Optional helper to construct a [BanknoteSerial] from input.
  BanknoteSerial? parseSerial({
    required String rawSerial,
    required int denomination,
    required String series,
  });
}

