import '../domain/entities/validation_result.dart';
import '../domain/repositories/rules_repository.dart';

class ValidateSerialUseCase {
  const ValidateSerialUseCase(this._repository);

  final RulesRepository _repository;

  Future<ValidationResult> call({
    required String rawSerial,
    required int denomination,
    required String series,
  }) {
    return _repository.validateSerial(
      rawSerial: rawSerial,
      denomination: denomination,
      series: series,
    );
  }
}

