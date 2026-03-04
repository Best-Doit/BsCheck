import 'package:equatable/equatable.dart';

class RuleRange extends Equatable {
  const RuleRange({
    required this.denomination,
    required this.series,
    required this.start,
    required this.end,
  });

  final int denomination;
  final String series;
  final int start;
  final int end;

  bool contains(int serial) => serial >= start && serial <= end;

  @override
  List<Object> get props => [denomination, series, start, end];
}

