import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/utils/audio_service.dart';
import '../../models/ejercicio.dart';
import '../../providers/ejercicio_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/leccion_provider.dart';
import '../../widgets/mascota_mateo.dart';
import '../../widgets/boton_respuesta.dart';
import '../../widgets/barra_progreso.dart';
import '../../widgets/confetti_overlay.dart';
import 'widgets/pregunta_completar.dart';

/// Pantalla de ejercicios con motor adaptativo y feedback de Mateo.
class EjercicioScreen extends ConsumerStatefulWidget {
  final int leccionId;
  const EjercicioScreen({super.key, required this.leccionId});

  @override
  ConsumerState<EjercicioScreen> createState() => _EjercicioScreenState();
}

class _EjercicioScreenState extends ConsumerState<EjercicioScreen>
    with TickerProviderStateMixin {
  // ── Estado local de la UI ─────────────────────────────────
  String? _respuestaSeleccionada;
  bool _respondido = false;
  String? _mensajeMateo;
  EstadoMateo _estadoMateo = EstadoMateo.feliz;

  late AnimationController _transicionController;
  late Animation<double> _transicionOpacidad;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  void initState() {
    super.initState();
    _transicionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _transicionOpacidad = CurvedAnimation(
      parent: _transicionController,
      curve: Curves.easeInOut,
    );
    _transicionController.value = 1.0;

    // Iniciar sesión con el motor adaptativo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(motorAdaptativoProvider.notifier).iniciarSesion(widget.leccionId);
    });
  }

  @override
  void dispose() {
    _transicionController.dispose();
    AudioService.instancia.detener();
    super.dispose();
  }

  // ── Lógica de respuesta ───────────────────────────────────

  Future<void> _responder(String respuesta) async {
    if (_respondido) return;

    setState(() {
      _respuestaSeleccionada = respuesta;
      _respondido = true;
    });

    final esCorrecta =
        ref.read(motorAdaptativoProvider.notifier).responder(respuesta);

    if (esCorrecta) {
      setState(() {
        _estadoMateo = EstadoMateo.celebrando;
        _mensajeMateo = null;
      });
      await AudioService.instancia.correcto();
    } else {
      final motor = ref.read(motorAdaptativoProvider).motor;
      final deberPista = motor?.debeDarPista ?? false;

      setState(() {
        _estadoMateo = EstadoMateo.triste;
        _mensajeMateo = deberPista
            ? (motor?.ejercicioActual?.pista ?? '¡Inténtalo de nuevo!')
            : null;
      });
      await AudioService.instancia.incorrecto();
      if (deberPista && motor?.ejercicioActual?.pista != null) {
        await AudioService.instancia.pista(motor!.ejercicioActual!.pista!);
      }
    }

    // Avanzar al siguiente ejercicio después de 1.5 segundos
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) _avanzar();
  }

  Future<void> _avanzar() async {
    final sesionState = ref.read(motorAdaptativoProvider);

    if (sesionState.sesionCompletada) {
      _mostrarResultado();
      return;
    }

    // Transición suave entre preguntas
    await _transicionController.reverse();
    setState(() {
      _respuestaSeleccionada = null;
      _respondido = false;
      _estadoMateo = EstadoMateo.feliz;
      _mensajeMateo = null;
    });
    await _transicionController.forward();

    // Leer la nueva pregunta
    final motor = ref.read(motorAdaptativoProvider).motor;
    final nuevaPregunta = motor?.ejercicioActual?.pregunta;
    if (nuevaPregunta != null) {
      await AudioService.instancia.leerPregunta(nuevaPregunta);
    }
  }

  Future<void> _mostrarResultado() async {
    final resultado = ref.read(motorAdaptativoProvider).resultado;
    if (resultado == null) return;

    // Guardar progreso en la DB
    await ref.read(guardarProgresoProvider).guardar(
          leccionId: widget.leccionId,
          estrellas: resultado.estrellas,
          precisionPct: resultado.precisionPct,
          completada: resultado.precisionPct >= 50,
        );

    // Dar monedas al usuario
    await ref.read(usuarioActivoProvider.notifier).ganarMonedas(resultado.monedasGanadas);
    await ref.read(usuarioActivoProvider.notifier).actualizarRacha();

    if (mounted) {
      _confettiKey.currentState?.lanzar();
      await AudioService.instancia.completarLeccion();
      _mostrarDialogoResultado(resultado);
    }
  }

  void _mostrarDialogoResultado(dynamic resultado) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoResultado(
        correctas: resultado.correctas,
        incorrectas: resultado.incorrectas,
        precisionPct: resultado.precisionPct,
        estrellas: resultado.estrellas,
        monedasGanadas: resultado.monedasGanadas,
        alCerrar: () {
          ref.read(motorAdaptativoProvider.notifier).reiniciar();
          context.pop();
        },
        alReintentar: () {
          ref.read(motorAdaptativoProvider.notifier).reiniciar();
          Navigator.of(context).pop();
          ref
              .read(motorAdaptativoProvider.notifier)
              .iniciarSesion(widget.leccionId);
          setState(() {
            _respuestaSeleccionada = null;
            _respondido = false;
            _estadoMateo = EstadoMateo.feliz;
            _mensajeMateo = null;
          });
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sesionState = ref.watch(motorAdaptativoProvider);
    final motor = sesionState.motor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmarSalida(context),
        ),
      ),
      body: Stack(
        children: [
          // ── Confetti (celebración) ──────────────────────────
          ConfettiOverlay(key: _confettiKey),

          // ── Contenido principal ─────────────────────────────
          if (sesionState.cargando)
            const Center(child: CircularProgressIndicator())
          else if (sesionState.error != null)
            _PantallaError(mensaje: sesionState.error!)
          else if (motor == null || motor.sesionTerminada)
            const SizedBox.shrink()
          else
            FadeTransition(
              opacity: _transicionOpacidad,
              child: _ContenidoEjercicio(
                motor: motor,
                respuestaSeleccionada: _respuestaSeleccionada,
                respondido: _respondido,
                mensajeMateo: _mensajeMateo,
                estadoMateo: _estadoMateo,
                alResponder: _responder,
              ),
            ),
        ],
      ),
    );
  }

  void _confirmarSalida(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Salir del ejercicio?'),
        content: const Text('Perderás el progreso de esta sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(motorAdaptativoProvider.notifier).reiniciar();
              Navigator.pop(context);
              context.pop();
            },
            child: const Text(
              'Salir',
              style: TextStyle(color: AppColores.rojo),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget del contenido del ejercicio ────────────────────

class _ContenidoEjercicio extends StatelessWidget {
  final dynamic motor; // AdaptiveEngine
  final String? respuestaSeleccionada;
  final bool respondido;
  final String? mensajeMateo;
  final EstadoMateo estadoMateo;
  final ValueChanged<String> alResponder;

  const _ContenidoEjercicio({
    required this.motor,
    required this.respuestaSeleccionada,
    required this.respondido,
    required this.mensajeMateo,
    required this.estadoMateo,
    required this.alResponder,
  });

  @override
  Widget build(BuildContext context) {
    final ejercicio = motor.ejercicioActual as Ejercicio?;
    if (ejercicio == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Barra de progreso ─────────────────────────────
            BarraProgreso(
              actual: motor.preguntasRespondidas as int,
              total: motor.preguntasTotal as int,
            ),

            const SizedBox(height: 20),

            // ── Mateo ─────────────────────────────────────────
            MascotaMateo(
              estado: estadoMateo,
              mensaje: mensajeMateo,
              tamano: 110,
            ),

            const SizedBox(height: 16),

            // ── Pregunta ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                ejercicio.pregunta,
                style: AppTextos.pregunta,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // ── Opciones de respuesta ─────────────────────────
            Expanded(
              child: ejercicio.tipo == TipoEjercicio.completarBlanco
                  ? PreguntaCompletar(
                      onSubmit: alResponder,
                      deshabilitado: respondido,
                    )
                  : _OpcionesMultiple(
                      opciones: ejercicio.opciones,
                      respuestaCorrecta: ejercicio.respuestaCorrecta,
                      respuestaSeleccionada: respuestaSeleccionada,
                      respondido: respondido,
                      alSeleccionar: alResponder,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Opciones de selección múltiple ────────────────────────

class _OpcionesMultiple extends StatelessWidget {
  final List<String> opciones;
  final String respuestaCorrecta;
  final String? respuestaSeleccionada;
  final bool respondido;
  final ValueChanged<String> alSeleccionar;

  const _OpcionesMultiple({
    required this.opciones,
    required this.respuestaCorrecta,
    required this.respuestaSeleccionada,
    required this.respondido,
    required this.alSeleccionar,
  });

  EstadoBoton _estadoDeOpcion(String opcion) {
    if (!respondido) return EstadoBoton.normal;
    if (opcion == respuestaCorrecta) return EstadoBoton.correcto;
    if (opcion == respuestaSeleccionada) return EstadoBoton.incorrecto;
    return EstadoBoton.deshabilitado;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: opciones.map((opcion) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BotonRespuesta(
            texto: opcion,
            estado: _estadoDeOpcion(opcion),
            alPresionar: respondido ? null : () => alSeleccionar(opcion),
          ),
        );
      }).toList(),
    );
  }
}

// ── Diálogo de resultado final ────────────────────────────

class _DialogoResultado extends StatelessWidget {
  final int correctas;
  final int incorrectas;
  final double precisionPct;
  final int estrellas;
  final int monedasGanadas;
  final VoidCallback alCerrar;
  final VoidCallback alReintentar;

  const _DialogoResultado({
    required this.correctas,
    required this.incorrectas,
    required this.precisionPct,
    required this.estrellas,
    required this.monedasGanadas,
    required this.alCerrar,
    required this.alReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final aprobado = precisionPct >= 50;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MascotaMateo(
              estado: aprobado ? EstadoMateo.celebrando : EstadoMateo.triste,
              tamano: 130,
            ),
            const SizedBox(height: 16),
            Text(
              aprobado ? '¡Súper bien!' : '¡Sigue practicando!',
              style: AppTextos.tituloSeccion,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            IndicadorEstrellas(estrellas: estrellas),
            const SizedBox(height: 16),
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat('✅ Correctas', '$correctas', AppColores.verde),
                _Stat('❌ Incorrectas', '$incorrectas', AppColores.rojo),
                _Stat('🪙 Monedas', '+$monedasGanadas', AppColores.oro),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: alCerrar,
              child: const Text('Ver mi progreso 🗺️'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: alReintentar,
              child: const Text('Intentar de nuevo 🔄'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;

  const _Stat(this.etiqueta, this.valor, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          etiqueta,
          style: AppTextos.cuerpoChico,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PantallaError extends StatelessWidget {
  final String mensaje;
  const _PantallaError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotaMateo(
              estado: EstadoMateo.triste,
              mensaje: 'Ups, algo salió mal.',
              tamano: 140,
            ),
            const SizedBox(height: 16),
            Text(mensaje, style: AppTextos.cuerpoNormal, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
