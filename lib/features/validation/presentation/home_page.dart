import 'package:flutter/material.dart';

import 'manual_input_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BsCheck'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Verificador de billetes bolivianos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () {
                  // TODO: navegar a pantalla de escaneo (sprint 03).
                },
                child: const Text('Escanear billete'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ManualInputPage(),
                    ),
                  );
                },
                child: const Text('Ingresar serie'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // TODO: navegar a historial (sprint 04).
                },
                child: const Text('Historial'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

