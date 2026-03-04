import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../validation/application/validation_providers.dart';
import '../../validation/domain/entities/validation_result.dart';
import '../../history/data/history_local_datasource.dart';
import 'result_page.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  CameraController? _controller;
  bool _isBusy = false;
  String? _error;
  int _denomination = 10;
  late final TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar la cámara.';
      });
    }
  }

  Future<void> _captureAndValidate() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });

    XFile? file;
    try {
      file = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      final candidate = _extractSerialCandidate(recognizedText);

      if (candidate == null) {
        final result = ValidationResult(
          status: ValidationStatus.notRecognized,
          serial: '',
        );
        final history = HistoryEntry(
          timestamp: DateTime.now(),
          serial: result.serial,
          denomination: _denomination,
          series: 'B',
          resultType: HistoryResultType.notRecognized,
        );
        await HistoryLocalDataSourceImpl().addEntry(history);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultPage(
              result: result,
              denomination: _denomination,
              series: 'B',
            ),
          ),
        );
      } else {
        final useCase = ref.read(validateSerialUseCaseProvider);
        final validation = await useCase(
          rawSerial: candidate,
          denomination: _denomination,
          series: 'B',
        );

        final history = HistoryEntry(
          timestamp: DateTime.now(),
          serial: validation.serial,
          denomination: _denomination,
          series: 'B',
          resultType: switch (validation.status) {
            ValidationStatus.disabled => HistoryResultType.disabled,
            ValidationStatus.valid => HistoryResultType.valid,
            ValidationStatus.notRecognized => HistoryResultType.notRecognized,
          },
        );
        await HistoryLocalDataSourceImpl().addEntry(history);

        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultPage(
              result: validation,
              denomination: _denomination,
              series: 'B',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al procesar la imagen.';
      });
    } finally {
      if (file != null) {
        try {
          await File(file.path).delete();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  String? _extractSerialCandidate(RecognizedText recognizedText) {
    final regex = RegExp(r'[0-9]{7,9}');
    final occurrences = <String, int>{};
    final firstSeenAt = <String, int>{};
    var index = 0;

    for (final block in recognizedText.blocks) {
      final text = block.text.replaceAll(RegExp(r'[^0-9]'), ' ');
      final matches = regex.allMatches(text);
      for (final match in matches) {
        final value = match.group(0);
        if (value == null) continue;
        occurrences[value] = (occurrences[value] ?? 0) + 1;
        firstSeenAt.putIfAbsent(value, () => index);
        index++;
      }
    }

    if (occurrences.isEmpty) {
      return null;
    }

    final candidates = occurrences.keys.toList()
      ..sort((a, b) {
        final byFrequency = occurrences[b]!.compareTo(occurrences[a]!);
        if (byFrequency != 0) return byFrequency;

        final byLength = _lengthPenalty(
          a.length,
        ).compareTo(_lengthPenalty(b.length));
        if (byLength != 0) return byLength;

        return firstSeenAt[a]!.compareTo(firstSeenAt[b]!);
      });

    return candidates.first;
  }

  int _lengthPenalty(int length) {
    if (length == 8) return 0;
    if (length == 9) return 1;
    if (length == 7) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escaneo')),
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    const Text(
                      'Corte:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('10 Bs'),
                            selected: _denomination == 10,
                            onSelected: _isBusy
                                ? null
                                : (selected) {
                                    if (!selected) return;
                                    setState(() => _denomination = 10);
                                  },
                          ),
                          ChoiceChip(
                            label: const Text('20 Bs'),
                            selected: _denomination == 20,
                            onSelected: _isBusy
                                ? null
                                : (selected) {
                                    if (!selected) return;
                                    setState(() => _denomination = 20);
                                  },
                          ),
                          ChoiceChip(
                            label: const Text('50 Bs'),
                            selected: _denomination == 50,
                            onSelected: _isBusy
                                ? null
                                : (selected) {
                                    if (!selected) return;
                                    setState(() => _denomination = 50);
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: controller == null || !controller.value.isInitialized
                      ? Center(
                          child: _error != null
                              ? Text(_error!)
                              : const CircularProgressIndicator(),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CameraPreview(controller),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 150,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color(0xB3000000),
                                        Color(0x00000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 280,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: colors.primary.withValues(
                                        alpha: 0.95,
                                      ),
                                      width: 2.6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.primary.withValues(
                                          alpha: 0.28,
                                        ),
                                        blurRadius: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Positioned(
                                bottom: 24,
                                left: 16,
                                right: 16,
                                child: Text(
                                  'Alinea la serie dentro del recuadro',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FilledButton.icon(
                  onPressed: _isBusy ? null : _captureAndValidate,
                  icon: _isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.camera_alt_rounded),
                  label: Text(_isBusy ? 'Procesando...' : 'Capturar y validar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
