import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/widgets/app_button.dart';
import '../../history/data/history_local_datasource.dart';
import '../../validation/application/validation_providers.dart';
import '../../validation/domain/entities/validation_result.dart';
import 'result_page.dart';

class ManualInputPage extends ConsumerStatefulWidget {
  const ManualInputPage({super.key});

  @override
  ConsumerState<ManualInputPage> createState() => _ManualInputPageState();
}

class _ManualInputPageState extends ConsumerState<ManualInputPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _denomination = 10;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onValidatePressed() async {
    _focusNode.unfocus();
    setState(() => _errorText = null);

    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Ingresa la serie del billete');
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isLoading = true);

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
      setState(() => _errorText = 'Error al validar. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      // Sin AppBar — usamos header personalizado
      body: GestureDetector(
        onTap: () => _focusNode.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header inmersivo ──────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                safePadding.top + 16,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1B5E20),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón back
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ingresa la serie',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escribe los dígitos que aparecen en el billete',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Contenido ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tip: dónde encontrar la serie
                    _SerialTipCard(),

                    const SizedBox(height: 24),

                    // ─── Denominación ─────────────────────────────
                    _SectionLabel('DENOMINACIÓN'),
                    const SizedBox(height: 10),
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: 10,
                          label: Text('10 Bs'),
                          icon: Icon(Icons.payments_outlined, size: 14),
                        ),
                        ButtonSegment(
                          value: 20,
                          label: Text('20 Bs'),
                          icon: Icon(Icons.payments_outlined, size: 14),
                        ),
                        ButtonSegment(
                          value: 50,
                          label: Text('50 Bs'),
                          icon: Icon(Icons.payments_outlined, size: 14),
                        ),
                      ],
                      selected: {_denomination},
                      onSelectionChanged: (s) {
                        HapticFeedback.selectionClick();
                        setState(() => _denomination = s.first);
                      },
                    ),

                    const SizedBox(height: 28),

                    // ─── Serie ───────────────────────────────────
                    _SectionLabel('NÚMERO DE SERIE'),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _errorText != null
                              ? const Color(0xFFD32F2F)
                              : _focusNode.hasFocus
                                  ? const Color(0xFF1B5E20)
                                  : colors.outlineVariant,
                          width: _focusNode.hasFocus ? 2 : 1,
                        ),
                        boxShadow: _focusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20)
                                      .withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 9,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _onValidatePressed(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B0F),
                        ),
                        decoration: InputDecoration(
                          hintText: '·  ·  ·  ·  ·  ·  ·  ·',
                          hintStyle: TextStyle(
                            fontSize: 22,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w300,
                            color: colors.onSurfaceVariant
                                .withValues(alpha: 0.25),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      size: 18),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 14, color: Color(0xFFD32F2F)),
                          const SizedBox(width: 4),
                          Text(
                            _errorText!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '${_controller.text.length} / 9 dígitos  ·  7–9 caracteres',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // ─── CTA ─────────────────────────────────────
                    AppPrimaryButton(
                      onPressed: _onValidatePressed,
                      icon: Icons.check_circle_outline_rounded,
                      isBusy: _isLoading,
                      label: 'Validar billete',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: colors.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SerialTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF1B5E20).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              size: 18,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Dónde está la serie?',
                  style: textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Es el número de 7 a 9 dígitos impreso en el frente o reverso del billete, generalmente en las esquinas.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
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
