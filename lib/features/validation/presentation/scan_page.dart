import 'dart:async';

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

    try {
      final file = await controller.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final regex = RegExp(r'[0-9]{7,9}');
      String? candidate;

      for (final block in recognizedText.blocks) {
        final text = block.text.replaceAll(RegExp(r'[^0-9]'), ' ');
        final matches = regex.allMatches(text);
        for (final m in matches) {
          final value = m.group(0);
          if (value == null) continue;
          if (candidate == null || value.length > candidate.length) {
            candidate = value;
          }
        }
      }

      if (candidate == null) {
        final result = ValidationResult(
          status: ValidationStatus.notRecognized,
          serial: '',
        );
        final history = HistoryEntry(
          timestamp: DateTime.now(),
          serial: result.serial,
          denomination: 10,
          series: 'B',
          resultType: HistoryResultType.notRecognized,
        );
        await HistoryLocalDataSourceImpl().addEntry(history);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ResultPage(
              result: result,
              denomination: 10,
              series: 'B',
            ),
          ),
        );
      } else {
        final useCase = ref.read(validateSerialUseCaseProvider);
        final validation = await useCase(
          rawSerial: candidate,
          // MVP: el usuario elegirá el corte en una versión futura;
          // por ahora se asume 10 Bs como valor por defecto.
          denomination: 10,
          series: 'B',
        );

        final history = HistoryEntry(
          timestamp: DateTime.now(),
          serial: validation.serial,
          denomination: 10,
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
              denomination: 10,
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
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear billete'),
      ),
      body: Column(
        children: [
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
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CameraPreview(controller),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                          colors: [
                            const Color(0x99000000),
                            const Color(0x00000000),
                          ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 260,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 24,
                            left: 16,
                            right: 16,
                            child: Text(
                              'Alinea la serie del billete dentro del recuadro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(_isBusy ? 'Procesando...' : 'Capturar y validar'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

