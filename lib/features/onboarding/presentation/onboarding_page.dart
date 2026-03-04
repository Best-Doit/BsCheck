import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../navigation/presentation/main_shell_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  static const _pages = [
    _OnboardingData(
      icon: Icons.volunteer_activism_rounded,
      title: 'A las familias afectadas',
      description:
          'BsCheck expresa sus más sinceras condolencias a todas las familias que sufrieron la tragedia del siniestro aéreo.\n\n'
          'Esta aplicación permite a comerciantes, tiendas de barrio y todas las personas verificar rápidamente series inhabilitadas por el Banco Central de Bolivia, incluso sin acceso a internet.',
      isCondolence: true,
    ),
    _OnboardingData(
      icon: Icons.account_balance_rounded,
      title: 'Serie B · BCB',
      description:
          'Verifica series inhabilitadas de la nueva Serie B según las resoluciones oficiales del Banco Central de Bolivia. Sin internet, sin registro, de forma instantánea.',
    ),
    _OnboardingData(
      icon: Icons.document_scanner_rounded,
      title: 'Escanea o escribe',
      description:
          'Usa la cámara para leer la serie del billete automáticamente con OCR, o ingrésala a mano en segundos.',
    ),
    _OnboardingData(
      icon: Icons.shield_rounded,
      title: 'Datos públicos',
      description:
          'BsCheck NO es oficial del Banco Central de Bolivia. Es un proyecto comunitario de Best-Doit basado en información pública.',
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    final box = await Hive.openBox('bscheck_prefs');
    await box.put('seen_onboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShellPage()),
    );
  }

  void _nextPage() {
    if (_isFinishing) return;
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final safePadding = MediaQuery.of(context).padding;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          // ─── Ilustración + contenido ─────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) =>
                  _OnboardingScreen(data: _pages[index]),
            ),
          ),

          // ─── Controles ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              safePadding.bottom + 24,
            ),
            child: Column(
              children: [
                // Indicadores de página
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? colors.primary
                            : colors.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Botón principal
                FilledButton(
                  onPressed: _isFinishing ? null : _nextPage,
                  child: Text(
                    _isFinishing
                        ? 'Cargando...'
                        : (isLast ? 'Comenzar' : 'Siguiente'),
                  ),
                ),
                const SizedBox(height: 8),
                // Saltar
                if (!isLast)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isFinishing ? null : _finishOnboarding,
                      child: const Text('Omitir'),
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

// Datos de cada slide
class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
    this.isCondolence = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isLast;
  final bool isCondolence;
}

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (data.isCondolence) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con fondo oscuro suave
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1B2F),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(data.icon, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Título en negro profundo
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D1B0F),
              ),
            ),
            const SizedBox(height: 20),
            // Mensaje de condolencias
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono hero
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(data.icon, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          if (data.isLast) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hecho con amor por Best-Doit',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
