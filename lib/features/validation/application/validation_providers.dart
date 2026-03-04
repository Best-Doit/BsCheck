import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/rules_local_datasource.dart';
import '../data/repositories/rules_repository_impl.dart';
import '../domain/repositories/rules_repository.dart';
import 'validate_serial_usecase.dart';

final rulesLocalDataSourceProvider = Provider<RulesLocalDataSource>(
  (ref) => const RulesLocalDataSourceImpl(),
);

final rulesRepositoryProvider = Provider<RulesRepository>(
  (ref) => RulesRepositoryImpl(ref.read(rulesLocalDataSourceProvider)),
);

final validateSerialUseCaseProvider = Provider<ValidateSerialUseCase>(
  (ref) => ValidateSerialUseCase(ref.read(rulesRepositoryProvider)),
);

