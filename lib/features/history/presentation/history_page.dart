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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.primaryContainer, const Color(0xFFF4FAF6)],
                ),
              ),
            ),
          ),
          asyncEntries.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(child: Text('Aún no hay verificaciones.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final date = entry.timestamp;
                  final dateText =
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                  final (label, color) = switch (entry.resultType) {
                    HistoryResultType.disabled => ('INHABILITADO', Colors.red),
                    HistoryResultType.valid => ('VÁLIDO', colors.primary),
                    HistoryResultType.notRecognized => (
                      'NO RECONOCIDO',
                      colors.onSurfaceVariant,
                    ),
                  };

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 52,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.serial.isEmpty
                                      ? '(sin serie)'
                                      : entry.serial,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$dateText · ${entry.denomination} Bs · Serie ${entry.series}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: color,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Error al cargar historial: $e')),
          ),
        ],
      ),
    );
  }
}
