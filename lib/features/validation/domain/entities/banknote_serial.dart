import 'package:equatable/equatable.dart';

class BanknoteSerial extends Equatable {
  const BanknoteSerial({
    required this.value,
    required this.denomination,
    required this.series,
  });

  final int value;
  final int denomination;
  final String series;

  @override
  List<Object> get props => [value, denomination, series];
}

