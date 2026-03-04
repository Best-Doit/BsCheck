import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/history_local_datasource.dart';

final historyDataSourceProvider = Provider<HistoryLocalDataSource>(
  (ref) => HistoryLocalDataSourceImpl(),
);

final historyEntriesProvider = FutureProvider(
  (ref) => ref.read(historyDataSourceProvider).getEntries(),
);

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(historyEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: asyncEntries.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Text('Aún no hay verificaciones.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final date = entry.timestamp;
              final dateText =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

              final (label, color) = switch (entry.resultType) {
                HistoryResultType.disabled => ('INHABILITADO', Colors.red),
                HistoryResultType.valid => ('VÁLIDO', Colors.green),
                HistoryResultType.notRecognized =>
                  ('NO RECONOCIDO', Colors.grey),
              };

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                title: Text(
                  entry.serial.isEmpty ? '(sin serie)' : entry.serial,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '$dateText · ${entry.denomination} Bs · Serie ${entry.series}',
                ),
                trailing: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error al cargar historial: $e'),
        ),
      ),
    );
  }
}

