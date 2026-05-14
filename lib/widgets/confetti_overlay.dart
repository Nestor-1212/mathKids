import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../core/constants/colores.dart';

/// Overlay de confetti para celebración al completar una lección.
/// Uso:
///   final _clave = GlobalKey<ConfettiOverlayState>();
///   ConfettiOverlay(key: _clave)
///   _clave.currentState?.lanzar();
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _controllerCentro;
  late final ConfettiController _controllerIzquierda;
  late final ConfettiController _controllerDerecha;

  @override
  void initState() {
    super.initState();
    _controllerCentro = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controllerIzquierda = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _controllerDerecha = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  /// Lanza el confetti desde 3 puntos simultáneamente.
  void lanzar() {
    _controllerCentro.play();
    _controllerIzquierda.play();
    _controllerDerecha.play();
  }

  void detener() {
    _controllerCentro.stop();
    _controllerIzquierda.stop();
    _controllerDerecha.stop();
  }

  @override
  void dispose() {
    _controllerCentro.dispose();
    _controllerIzquierda.dispose();
    _controllerDerecha.dispose();
    super.dispose();
  }

  static const _colores = [
    AppColores.amarillo,
    AppColores.verde,
    AppColores.azulCielo,
    AppColores.naranja,
    AppColores.morado,
    AppColores.rosado,
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Centro
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _controllerCentro,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 20,
            gravity: 0.3,
            colors: _colores,
          ),
        ),
        // Izquierda
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _controllerIzquierda,
            blastDirection: 0.5, // hacia la derecha
            emissionFrequency: 0.06,
            numberOfParticles: 15,
            gravity: 0.3,
            colors: _colores,
          ),
        ),
        // Derecha
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _controllerDerecha,
            blastDirection: 2.7, // hacia la izquierda
            emissionFrequency: 0.06,
            numberOfParticles: 15,
            gravity: 0.3,
            colors: _colores,
          ),
        ),
      ],
    );
  }
}
