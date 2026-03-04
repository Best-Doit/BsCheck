import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../history/data/history_local_datasource.dart';
import '../../validation/application/validation_providers.dart';
import '../../validation/domain/entities/validation_result.dart';
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
  FlashMode _flashMode = FlashMode.off;
  late final TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer();
    _initCamera();
  }

  @override
  void dispose() {
    unawaited(_turnFlashOffBeforeExit());
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
      await controller.setFlashMode(_flashMode);

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar la cámara.';
      });
    }
  }

  Future<void> _cycleFlashMode() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isBusy) {
      return;
    }

    final nextMode = switch (_flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      FlashMode.torch => FlashMode.off,
      _ => FlashMode.off,
    };

    try {
      await controller.setFlashMode(nextMode);
      if (!mounted) return;
      setState(() {
        _flashMode = nextMode;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Este dispositivo no soporta cambio de flash.';
      });
    }
  }

  Future<void> _turnFlashOffBeforeExit() async {
    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;

    try {
      await controller.setFlashMode(FlashMode.off);
    } catch (_) {
      // Mejor esfuerzo al salir de la pantalla.
    }
  }

  IconData _flashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return Icons.flash_auto_outlined;
      case FlashMode.torch:
        return Icons.flash_on_outlined;
      case FlashMode.off:
      default:
        return Icons.flash_off_outlined;
    }
  }

  String _flashLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.torch:
        return 'On';
      case FlashMode.off:
      default:
        return 'Off';
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
      final extracted = _extractScanData(recognizedText);
      await _validateAndShowResult(extracted.serial, extracted.series ?? 'B');
    } catch (_) {
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

  Future<void> _validateAndShowResult(String? candidate, String series) async {
    final ValidationResult result;

    if (candidate == null) {
      result = const ValidationResult(
        status: ValidationStatus.notRecognized,
        serial: '',
      );
    } else {
      final useCase = ref.read(validateSerialUseCaseProvider);
      result = await useCase(
        rawSerial: candidate,
        denomination: _denomination,
        series: series,
      );
    }

    final history = HistoryEntry(
      timestamp: DateTime.now(),
      serial: result.serial,
      denomination: _denomination,
      series: series,
      resultType: switch (result.status) {
        ValidationStatus.disabled => HistoryResultType.disabled,
        ValidationStatus.valid => HistoryResultType.valid,
        ValidationStatus.notRecognized => HistoryResultType.notRecognized,
      },
    );

    await HistoryLocalDataSourceImpl().addEntry(history);

    if (!mounted) return;
    await _turnFlashOffNow();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResultPage(
          result: result,
          denomination: _denomination,
          series: series,
        ),
      ),
    );
  }

  Future<void> _turnFlashOffNow() async {
    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;

    try {
      await controller.setFlashMode(FlashMode.off);
      if (mounted && _flashMode != FlashMode.off) {
        setState(() {
          _flashMode = FlashMode.off;
        });
      }
    } catch (_) {
      // Mejor esfuerzo.
    }
  }

  String? _extractSerialCandidate(RecognizedText recognizedText) {
    final regex = RegExp(r'[0-9]{7,9}');
    final scores = <String, int>{};

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final text = line.text.replaceAll(RegExp(r'[^0-9]'), ' ');
        final matches = regex.allMatches(text);
        for (final match in matches) {
          final value = match.group(0);
          if (value == null) continue;

          final lengthScore = switch (value.length) {
            8 => 5,
            9 => 3,
            7 => 2,
            _ => 0,
          };
          scores[value] = (scores[value] ?? 0) + lengthScore;
        }
      }
    }

    if (scores.isEmpty) return null;

    final candidates = scores.keys.toList()
      ..sort((a, b) {
        final byScore = scores[b]!.compareTo(scores[a]!);
        if (byScore != 0) return byScore;

        // Desempate: preferir 8 dígitos.
        final aPenalty = (a.length - 8).abs();
        final bPenalty = (b.length - 8).abs();
        return aPenalty.compareTo(bPenalty);
      });

    return candidates.first;
  }

  _ScanData _extractScanData(RecognizedText recognizedText) {
    final serial = _extractSerialCandidate(recognizedText);
    final series = _extractSeriesCandidate(recognizedText, serial: serial);
    return _ScanData(serial: serial, series: series);
  }

  String? _extractSeriesCandidate(
    RecognizedText recognizedText, {
    String? serial,
  }) {
    final scores = <String, int>{};
    final serialRegex = serial == null ? null : RegExp(RegExp.escape(serial));

    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        final raw = line.text.toUpperCase();

        // Caso típico OCR: letra + serial en la misma línea (ej: J12345678).
        final direct = RegExp(
          r'\b([A-Z])\s*[-]?\s*[0-9]{7,9}\b',
        ).firstMatch(raw);
        final directLetter = direct?.group(1);
        if (directLetter != null) {
          scores[directLetter] = (scores[directLetter] ?? 0) + 5;
        }

        // Si ya se detectó serial, buscar la letra más cercana antes del número.
        if (serialRegex != null) {
          final serialMatch = serialRegex.firstMatch(raw);
          if (serialMatch != null && serialMatch.start > 0) {
            final prefix = raw.substring(0, serialMatch.start);
            final near = RegExp(r'([A-Z])[^A-Z]*$').firstMatch(prefix);
            final nearLetter = near?.group(1);
            if (nearLetter != null) {
              scores[nearLetter] = (scores[nearLetter] ?? 0) + 6;
            }
          }
        }

        // Fallback: letras aisladas.
        for (final isolated in RegExp(r'\b([A-Z])\b').allMatches(raw)) {
          final letter = isolated.group(1);
          if (letter != null) {
            scores[letter] = (scores[letter] ?? 0) + 1;
          }
        }
      }
    }

    if (scores.isEmpty) return null;
    final ranked = scores.keys.toList()
      ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
    return ranked.first;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        foregroundColor: const Color(0xFF0D1B0F),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: const Text(
          'Escanear billete',
          style: TextStyle(
            color: Color(0xFF0D1B0F),
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _cycleFlashMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _flashMode == FlashMode.off
                      ? colors.outlineVariant.withValues(alpha: 0.3)
                      : colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: _flashMode == FlashMode.off
                        ? colors.outlineVariant
                        : colors.primary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _flashIcon(_flashMode),
                      size: 16,
                      color: _flashMode == FlashMode.off
                          ? colors.onSurfaceVariant
                          : colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _flashLabel(_flashMode),
                      style: TextStyle(
                        color: _flashMode == FlashMode.off
                            ? colors.onSurfaceVariant
                            : colors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Selector de corte ────────────────────────────────
          Container(
            color: const Color(0xFFF7F9FB),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instrucción principal
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Selecciona el corte del billete a escanear',
                        style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF0D1B0F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Botones de denominación grandes
                Row(
                  children: [10, 20, 50].map((denom) {
                    final selected = _denomination == denom;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: denom != 50 ? 10 : 0,
                        ),
                        child: GestureDetector(
                          onTap: _isBusy
                              ? null
                              : () => setState(() => _denomination = denom),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 72,
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? colors.primary
                                    : colors.outlineVariant,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: colors.primary
                                            .withValues(alpha: 0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$denom',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF0D1B0F),
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  'Bs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.85)
                                        : colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // ─── Vista de cámara ──────────────────────────────────
          Expanded(
            child: controller == null || !controller.value.isInitialized
                ? Container(
                    color: const Color(0xFF0D1B0F),
                    child: Center(
                      child: _error != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam_off_rounded,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                    ),
                  )
                : ClipRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // FittedBox.cover respeta el aspect ratio del sensor
                        // y rellena el área sin aplastar la imagen.
                        SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: controller.value.previewSize!.height,
                              height: controller.value.previewSize!.width,
                              child: CameraPreview(controller),
                            ),
                          ),
                        ),
                        _ScannerOverlayFrame(primaryColor: colors.primary),
                      ],
                    ),
                  ),
          ),

          // ─── Botón de captura ─────────────────────────────────
          Container(
            color: const Color(0xFFF7F9FB),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              children: [
                // Paso 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Alinea la serie dentro del marco y captura',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _isBusy
                          ? colors.primary.withValues(alpha: 0.5)
                          : colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                    label: Text(_isBusy ? 'Procesando…' : 'Capturar y validar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanData {
  const _ScanData({required this.serial, required this.series});

  final String? serial;
  final String? series;
}

/// Overlay con esquinas estilo fintech + zona central transparente.
class _ScannerOverlayFrame extends StatelessWidget {
  const _ScannerOverlayFrame({required this.primaryColor});

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        const frameW = 280.0;
        const frameH = 100.0;
        final left = (w - frameW) / 2;
        final top = (h - frameH) / 2 - 20;

        return CustomPaint(
          painter: _OverlayPainter(
            frameRect: Rect.fromLTWH(left, top, frameW, frameH),
            borderColor: primaryColor,
          ),
          child: Positioned(
            left: left,
            top: top + frameH + 16,
            width: frameW,
            child: const Text(
              'Apunta la cámara hacia la serie del billete',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  const _OverlayPainter({required this.frameRect, required this.borderColor});

  final Rect frameRect;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Sombra oscura sobre toda la pantalla menos el frame.
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    const r = 14.0;
    final framePath = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(r)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, framePath),
      overlayPaint,
    );

    // Esquinas tipo bracket (L-shape) con el color primario.
    const cornerLen = 24.0;
    final x = frameRect.left;
    final y = frameRect.top;
    final x2 = frameRect.right;
    final y2 = frameRect.bottom;

    // Top-left
    canvas.drawLine(
      Offset(x + r, y),
      Offset(x + r + cornerLen, y),
      borderPaint,
    );
    canvas.drawLine(
      Offset(x, y + r),
      Offset(x, y + r + cornerLen),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(x, y, r * 2, r * 2),
      -3.14,
      3.14 / 2,
      false,
      borderPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(x2 - r - cornerLen, y),
      Offset(x2 - r, y),
      borderPaint,
    );
    canvas.drawLine(
      Offset(x2, y + r),
      Offset(x2, y + r + cornerLen),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(x2 - r * 2, y, r * 2, r * 2),
      -3.14 / 2,
      3.14 / 2,
      false,
      borderPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(x + r, y2),
      Offset(x + r + cornerLen, y2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(x, y2 - r - cornerLen),
      Offset(x, y2 - r),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(x, y2 - r * 2, r * 2, r * 2),
      3.14 / 2,
      3.14 / 2,
      false,
      borderPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(x2 - r - cornerLen, y2),
      Offset(x2 - r, y2),
      borderPaint,
    );
    canvas.drawLine(
      Offset(x2, y2 - r - cornerLen),
      Offset(x2, y2 - r),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(x2 - r * 2, y2 - r * 2, r * 2, r * 2),
      0,
      3.14 / 2,
      false,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) =>
      old.frameRect != frameRect || old.borderColor != borderColor;
}
