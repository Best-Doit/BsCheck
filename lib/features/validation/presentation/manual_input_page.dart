import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../validation/application/validation_providers.dart';
import '../../validation/domain/entities/validation_result.dart';
import '../../history/data/history_local_datasource.dart';
import 'result_page.dart';

class ManualInputPage extends ConsumerStatefulWidget {
  const ManualInputPage({super.key});

  @override
  ConsumerState<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends ConsumerState<ManualInputPage> {
  final _controller = TextEditingController();
  int _denomination = 10;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onValidatePressed() async {
    setState(() {
      _errorText = null;
    });

    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorText = 'Ingresa la serie del billete';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final useCase = ref.read(validateSerialUseCaseProvider);
      final result = await useCase(
        rawSerial: text,
        denomination: _denomination,
        series: 'B',
      );

      final history = HistoryEntry(
        timestamp: DateTime.now(),
        serial: result.serial,
        denomination: _denomination,
        series: 'B',
        resultType: switch (result.status) {
          ValidationStatus.disabled => HistoryResultType.disabled,
          ValidationStatus.valid => HistoryResultType.valid,
          ValidationStatus.notRecognized => HistoryResultType.notRecognized,
        },
      );
      await HistoryLocalDataSourceImpl().addEntry(history);

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute<ValidationResult>(
          builder: (_) => ResultPage(
            result: result,
            denomination: _denomination,
            series: 'B',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Error al validar. Intenta de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso Manual')),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Selecciona el corte y escribe la serie del billete.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('10 Bs'),
                      selected: _denomination == 10,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _denomination = 10);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('20 Bs'),
                      selected: _denomination == 20,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _denomination = 20);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('50 Bs'),
                      selected: _denomination == 50,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() => _denomination = 50);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          maxLength: 9,
                          decoration: InputDecoration(
                            labelText: 'Serie del billete',
                            hintText: 'Ej: 87280145',
                            errorText: _errorText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Usa solo dígitos (7 a 9 números).',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _onValidatePressed,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(_isLoading ? 'Validando...' : 'Validar Billete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
