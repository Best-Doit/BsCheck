import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../validation/presentation/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) return;
    setState(() {
      _isFinishing = true;
    });

    final box = await Hive.openBox('bscheck_prefs');
    await box.put('seen_onboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _nextPage() {
    if (_isFinishing) return;
    if (_currentPage == 2) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final pages = [
      _OnboardingScreen(
        icon: Icons.offline_bolt_rounded,
        title: 'Verificación offline',
        description:
            'BsCheck valida billetes bolivianos sin conexión a internet, ideal para mercados, comercios y ventas en calle.',
      ),
      _OnboardingScreen(
        icon: Icons.document_scanner_rounded,
        title: 'Escanéa o ingresa la serie',
        description:
            'Puedes usar la cámara con OCR para leer la serie del billete o escribirla manualmente en segundos.',
      ),
      _OnboardingScreen(
        icon: Icons.verified_user_rounded,
        title: 'Proyecto de Best-Doit',
        description:
            'Esta app NO es oficial del Banco Central de Bolivia. Es una contribución abierta de la comunidad (Best-Doit).',
        showSocial: true,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primaryContainer, const Color(0xFFF4FAF6)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _isFinishing ? null : _finishOnboarding,
                    child: const Text('Saltar'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) => pages[index],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? colors.primary
                            : colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: FilledButton(
                    onPressed: _isFinishing ? null : _nextPage,
                    child: Text(
                      _isFinishing
                          ? 'Cargando...'
                          : (_currentPage == pages.length - 1
                                ? 'Empezar'
                                : 'Siguiente'),
                    ),
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

class _OnboardingScreen extends StatelessWidget {
  const _OnboardingScreen({
    required this.icon,
    required this.title,
    required this.description,
    this.showSocial = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showSocial;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 106,
            height: 106,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, size: 56, color: colors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
          ),
          if (showSocial) ...[
            const SizedBox(height: 32),
            Text(
              'Sígueme en TikTok para más proyectos:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: colors.secondary),
            ),
          ],
        ],
      ),
    );
  }
}
