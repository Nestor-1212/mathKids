import 'package:sqflite/sqflite.dart';
import '../constants/assets.dart';

/// Datos iniciales: lecciones del currículo MEDUCA, ejercicios de muestra y logros.
class SeedData {
  SeedData._();

  // ══════════════════════════════════════════════════════════
  // LECCIONES — currículo MEDUCA alineado por grado
  // ══════════════════════════════════════════════════════════

  static Future<void> poblarLecciones(Database db) async {
    final lecciones = [
      // ── Pre-Kinder (grado 0) ──────────────────────────────
      _l(0, 'Números', 'Contar del 1 al 5',       1, 10, 1),
      _l(0, 'Números', 'Contar del 1 al 10',       1, 10, 2),
      _l(0, 'Números', 'Reconocer números del 1-5', 1, 10, 3),
      _l(0, 'Formas',  'Figuras geométricas básicas', 1, 8, 4),
      _l(0, 'Comparar','Más o menos (conceptual)',  1, 8, 5),

      // ── Kinder (grado 1) ─────────────────────────────────
      _l(1, 'Números', 'Contar del 1 al 20',        1, 12, 1),
      _l(1, 'Suma',    'Suma hasta 10',              1, 15, 2),
      _l(1, 'Patrones','Patrones simples AB-AB',     1, 10, 3),
      _l(1, 'Comparar','Comparar cantidades',        1, 10, 4),

      // ── 1er Grado (grado 2) ───────────────────────────────
      _l(2, 'Suma y Resta', 'Suma hasta 20',         1, 15, 1),
      _l(2, 'Suma y Resta', 'Resta hasta 20',        2, 15, 2),
      _l(2, 'Valor Posicional', 'Decenas y unidades',1, 12, 3),
      _l(2, 'Medición', 'Largo y corto',             1, 10, 4),
      _l(2, 'Formas',   'Figuras 2D y 3D',           1, 10, 5),

      // ── 2do Grado (grado 3) ───────────────────────────────
      _l(3, 'Suma y Resta', 'Suma hasta 100',        2, 15, 1),
      _l(3, 'Suma y Resta', 'Resta hasta 100',       2, 15, 2),
      _l(3, 'Multiplicación', 'Grupos iguales',      1, 12, 3),
      _l(3, 'Fracciones', 'Mitad y cuarto',          1, 10, 4),
      _l(3, 'Tiempo', 'Horas y medias horas',        2, 12, 5),

      // ── 3er Grado (grado 4) ───────────────────────────────
      _l(4, 'Multiplicación', 'Tablas del 1 al 5',   2, 20, 1),
      _l(4, 'Multiplicación', 'Tablas del 6 al 10',  3, 20, 2),
      _l(4, 'División',       'División básica',      2, 15, 3),
      _l(4, 'Fracciones',     'Numerador y denominador', 2, 12, 4),
      _l(4, 'Geometría',      'Perímetro',            2, 10, 5),

      // ── 4to Grado (grado 5) ───────────────────────────────
      _l(5, 'Multiplicación', 'Multiplicación de 2 dígitos', 3, 15, 1),
      _l(5, 'División',       'División con residuo',         3, 15, 2),
      _l(5, 'Decimales',      'Décimas y centésimas',        2, 12, 3),
      _l(5, 'Geometría',      'Área y perímetro',            3, 12, 4),

      // ── 5to Grado (grado 6) ───────────────────────────────
      _l(6, 'Fracciones',   'Suma y resta de fracciones',    3, 15, 1),
      _l(6, 'Fracciones',   'Multiplicación de fracciones',  3, 15, 2),
      _l(6, 'Porcentajes',  'Porcentajes básicos',           2, 12, 3),
      _l(6, 'Geometría',    'Ángulos y triángulos',          3, 12, 4),
      _l(6, 'Estadística',  'Leer gráficas',                 2, 10, 5),

      // ── 6to Grado (grado 7) ───────────────────────────────
      _l(7, 'Enteros',       'Números negativos',            3, 12, 1),
      _l(7, 'Proporciones',  'Razones y proporciones',       3, 15, 2),
      _l(7, 'Álgebra',       'Ecuaciones simples (x + a = b)',3, 12, 3),
      _l(7, 'Probabilidad',  'Probabilidad básica',          3, 10, 4),
    ];

    final batch = db.batch();
    for (final l in lecciones) {
      batch.insert('lecciones', l);
    }
    await batch.commit(noResult: true);
  }

  static Map<String, dynamic> _l(
    int grado,
    String tema,
    String subtema,
    int dificultad,
    int totalEjercicios,
    int orden,
  ) {
    return {
      'grado': grado,
      'tema': tema,
      'subtema': subtema,
      'dificultad': dificultad,
      'total_ejercicios': totalEjercicios,
      'orden': orden,
    };
  }

  // ══════════════════════════════════════════════════════════
  // EJERCICIOS — muestra representativa por grado
  // Los ejercicios reales se generan dinámicamente en AdaptiveEngine,
  // pero aquí poblamos un set base de 10-15 por lección.
  // ══════════════════════════════════════════════════════════

  static Future<void> poblarEjercicios(Database db) async {
    // Recuperamos el ID de la primera lección para asociar ejercicios
    // (el seed corre justo después de insertar lecciones, IDs son secuenciales)
    final batch = db.batch();

    // ── Contar del 1 al 5 (leccion_id = 1) ──────────────────
    _agregarEjerciciosConteo(batch, 1);

    // ── Contar del 1 al 10 (leccion_id = 2) ─────────────────
    _agregarEjerciciosConteo10(batch, 2);

    // ── Suma hasta 10 Kinder (leccion_id ~ 7) ────────────────
    _agregarEjerciciosSumaBasica(batch, 7);

    // ── Suma hasta 20 1er grado (leccion_id ~ 10) ────────────
    _agregarEjerciciosSuma20(batch, 10);

    // ── Tablas del 1 al 5 (leccion_id ~ 21) ──────────────────
    _agregarEjerciciosTablas1a5(batch, 21);

    await batch.commit(noResult: true);
  }

  static void _agregarEjerciciosConteo(Batch batch, int leccionId) {
    final ejercicios = [
      _e(leccionId, 0, '¿Cuántos manzanas hay?', ['1','2','3','4'], '3', 1,
          pista: 'Cuenta uno por uno: 1, 2, 3...'),
      _e(leccionId, 0, '¿Cuántos gatos hay?', ['2','3','4','5'], '2', 1,
          pista: 'Cuenta los gatitos.'),
      _e(leccionId, 0, '¿Qué número viene después del 3?', ['2','4','5','1'], '4', 1),
      _e(leccionId, 0, '¿Cuántos perros hay?', ['1','2','3','4'], '4', 1),
      _e(leccionId, 0, '¿Qué número es este?', ['3','4','5','2'], '5', 1),
      _e(leccionId, 1, '5 + ___ = 5', [], '0', 1, pista: 'El número 0 no agrega nada.'),
    ];
    for (final e in ejercicios) {
      batch.insert('ejercicios', e);
    }
  }

  static void _agregarEjerciciosConteo10(Batch batch, int leccionId) {
    for (int i = 1; i <= 10; i++) {
      batch.insert('ejercicios', _e(
        leccionId, 0,
        '¿Qué número es este?',
        _opcionesAleatorias(i, 1, 10),
        '$i',
        1,
      ));
    }
  }

  static void _agregarEjerciciosSumaBasica(Batch batch, int leccionId) {
    final pares = [
      [1,1],[1,2],[2,2],[2,3],[3,3],[1,4],[2,4],[3,4],[4,4],[1,5],
      [2,5],[3,5],[4,5],[0,5],[5,5],
    ];
    for (final p in pares) {
      final a = p[0], b = p[1];
      final res = a + b;
      batch.insert('ejercicios', _e(
        leccionId, 0,
        '$a + $b = ?',
        _opcionesAleatorias(res, 0, 10),
        '$res',
        1,
        pista: 'Cuenta con los dedos: empieza en $a y cuenta $b más.',
      ));
    }
  }

  static void _agregarEjerciciosSuma20(Batch batch, int leccionId) {
    final pares = [
      [5,6],[7,8],[9,9],[6,7],[8,5],[10,5],[9,8],[7,7],[6,9],[10,10],
      [11,3],[12,4],[13,2],[14,1],[15,5],
    ];
    for (final p in pares) {
      final a = p[0], b = p[1];
      final res = a + b;
      batch.insert('ejercicios', _e(
        leccionId, 0,
        '$a + $b = ?',
        _opcionesAleatorias(res, res - 5, res + 5),
        '$res',
        2,
      ));
    }
  }

  static void _agregarEjerciciosTablas1a5(Batch batch, int leccionId) {
    for (int tabla = 1; tabla <= 5; tabla++) {
      for (int factor = 1; factor <= 10; factor++) {
        final res = tabla * factor;
        batch.insert('ejercicios', _e(
          leccionId, 0,
          '$tabla × $factor = ?',
          _opcionesAleatorias(res, 0, 50),
          '$res',
          factor <= 5 ? 2 : 3,
          pista: 'Piensa: $factor grupos de $tabla cosas.',
        ));
      }
    }
  }

  static Map<String, dynamic> _e(
    int leccionId,
    int tipo,
    String pregunta,
    List<String> opciones,
    String respuesta,
    int nivel, {
    String? imagenPath,
    String? pista,
  }) {
    return {
      'leccion_id': leccionId,
      'tipo': tipo,
      'pregunta': pregunta,
      'opciones_json': _encodeOpciones(opciones),
      'respuesta_correcta': respuesta,
      'nivel_dificultad': nivel,
      'imagen_path': imagenPath,
      'pista': pista,
    };
  }

  // Genera 4 opciones incluyendo la correcta, sin duplicados.
  static List<String> _opcionesAleatorias(int correcta, int min, int max) {
    final Set<int> usados = {correcta};
    final List<int> opciones = [correcta];

    // Asegurar que min/max tengan rango suficiente
    final rangoMin = min < 0 ? min : (min < correcta - 5 ? min : (correcta - 5).clamp(0, 9999));
    final rangoMax = (max > correcta + 5) ? max : correcta + 5;

    int intentos = 0;
    while (opciones.length < 4 && intentos < 100) {
      intentos++;
      final candidato = rangoMin + (opciones.length * 2 + intentos) % (rangoMax - rangoMin + 1);
      if (!usados.contains(candidato)) {
        usados.add(candidato);
        opciones.add(candidato);
      }
    }

    opciones.shuffle();
    return opciones.map((n) => '$n').toList();
  }

  static String _encodeOpciones(List<String> opciones) {
    if (opciones.isEmpty) return '[]';
    final items = opciones.map((o) => '"$o"').join(',');
    return '[$items]';
  }

  // ══════════════════════════════════════════════════════════
  // LOGROS
  // ══════════════════════════════════════════════════════════

  static Future<void> poblarLogros(Database db) async {
    final logros = [
      {
        'nombre': '¡Primer día!',
        'descripcion': 'Completaste tu primera lección.',
        'condicion': 'primera_leccion',
        'icono_path': AppAssets.logro1erDia,
      },
      {
        'nombre': 'Racha de 7',
        'descripcion': 'Estudiaste 7 días seguidos. ¡Increíble!',
        'condicion': 'racha_7',
        'icono_path': AppAssets.logro7Racha,
      },
      {
        'nombre': 'Racha de 30',
        'descripcion': '30 días seguidos estudiando. ¡Eres un campeón!',
        'condicion': 'racha_30',
        'icono_path': AppAssets.logro30Racha,
      },
      {
        'nombre': 'Ahorrista',
        'descripcion': 'Acumulaste 100 monedas de oro.',
        'condicion': 'monedas_100',
        'icono_path': AppAssets.logro100Monedas,
      },
      {
        'nombre': 'Rico Rico',
        'descripcion': 'Acumulaste 1000 monedas de oro.',
        'condicion': 'monedas_1000',
        'icono_path': AppAssets.logro1000Monedas,
      },
      {
        'nombre': 'Estudioso',
        'descripcion': 'Completaste 10 lecciones.',
        'condicion': 'lecciones_10',
        'icono_path': AppAssets.logro10Lecciones,
      },
      {
        'nombre': '¡Perfecto!',
        'descripcion': 'Respondiste 10 preguntas seguidas correctas.',
        'condicion': 'racha_correctas_10',
        'icono_path': AppAssets.logroPerfecto,
      },
      {
        'nombre': 'Veloz',
        'descripcion': 'Respondiste correctamente en menos de 5 segundos.',
        'condicion': 'respuesta_rapida',
        'icono_path': AppAssets.logroVelocidad,
      },
    ];

    final batch = db.batch();
    for (final l in logros) {
      batch.insert('logros', l, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
