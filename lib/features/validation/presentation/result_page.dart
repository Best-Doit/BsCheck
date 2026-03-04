import 'package:flutter/material.dart';

import '../../../presentation/widgets/app_button.dart';
import '../../validation/domain/entities/validation_result.dart';

class ResultPage extends StatefulWidget {
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
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (
      heroColor,
      heroBg,
      iconData,
      statusLabel,
      description,
    ) = switch (widget.result.status) {
      ValidationStatus.disabled => (
        const Color(0xFFD32F2F),
        const Color(0xFFFFF0F0),
        Icons.cancel_rounded,
        'INHABILITADO',
        'Este billete pertenece a un rango de series inhabilitadas por el Banco Central de Bolivia.',
      ),
      ValidationStatus.valid => (
        const Color(0xFF1B5E20),
        const Color(0xFFF0FFF4),
        Icons.check_circle_rounded,
        'VÁLIDO',
        'La serie no se encuentra en los rangos de billetes inhabilitados conocidos.',
      ),
      ValidationStatus.notRecognized => (
        const Color(0xFF5D4037),
        const Color(0xFFFFF8F0),
        Icons.help_rounded,
        'NO RECONOCIDO',
        'No fue posible interpretar la serie. Ingresa los dígitos manualmente para verificar.',
      ),
    };

    return Scaffold(
      backgroundColor: heroBg,
      appBar: AppBar(
        backgroundColor: heroBg,
        foregroundColor: heroColor,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: heroColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Resultado',
          style: TextStyle(color: heroColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Hero ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: heroColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 48, color: heroColor),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: heroColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: heroColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: heroColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        switch (widget.result.status) {
                          ValidationStatus.disabled => 'Billete inhabilitado',
                          ValidationStatus.valid => 'Billete válido',
                          ValidationStatus.notRecognized => 'No reconocido',
                        },
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          color: heroColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: heroColor.withValues(alpha: 0.75),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Detalle ──────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Detalle de verificación',
                              style: textTheme.titleLarge),
                          const SizedBox(height: 20),
                          _DetailRow(
                            icon: Icons.tag_rounded,
                            label: 'Serie',
                            value: widget.result.serial.isEmpty
                                ? '—'
                                : widget.result.serial,
                            highlight: true,
                            highlightColor: heroColor,
                          ),
                          const _Divider(),
                          _DetailRow(
                            icon: Icons.payments_outlined,
                            label: 'Denominación',
                            value: '${widget.denomination} Bolivianos',
                          ),
                          const _Divider(),
                          _DetailRow(
                            icon: Icons.sort_by_alpha_rounded,
                            label: 'Serie letra',
                            value: widget.series,
                          ),
                          const SizedBox(height: 32),
                          AppPrimaryButton(
                            onPressed: () => Navigator.of(context).pop(),
                            label: 'Nueva verificación',
                            icon: Icons.refresh_rounded,
                          ),
                          const SizedBox(height: 12),
                          AppSecondaryButton(
                            onPressed: () => Navigator.of(context).pop(),
                            label: 'Volver al inicio',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (highlightColor ?? colors.primary).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: highlightColor ?? colors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleMedium?.copyWith(
                    color: highlight
                        ? highlightColor
                        : colors.onSurface,
                    fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                    fontSize: highlight ? 18 : 15,
                    letterSpacing: highlight ? 1.2 : 0,
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

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      color: colors.outlineVariant.withValues(alpha: 0.4),
    );
  }
}
