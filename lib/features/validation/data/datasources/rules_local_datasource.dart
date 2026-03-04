import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/rule_range.dart';

abstract class RulesLocalDataSource {
  Future<List<RuleRange>> loadRules();
}

class RulesLocalDataSourceImpl implements RulesLocalDataSource {
  const RulesLocalDataSourceImpl();

  @override
  Future<List<RuleRange>> loadRules() async {
    final jsonStr = await rootBundle.loadString('assets/rules/rules_v1.json');
    final decoded = json.decode(jsonStr) as Map<String, dynamic>;
    final rulesJson = decoded['rules'] as List<dynamic>? ?? <dynamic>[];

    final rules = rulesJson
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => RuleRange(
            denomination: e['denomination'] as int,
            series: e['series'] as String,
            start: e['start'] as int,
            end: e['end'] as int,
          ),
        )
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return rules;
  }
}

