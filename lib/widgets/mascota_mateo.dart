import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../core/constants/assets.dart';
import '../core/constants/colores.dart';
import '../core/constants/estilos_texto.dart';
import '../core/utils/audio_service.dart';

/// Estado emocional de Mateo el búho.
enum EstadoMateo {
  feliz,
  triste,
  sorprendido,
  celebrando,
  durmiendo,
  hablando,
}

/// Widget de la mascota Mateo que reacciona a las acciones del niño.
/// Muestra animación Lottie + burbuja de diálogo opcional.
class MascotaMateo extends StatefulWidget {
  final EstadoMateo estado;
  final String? mensaje;        // burbuja de diálogo (null = sin burbuja)
  final double tamano;
  final bool narrarMensaje;     // si true, TTS lee el mensaje
  final VoidCallback? alTocar;  // callback cuando el niño toca a Mateo

  const MascotaMateo({
    super.key,
    this.estado = EstadoMateo.feliz,
    this.mensaje,
    this.tamano = 150,
    this.narrarMensaje = false,
    this.alTocar,
  });

  @override
  State<MascotaMateo> createState() => _MascotaMateoState();
}

class _MascotaMateoState extends State<MascotaMateo>
    with TickerProviderStateMixin {
  late AnimationController _burbujaController;
  late Animation<double> _burbujaAnimation;

  @override
  void initState() {
    super.initState();
    _burbujaController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _burbujaAnimation = CurvedAnimation(
      parent: _burbujaController,
      curve: Curves.elasticOut,
    );
    if (widget.mensaje != null) {
      _burbujaController.forward();
      if (widget.narrarMensaje) {
        _narrar();
      }
    }
  }

  @override
  void didUpdateWidget(MascotaMateo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mensaje != oldWidget.mensaje) {
      if (widget.mensaje != null) {
        _burbujaController.forward(from: 0);
        if (widget.narrarMensaje) _narrar();
      } else {
        _burbujaController.reverse();
      }
    }
  }

  void _narrar() {
    if (widget.mensaje != null) {
      AudioService.instancia.narrar(widget.mensaje!);
    }
  }

  @override
  void dispose() {
    _burbujaController.dispose();
    super.dispose();
  }

  // ── Mapeo estado → archivo Lottie ────────────────────────

  String get _animacionPath {
    switch (widget.estado) {
      case EstadoMateo.feliz:       return AppAssets.mateoFeliz;
      case EstadoMateo.triste:      return AppAssets.mateoTriste;
      case EstadoMateo.sorprendido: return AppAssets.mateoSorprendido;
      case EstadoMateo.celebrando:  return AppAssets.mateoCelebrando;
      case EstadoMateo.durmiendo:   return AppAssets.mateoDurmiendo;
      case EstadoMateo.hablando:    return AppAssets.mateoHablando;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.alTocar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Burbuja de diálogo ────────────────────────────
          if (widget.mensaje != null)
            ScaleTransition(
              scale: _burbujaAnimation,
              child: _BurbujaDialogo(mensaje: widget.mensaje!),
            ),

          if (widget.mensaje != null)
            const SizedBox(height: 8),

          // ── Mateo animado ─────────────────────────────────
          SizedBox(
            width: widget.tamano,
            height: widget.tamano,
            child: _AnimacionMateo(
              path: _animacionPath,
              estado: widget.estado,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subwidget: animación Lottie con fallback ──────────────

class _AnimacionMateo extends StatelessWidget {
  final String path;
  final EstadoMateo estado;

  const _AnimacionMateo({required this.path, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      fit: BoxFit.contain,
      repeat: _debeRepetir,
      errorBuilder: (_, __, ___) => _FallbackMateo(estado: estado),
    );
  }

  bool get _debeRepetir =>
      estado == EstadoMateo.feliz ||
      estado == EstadoMateo.durmiendo ||
      estado == EstadoMateo.hablando;
}

// ── Subwidget: fallback si no existe el archivo Lottie ────

class _FallbackMateo extends StatelessWidget {
  final EstadoMateo estado;
  const _FallbackMateo({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColores.azulCielo.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _emoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  String get _emoji {
    switch (estado) {
      case EstadoMateo.feliz:       return '🦉';
      case EstadoMateo.triste:      return '😢';
      case EstadoMateo.sorprendido: return '😲';
      case EstadoMateo.celebrando:  return '🎉';
      case EstadoMateo.durmiendo:   return '😴';
      case EstadoMateo.hablando:    return '🗣️';
    }
  }
}

// ── Subwidget: burbuja de diálogo ─────────────────────────

class _BurbujaDialogo extends StatelessWidget {
  final String mensaje;
  const _BurbujaDialogo({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColores.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColores.azulCielo.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        mensaje,
        style: AppTextos.burbujaMateo,
        textAlign: TextAlign.center,
      ),
    );
  }
}
