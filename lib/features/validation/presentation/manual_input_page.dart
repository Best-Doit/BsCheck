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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar serie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona el corte y escribe la serie del billete.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 10, label: Text('10 Bs')),
                ButtonSegment(value: 20, label: Text('20 Bs')),
                ButtonSegment(value: 50, label: Text('50 Bs')),
              ],
              selected: {_denomination},
              onSelectionChanged: (values) {
                setState(() {
                  _denomination = values.first;
                });
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'Serie',
                hintText: 'Ej: 87280145',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _onValidatePressed,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Validar'),
            ),
          ],
        ),
      ),
    );
  }
}

