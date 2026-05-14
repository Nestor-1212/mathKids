import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ejercicio.dart';
import '../core/database/database_helper.dart';
import '../core/utils/adaptive_engine.dart';
import 'usuario_provider.dart';
import 'leccion_provider.dart';

// ── Ejercicios de una lección ─────────────────────────────

final ejerciciosPorLeccionProvider =
    FutureProvider.family<List<Ejercicio>, int>((ref, leccionId) async {
  return DatabaseHelper.instancia.obtenerEjerciciosPorLeccion(leccionId);
});

// ── Motor adaptativo activo ───────────────────────────────

final motorAdaptativoProvider =
    StateNotifierProvider<MotorAdaptativoNotifier, SesionEjercicioState>(
  (ref) => MotorAdaptativoNotifier(ref),
);

class SesionEjercicioState {
  final AdaptiveEngine? motor;
  final bool cargando;
  final String? error;
  final bool sesionCompletada;
  final ResultadoSesion? resultado;

  const SesionEjercicioState({
    this.motor,
    this.cargando = false,
    this.error,
    this.sesionCompletada = false,
    this.resultado,
  });

  SesionEjercicioState copyWith({
    AdaptiveEngine? motor,
    bool? cargando,
    String? error,
    bool? sesionCompletada,
    ResultadoSesion? resultado,
  }) {
    return SesionEjercicioState(
      motor: motor ?? this.motor,
      cargando: cargando ?? this.cargando,
      error: error,
      sesionCompletada: sesionCompletada ?? this.sesionCompletada,
      resultado: resultado ?? this.resultado,
    );
  }
}

class MotorAdaptativoNotifier extends StateNotifier<SesionEjercicioState> {
  final Ref _ref;

  MotorAdaptativoNotifier(this._ref) : super(const SesionEjercicioState());

  /// Inicia una nueva sesión para la lección seleccionada.
  Future<void> iniciarSesion(int leccionId) async {
    state = const SesionEjercicioState(cargando: true);

    try {
      final ejercicios = await DatabaseHelper.instancia
          .obtenerEjerciciosPorLeccion(leccionId);

      if (ejercicios.isEmpty) {
        state = const SesionEjercicioState(
          error: 'No hay ejercicios disponibles para esta lección.',
        );
        return;
      }

      // Recuperar nivel previo del usuario en esta lección
      final progresoMapa = await _ref.read(mapaProgresoProvider.future);
      final progresoLeccion = progresoMapa[leccionId];

      // Nivel inicial: basado en precisión histórica
      int nivelInicial = 1;
      if (progresoLeccion != null) {
        if (progresoLeccion.precisionPct >= 80) nivelInicial = 3;
        else if (progresoLeccion.precisionPct >= 60) nivelInicial = 2;
      }
      final motor = AdaptiveEngine(
        leccionId: leccionId,
        ejercicios: ejercicios,
        nivelInicial: nivelInicial,
      );

      state = SesionEjercicioState(motor: motor);
    } catch (e) {
      state = SesionEjercicioState(
        error: 'Hubo un problema al cargar los ejercicios.',
      );
    }
  }

  /// Registra la respuesta y calcula si la sesión terminó.
  bool responder(String respuesta) {
    final motor = state.motor;
    if (motor == null) return false;

    final esCorrecta = motor.registrarRespuesta(respuesta);

    if (motor.sesionTerminada) {
      _finalizarSesion(motor);
    } else {
      // Forzar rebuild con el mismo motor (estado interno cambió)
      state = state.copyWith(motor: motor);
    }

    return esCorrecta;
  }

  void _finalizarSesion(AdaptiveEngine motor) {
    final resultado = motor.calcularResultado(nivelAnterior: 1);
    state = SesionEjercicioState(
      motor: motor,
      sesionCompletada: true,
      resultado: resultado,
    );
  }

  void reiniciar() {
    state = const SesionEjercicioState();
  }
}
