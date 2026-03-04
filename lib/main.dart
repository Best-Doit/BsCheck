import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/validation/presentation/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: BsCheckApp()));
}

class BsCheckApp extends StatelessWidget {
  const BsCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00796B),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    return MaterialApp(title: 'BsCheck', theme: theme, home: const HomePage());
  }
}
