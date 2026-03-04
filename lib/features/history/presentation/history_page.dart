import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/widgets/history_item.dart';
import '../data/history_local_datasource.dart';

final historyDataSourceProvider = Provider<HistoryLocalDataSource>(
  (ref) => HistoryLocalDataSourceImpl(),
);

final historyEntriesProvider = StreamProvider.autoDispose<List<HistoryEntry>>(
  (ref) => ref.read(historyDataSourceProvider).watchEntries(),
);

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(historyEntriesProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
      ),
      body: asyncEntries.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(colors: colors, textTheme: textTheme);
          }

          // Agrupar entradas por fecha relativa
          final groups = _groupByDate(entries);

          // Calcular stats
          final totalValid = entries
              .where((e) => e.resultType == HistoryResultType.valid)
              .length;
          final totalDisabled = entries
              .where((e) => e.resultType == HistoryResultType.disabled)
              .length;

          return CustomScrollView(
            slivers: [
              // ─── Stats rápidos ──────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Válidos',
                          value: totalValid.toString(),
                          color: const Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.cancel_rounded,
                          label: 'Inhabilitados',
                          value: totalDisabled.toString(),
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.history_rounded,
                          label: 'Total',
                          value: entries.length.toString(),
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Grupos con cabecera de fecha ───────────────────
              for (final group in groups) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          group.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurfaceVariant,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: colors.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${group.entries.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  sliver: SliverList.separated(
                    itemCount: group.entries.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = group.entries[index];
                      final date = entry.timestamp;
                      final timeText =
                          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

                      final (label, color) = switch (entry.resultType) {
                        HistoryResultType.disabled => (
                          'INHABILITADO',
                          const Color(0xFFD32F2F),
                        ),
                        HistoryResultType.valid => (
                          'VÁLIDO',
                          const Color(0xFF1B5E20),
                        ),
                        HistoryResultType.notRecognized => (
                          'NO RECONOCIDO',
                          colors.onSurfaceVariant,
                        ),
                      };

                      return HistoryListItem(
                        serial: entry.serial,
                        metadata: '$timeText · ${entry.denomination} Bs',
                        badgeLabel: label,
                        badgeColor: color,
                      );
                    },
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error al cargar historial: $e'),
        ),
      ),
    );
  }

  List<_DateGroup> _groupByDate(List<HistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    final groups = <String, List<HistoryEntry>>{};

    for (final entry in entries) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      final String label;
      if (entryDate == today) {
        label = 'Hoy';
      } else if (entryDate == yesterday) {
        label = 'Ayer';
      } else if (entryDate.isAfter(thisWeekStart)) {
        label = 'Esta semana';
      } else {
        final month = _monthName(entryDate.month);
        label = '$month ${entryDate.year}';
      }

      groups.putIfAbsent(label, () => []).add(entry);
    }

    const order = ['Hoy', 'Ayer', 'Esta semana'];
    final result = <_DateGroup>[];

    for (final label in order) {
      if (groups.containsKey(label)) {
        result.add(_DateGroup(label: label, entries: groups[label]!));
        groups.remove(label);
      }
    }

    // Meses restantes (orden descendente)
    final remaining = groups.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    for (final e in remaining) {
      result.add(_DateGroup(label: e.key, entries: e.value));
    }

    return result;
  }

  String _monthName(int month) {
    const names = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month];
  }
}

class _DateGroup {
  const _DateGroup({required this.label, required this.entries});
  final String label;
  final List<HistoryEntry> entries;
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.textTheme});

  final ColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 38,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin verificaciones',
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando verifiques un billete, verás aquí el resultado con su serie, denominación y fecha.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
