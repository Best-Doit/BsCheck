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

  // ────────────────────────────────────────────────────────────────
  // CORTE 10 Bs
  // Rangos inhabilitados:
  //   67250001-67700000 | 69050001-71300000 (5 rangos continuos)
  //   76310012-85139995 | 86400001-86850000
  //   90900001-91350000 | 91800001-92250000
  // ────────────────────────────────────────────────────────────────
  group('10 Bs – validación de rangos', () {
    test('límite inferior primer rango 67250001 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '67250001', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('límite superior primer rango 67700000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '67700000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo antes del primer rango 67250000 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '67250000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('justo después del primer rango 67700001 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '67700001', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('inicio rango grande 76310012 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '76310012', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo antes rango grande 76310011 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '76310011', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('centro rango grande 80000000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '80000000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('fin rango grande 85139995 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '85139995', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo después rango grande 85139996 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '85139996', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('dentro rango 91800001-92250000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '92000000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('número fuera de todos los rangos 10 Bs => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '68000000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // CORTE 20 Bs
  // ────────────────────────────────────────────────────────────────
  group('20 Bs – validación de rangos', () {
    test('inicio primer rango 87280145 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '87280145', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('fin primer rango 91646549 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '91646549', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo después primer rango 91646550 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '91646550', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('dentro rango 120500001-120950000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '120700000', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('número fuera de todos los rangos 20 Bs => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '95000000', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // CORTE 50 Bs
  // Rangos inhabilitados:
  //   77100001-77550000 | 78000001-78450000 | 78900001-96350000
  //   96350001-96800000 | 96800001-97250000 | 98150001-98600000
  //   104900001-105350000 | 105350001-105800000 | 106700001-107150000
  //   107600001-108050000 | 108050001-108500000 | 109400001-109850000
  // ────────────────────────────────────────────────────────────────
  group('50 Bs – validación de rangos', () {
    test('inicio primer rango 77100001 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '77100001', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('fin primer rango 77550000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '77550000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo antes primer rango 77100000 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '77100000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('centro rango grande 78900001-96350000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '85000000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('inicio rango grande 78900001 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '78900001', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('fin rango grande 96350000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '96350000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('dentro último rango 109400001-109850000 => disabled', () async {
      final r = await repository.validateSerial(
        rawSerial: '109600000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('justo después último rango 109850001 => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '109850001', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    test('número fuera de todos los rangos 50 Bs => valid', () async {
      final r = await repository.validateSerial(
        rawSerial: '67250001', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // AISLAMIENTO ENTRE DENOMINACIONES
  // El mismo número debe dar resultados distintos según el corte
  // ────────────────────────────────────────────────────────────────
  group('Aislamiento entre denominaciones', () {
    // 80000000 está en rango 10 Bs (76310012-85139995) Y en rango 50 Bs (78900001-96350000)
    test('80000000 es disabled para 10 Bs', () async {
      final r = await repository.validateSerial(
        rawSerial: '80000000', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('80000000 es disabled para 50 Bs', () async {
      final r = await repository.validateSerial(
        rawSerial: '80000000', denomination: 50, series: 'B',
      );
      expect(r.status, ValidationStatus.disabled);
    });

    test('80000000 es valid para 20 Bs (no está en ningún rango de 20)', () async {
      final r = await repository.validateSerial(
        rawSerial: '80000000', denomination: 20, series: 'B',
      );
      expect(r.status, ValidationStatus.valid);
    });

    // La letra de serie no afecta la validación (solo se usa denominación)
    test('la letra de serie no afecta el resultado', () async {
      final withB = await repository.validateSerial(
        rawSerial: '67250001', denomination: 10, series: 'B',
      );
      final withA = await repository.validateSerial(
        rawSerial: '67250001', denomination: 10, series: 'A',
      );
      expect(withB.status, ValidationStatus.disabled);
      expect(withA.status, ValidationStatus.disabled);
    });
  });

  // ────────────────────────────────────────────────────────────────
  // EDGE CASES DEL PARSER
  // ────────────────────────────────────────────────────────────────
  group('Edge cases del parser de series', () {
    test('serie con menos de 7 dígitos => notRecognized', () async {
      final r = await repository.validateSerial(
        rawSerial: '123456', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.notRecognized);
    });

    test('serie con más de 9 dígitos => notRecognized', () async {
      final r = await repository.validateSerial(
        rawSerial: '1234567890', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.notRecognized);
    });

    test('serie vacía => notRecognized', () async {
      final r = await repository.validateSerial(
        rawSerial: '', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.notRecognized);
    });

    test('serie con texto no numérico => notRecognized', () async {
      final r = await repository.validateSerial(
        rawSerial: 'ABCDEFGH', denomination: 10, series: 'B',
      );
      expect(r.status, ValidationStatus.notRecognized);
    });
  });
}
