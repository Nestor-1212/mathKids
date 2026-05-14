import '../../models/ejercicio.dart';

/// Resultado de una sesión adaptativa.
class ResultadoSesion {
  final int correctas;
  final int incorrectas;
  final double precisionPct;
  final int nivelFinal;         // 1-5
  final int monedasGanadas;
  final int estrellas;          // 1-3
  final bool subioNivel;
  final bool bajoNivel;

  const ResultadoSesion({
    required this.correctas,
    required this.incorrectas,
    required this.precisionPct,
    required this.nivelFinal,
    required this.monedasGanadas,
    required this.estrellas,
    required this.subioNivel,
    required this.bajoNivel,
  });
}

/// Motor adaptativo de dificultad.
///
/// Reglas:
///   – Comienza con 5 preguntas de diagnóstico en nivel actual.
///   – Precisión > 80 % → sube dificultad.
///   – Precisión 50-80 % → mantiene nivel.
///   – Precisión < 50 % → baja dificultad y refuerza.
///   – Máximo 15 preguntas por sesión.
class AdaptiveEngine {
  // ── Estado de la sesión activa ────────────────────────────

  final int leccionId;
  final List<Ejercicio> _poolEjercicios; // todos los ejercicios disponibles

  int _nivelActual;       // 1-5
  int _correctas   = 0;
  int _incorrectas = 0;
  int _preguntasRespondidas = 0;
  int _rachaCorrectasActual = 0;
  int _fallosConsecutivos   = 0;

  static const _maxPreguntas = 15;
  static const _preguntasDiagnostico = 5;
  static const _umbralAlto  = 0.80; // subir
  static const _umbralBajo  = 0.50; // bajar

  // ── Cola de ejercicios de la sesión ──────────────────────
  final List<Ejercicio> _cola = [];
  int _indiceCola = 0;

  AdaptiveEngine({
    required this.leccionId,
    required List<Ejercicio> ejercicios,
    required int nivelInicial,
  })  : _poolEjercicios = ejercicios,
        _nivelActual = nivelInicial.clamp(1, 5) {
    _construirCola();
  }

  // ── Interfaz pública ──────────────────────────────────────

  /// Ejercicio actual. Null si la sesión terminó.
  Ejercicio? get ejercicioActual {
    if (_indiceCola >= _cola.length) return null;
    return _cola[_indiceCola];
  }

  int get preguntasRespondidas => _preguntasRespondidas;
  int get preguntasTotal => _maxPreguntas;
  int get correctas => _correctas;
  int get incorrectas => _incorrectas;
  int get nivelActual => _nivelActual;
  bool get sesionTerminada => _preguntasRespondidas >= _maxPreguntas ||
      _indiceCola >= _cola.length;

  double get precisionActual => _preguntasRespondidas > 0
      ? _correctas / _preguntasRespondidas
      : 0.0;

  /// ¿Debe Mateo dar una pista? (2 fallos consecutivos).
  bool get debeDarPista => _fallosConsecutivos >= 2;

  /// Registra la respuesta del niño y avanza al siguiente ejercicio.
  /// Devuelve true si fue correcta.
  bool registrarRespuesta(String respuesta) {
    final ejercicio = ejercicioActual;
    if (ejercicio == null || sesionTerminada) return false;

    final esCorrecta = ejercicio.esCorrecta(respuesta);
    _preguntasRespondidas++;
    _indiceCola++;

    if (esCorrecta) {
      _correctas++;
      _rachaCorrectasActual++;
      _fallosConsecutivos = 0;
    } else {
      _incorrectas++;
      _fallosConsecutivos++;
      _rachaCorrectasActual = 0;
    }

    // Ajustar dificultad cada 5 preguntas
    if (_preguntasRespondidas % _preguntasDiagnostico == 0 &&
        !sesionTerminada) {
      _ajustarDificultad();
      _rellenarCola();
    }

    return esCorrecta;
  }

  /// Calcula el resultado final de la sesión.
  ResultadoSesion calcularResultado({required int nivelAnterior}) {
    final precision = precisionActual * 100;
    final subioNivel = _nivelActual > nivelAnterior;
    final bajoNivel  = _nivelActual < nivelAnterior;

    // Monedas: 10 por respuesta correcta + bonus por precisión
    int monedas = _correctas * 10;
    if (precision >= 90) monedas += 50;
    else if (precision >= 80) monedas += 25;
    else if (precision >= 70) monedas += 10;

    // Estrellas según precisión
    int estrellas;
    if (precision >= 90) estrellas = 3;
    else if (precision >= 70) estrellas = 2;
    else if (precision >= 50) estrellas = 1;
    else estrellas = 0;

    return ResultadoSesion(
      correctas: _correctas,
      incorrectas: _incorrectas,
      precisionPct: precision,
      nivelFinal: _nivelActual,
      monedasGanadas: monedas,
      estrellas: estrellas,
      subioNivel: subioNivel,
      bajoNivel: bajoNivel,
    );
  }

  // ── Lógica interna ────────────────────────────────────────

  void _ajustarDificultad() {
    final precision = precisionActual;

    if (precision > _umbralAlto && _nivelActual < 5) {
      _nivelActual++;
    } else if (precision < _umbralBajo && _nivelActual > 1) {
      _nivelActual--;
    }
  }

  void _construirCola() {
    _cola.clear();
    _indiceCola = 0;
    final ejerciciosNivel = _filtrarPorNivel(_nivelActual);
    _cola.addAll(_tomarAleatorios(ejerciciosNivel, _preguntasDiagnostico));
  }

  void _rellenarCola() {
    final restantes = _maxPreguntas - _preguntasRespondidas;
    if (restantes <= 0) return;

    final ejerciciosNivel = _filtrarPorNivel(_nivelActual);
    final yaEnCola = _cola.map((e) => e.id).toSet();
    final candidatos = ejerciciosNivel
        .where((e) => !yaEnCola.contains(e.id))
        .toList();

    final aAgregar = _tomarAleatorios(
      candidatos.isNotEmpty ? candidatos : ejerciciosNivel,
      restantes.clamp(1, _preguntasDiagnostico),
    );
    _cola.addAll(aAgregar);
  }

  List<Ejercicio> _filtrarPorNivel(int nivel) {
    final resultado = _poolEjercicios
        .where((e) => e.nivelDificultad == nivel)
        .toList();
    // Si no hay en ese nivel exacto, usar los más cercanos
    if (resultado.isEmpty) {
      return _poolEjercicios.isNotEmpty ? _poolEjercicios : [];
    }
    return resultado;
  }

  List<Ejercicio> _tomarAleatorios(List<Ejercicio> fuente, int cantidad) {
    if (fuente.isEmpty) return [];
    final copia = List<Ejercicio>.from(fuente)..shuffle();
    return copia.take(cantidad.clamp(1, fuente.length)).toList();
  }
}
