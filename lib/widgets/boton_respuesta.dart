import 'package:flutter/material.dart';
import '../core/constants/colores.dart';
import '../core/constants/estilos_texto.dart';

/// Estado visual del botón de respuesta.
enum EstadoBoton { normal, correcto, incorrecto, deshabilitado }

/// Botón de respuesta para ejercicios de selección múltiple.
/// Área de toque mínima de 48x48dp (especificación UX infantil).
class BotonRespuesta extends StatefulWidget {
  final String texto;
  final EstadoBoton estado;
  final VoidCallback? alPresionar;
  final Widget? icono;          // imagen/icono opcional para Pre-K/Kinder
  final bool mostrarIcono;

  const BotonRespuesta({
    super.key,
    required this.texto,
    this.estado = EstadoBoton.normal,
    this.alPresionar,
    this.icono,
    this.mostrarIcono = false,
  });

  @override
  State<BotonRespuesta> createState() => _BotonRespuestaState();
}

class _BotonRespuestaState extends State<BotonRespuesta>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _escala;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _escala = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BotonRespuesta oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animación de sacudida cuando es incorrecto
    if (widget.estado == EstadoBoton.incorrecto &&
        oldWidget.estado != EstadoBoton.incorrecto) {
      _animarIncorrecto();
    }
    // Animación de rebote cuando es correcto
    if (widget.estado == EstadoBoton.correcto &&
        oldWidget.estado != EstadoBoton.correcto) {
      _animarCorrecto();
    }
  }

  void _animarIncorrecto() async {
    await _controller.forward();
    await _controller.reverse();
  }

  void _animarCorrecto() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ── Colores según estado ──────────────────────────────────

  Color get _colorFondo {
    switch (widget.estado) {
      case EstadoBoton.normal:       return AppColores.blanco;
      case EstadoBoton.correcto:     return AppColores.verde;
      case EstadoBoton.incorrecto:   return AppColores.rojo;
      case EstadoBoton.deshabilitado: return AppColores.grisClaro;
    }
  }

  Color get _colorTexto {
    switch (widget.estado) {
      case EstadoBoton.normal:        return AppColores.negro;
      case EstadoBoton.correcto:      return AppColores.blanco;
      case EstadoBoton.incorrecto:    return AppColores.blanco;
      case EstadoBoton.deshabilitado: return AppColores.grisMedio;
    }
  }

  Color get _colorBorde {
    switch (widget.estado) {
      case EstadoBoton.normal:        return AppColores.azulCielo.withOpacity(0.4);
      case EstadoBoton.correcto:      return AppColores.verdeOscuro;
      case EstadoBoton.incorrecto:    return AppColores.rojo;
      case EstadoBoton.deshabilitado: return AppColores.grisMedio;
    }
  }

  Widget? get _icono {
    switch (widget.estado) {
      case EstadoBoton.correcto:
        return const Icon(Icons.check_circle, color: Colors.white, size: 28);
      case EstadoBoton.incorrecto:
        return const Icon(Icons.cancel, color: Colors.white, size: 28);
      default:
        return widget.icono;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estaDeshabilitado = widget.estado == EstadoBoton.deshabilitado ||
        widget.estado == EstadoBoton.correcto ||
        widget.estado == EstadoBoton.incorrecto;

    return ScaleTransition(
      scale: _escala,
      child: GestureDetector(
        onTapDown: estaDeshabilitado
            ? null
            : (_) => _controller.forward(),
        onTapUp: estaDeshabilitado
            ? null
            : (_) {
                _controller.reverse();
                widget.alPresionar?.call();
              },
        onTapCancel: estaDeshabilitado
            ? null
            : () => _controller.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(
            minHeight: 64, // > 48dp por UX infantil
            minWidth: double.infinity,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _colorFondo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _colorBorde, width: 2),
            boxShadow: widget.estado == EstadoBoton.normal
                ? [
                    BoxShadow(
                      color: AppColores.azulCielo.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_icono != null && widget.mostrarIcono) ...[
                _icono!,
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  widget.texto,
                  style: AppTextos.opcionRespuesta.copyWith(
                    color: _colorTexto,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_icono != null &&
                  (widget.estado == EstadoBoton.correcto ||
                      widget.estado == EstadoBoton.incorrecto)) ...[
                const SizedBox(width: 12),
                _icono!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
