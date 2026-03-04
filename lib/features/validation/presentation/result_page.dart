import 'package:flutter/material.dart';

import '../../validation/domain/entities/validation_result.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.result,
    required this.denomination,
    required this.series,
  });

  final ValidationResult result;
  final int denomination;
  final String series;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (title, description, color, icon) = switch (result.status) {
      ValidationStatus.disabled => (
        'Billete inhabilitado',
        'Este billete está en un rango de series inhabilitadas.',
        Colors.red,
        Icons.warning_amber_rounded,
      ),
      ValidationStatus.valid => (
        'Billete válido',
        'La serie no se encuentra en los rangos inhabilitados.',
        Colors.green,
        Icons.check_circle_rounded,
      ),
      ValidationStatus.notRecognized => (
        'No reconocido',
        'No se pudo interpretar la serie ingresada.',
        Colors.grey,
        Icons.help_outline_rounded,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: color, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Serie: ${result.serial}'),
                        Text('Corte: $denomination Bs'),
                        Text('Serie letra: $series'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(fontSize: 14)),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
