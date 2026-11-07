import 'package:flutter/material.dart';

import 'app.dart';
import 'data/feed_repository.dart';
import 'state/feed_controller.dart';

/// Inicia la interfaz ANTES de leer el almacenamiento local.
/// Si el navegador bloquea la lectura, se muestra el motivo en pantalla
/// en vez de quedar una pantalla blanca indefinidamente.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = FeedController(LocalJsonFeedRepository());
  runApp(_CasetaProStartup(controller: controller));
}

class _CasetaProStartup extends StatefulWidget {
  const _CasetaProStartup({required this.controller});

  final FeedController controller;

  @override
  State<_CasetaProStartup> createState() => _CasetaProStartupState();
}

class _CasetaProStartupState extends State<_CasetaProStartup> {
  late Future<void> _load;

  @override
  void initState() {
    super.initState();
    _load = _readLocalData();
  }

  Future<void> _readLocalData() =>
      widget.controller.load().timeout(const Duration(seconds: 12));

  void _retry() {
    setState(() {
      _load = _readLocalData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return CasetaProApp(controller: widget.controller);
        }

        final failed = snapshot.hasError;
        return MaterialApp(
          title: 'CasetaPro',
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFFF2F7FB),
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        failed ? Icons.error_outline : Icons.waves_rounded,
                        color: const Color(0xFF1679B8),
                        size: 48,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'CasetaPro',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF102E51),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!failed) ...[
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        const Text('Abriendo los registros locales...'),
                      ] else ...[
                        const Text(
                          'No fue posible leer los registros guardados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No se han borrado ni sobrescrito tus registros.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
