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
  late List<RuleRange> rules;

  setUpAll(() async {
    rules = await _loadRulesFromAssetFile();
    repository = RulesRepositoryImpl(_TestRulesLocalDataSource(rules));
  });

  test('start/end/mid are disabled for every configured range', () async {
    for (final rule in rules) {
      final mid = rule.start + ((rule.end - rule.start) ~/ 2);

      final startResult = await repository.validateSerial(
        rawSerial: rule.start.toString(),
        denomination: rule.denomination,
        series: rule.series,
      );
      final endResult = await repository.validateSerial(
        rawSerial: rule.end.toString(),
        denomination: rule.denomination,
        series: rule.series,
      );
      final midResult = await repository.validateSerial(
        rawSerial: mid.toString(),
        denomination: rule.denomination,
        series: rule.series,
      );

      expect(
        startResult.status,
        ValidationStatus.disabled,
        reason:
            'Start should be disabled for ${rule.denomination} ${rule.series} (${rule.start}-${rule.end})',
      );
      expect(
        endResult.status,
        ValidationStatus.disabled,
        reason:
            'End should be disabled for ${rule.denomination} ${rule.series} (${rule.start}-${rule.end})',
      );
      expect(
        midResult.status,
        ValidationStatus.disabled,
        reason:
            'Mid should be disabled for ${rule.denomination} ${rule.series} (${rule.start}-${rule.end})',
      );
    }
  });
}
