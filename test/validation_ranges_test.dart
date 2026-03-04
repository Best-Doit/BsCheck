import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:bscheck/features/validation/data/datasources/rules_local_datasource.dart';
import 'package:bscheck/features/validation/data/repositories/rules_repository_impl.dart';
import 'package:bscheck/features/validation/domain/entities/rule_range.dart';
import 'package:bscheck/features/validation/domain/entities/validation_result.dart';

class _TestRulesLocalDataSource implements RulesLocalDataSource {
  _TestRulesLocalDataSource(this._rules);

  final List<RuleRange> _rules;

  @override
  Future<List<RuleRange>> loadRules() async => _rules;
}

Future<List<RuleRange>> _loadRulesFromAssetFile() async {
  final file = File('assets/rules/rules_v1.json');
  final raw = await file.readAsString();
  final decoded = json.decode(raw) as Map<String, dynamic>;
  final rulesJson = decoded['rules'] as List<dynamic>;

  return rulesJson
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => RuleRange(
          denomination: e['denomination'] as int,
          series: e['series'] as String,
          start: e['start'] as int,
          end: e['end'] as int,
        ),
      )
      .toList();
}

void main() {
  late RulesRepositoryImpl repository;

  setUpAll(() async {
    final rules = await _loadRulesFromAssetFile();
    repository = RulesRepositoryImpl(_TestRulesLocalDataSource(rules));
  });

  group('Validation ranges from rules_v1.json', () {
    test('10 Bs, serie B, límite inferior dentro de rango => disabled', () async {
      final result = await repository.validateSerial(
        rawSerial: '77100001',
        denomination: 10,
        series: 'B',
      );

      expect(result.status, ValidationStatus.disabled);
    });

    test('10 Bs, serie B, fuera de rangos => valid', () async {
      final result = await repository.validateSerial(
        rawSerial: '77550001',
        denomination: 10,
        series: 'B',
      );

      expect(result.status, ValidationStatus.valid);
    });

    test('20 Bs, serie B, primer rango conocido => disabled', () async {
      final result = await repository.validateSerial(
        rawSerial: '87280145',
        denomination: 20,
        series: 'B',
      );

      expect(result.status, ValidationStatus.disabled);
    });

    test('20 Bs, serie B, justo después de rango => valid', () async {
      final result = await repository.validateSerial(
        rawSerial: '91646550',
        denomination: 20,
        series: 'B',
      );

      expect(result.status, ValidationStatus.valid);
    });

    test('50 Bs, serie B, valor dentro de rango medio => disabled', () async {
      final result = await repository.validateSerial(
        rawSerial: '76310012',
        denomination: 50,
        series: 'B',
      );

      expect(result.status, ValidationStatus.disabled);
    });

    test('50 Bs, serie B, valor fuera de rango medio => valid', () async {
      final result = await repository.validateSerial(
        rawSerial: '76310011',
        denomination: 50,
        series: 'B',
      );

      expect(result.status, ValidationStatus.valid);
    });

    test('misma numeración pero serie J no usa reglas de serie B => valid', () async {
      final result = await repository.validateSerial(
        rawSerial: '87280145',
        denomination: 20,
        series: 'J',
      );

      expect(result.status, ValidationStatus.valid);
    });
  });
}
