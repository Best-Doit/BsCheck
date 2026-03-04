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
      appBar: AppBar(
        title: const Text('Resultado'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalle',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Serie: ${result.serial}'),
                    Text('Corte: $denomination Bs'),
                    Text('Serie letra: $series'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

