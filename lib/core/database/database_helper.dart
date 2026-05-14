import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/usuario.dart';
import '../../models/leccion.dart';
import '../../models/ejercicio.dart';
import '../../models/progreso.dart';
import 'seed_data.dart';

/// Singleton que gestiona la base de datos SQLite local.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instancia = DatabaseHelper._();

  static Database? _db;

  static const _nombreDB = 'math_kids_panama.db';
  static const _versionDB = 1;

  // ── Nombres de tablas ─────────────────────────────────────
  static const tablaUsuarios        = 'usuarios';
  static const tablaLecciones       = 'lecciones';
  static const tablaEjercicios      = 'ejercicios';
  static const tablaProgreso        = 'progreso_usuario';
  static const tablaSesiones        = 'sesiones';
  static const tablaLogros          = 'logros';
  static const tablaLogrosUsuario   = 'logros_usuario';

  // ── Acceso a la base de datos ─────────────────────────────

  Future<Database> get db async {
    _db ??= await _inicializar();
    return _db!;
  }

  Future<Database> _inicializar() async {
    final rutaDB = join(await getDatabasesPath(), _nombreDB);
    return openDatabase(
      rutaDB,
      version: _versionDB,
      onCreate: _crearTablas,
      onConfigure: _configurarPragmas,
    );
  }

  /// Activa foreign keys (SQLite las trae desactivadas por defecto).
  Future<void> _configurarPragmas(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ── DDL — creación de tablas ──────────────────────────────

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaUsuarios (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre          TEXT    NOT NULL,
        grado           INTEGER NOT NULL DEFAULT 0,
        avatar_indice   INTEGER NOT NULL DEFAULT 0,
        monedas         INTEGER NOT NULL DEFAULT 0,
        nivel_jugador   INTEGER NOT NULL DEFAULT 1,
        racha_actual    INTEGER NOT NULL DEFAULT 0,
        racha_mejor     INTEGER NOT NULL DEFAULT 0,
        ultimo_estudio  TEXT,
        creado_en       TEXT    NOT NULL,
        accesorios_mateo TEXT   NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaLecciones (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        grado            INTEGER NOT NULL,
        tema             TEXT    NOT NULL,
        subtema          TEXT    NOT NULL,
        dificultad       INTEGER NOT NULL DEFAULT 1,
        total_ejercicios INTEGER NOT NULL DEFAULT 10,
        orden            INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaEjercicios (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        leccion_id         INTEGER NOT NULL REFERENCES $tablaLecciones(id) ON DELETE CASCADE,
        tipo               INTEGER NOT NULL DEFAULT 0,
        pregunta           TEXT    NOT NULL,
        opciones_json      TEXT    NOT NULL DEFAULT '[]',
        respuesta_correcta TEXT    NOT NULL,
        nivel_dificultad   INTEGER NOT NULL DEFAULT 1,
        imagen_path        TEXT,
        pista              TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaProgreso (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id        INTEGER NOT NULL REFERENCES $tablaUsuarios(id) ON DELETE CASCADE,
        leccion_id        INTEGER NOT NULL REFERENCES $tablaLecciones(id) ON DELETE CASCADE,
        estrellas         INTEGER NOT NULL DEFAULT 0,
        precision_pct     REAL    NOT NULL DEFAULT 0.0,
        intentos          INTEGER NOT NULL DEFAULT 0,
        completada        INTEGER NOT NULL DEFAULT 0,
        fecha_completada  TEXT,
        UNIQUE(usuario_id, leccion_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaSesiones (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id      INTEGER NOT NULL REFERENCES $tablaUsuarios(id) ON DELETE CASCADE,
        fecha           TEXT    NOT NULL,
        duracion_seg    INTEGER NOT NULL DEFAULT 0,
        correctas       INTEGER NOT NULL DEFAULT 0,
        incorrectas     INTEGER NOT NULL DEFAULT 0,
        monedas_ganadas INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaLogros (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre      TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        condicion   TEXT NOT NULL UNIQUE,
        icono_path  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablaLogrosUsuario (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id     INTEGER NOT NULL REFERENCES $tablaUsuarios(id) ON DELETE CASCADE,
        logro_id       INTEGER NOT NULL REFERENCES $tablaLogros(id)   ON DELETE CASCADE,
        fecha_obtenido TEXT    NOT NULL,
        UNIQUE(usuario_id, logro_id)
      )
    ''');

    // Índices para queries frecuentes
    await db.execute(
      'CREATE INDEX idx_ejercicios_leccion ON $tablaEjercicios(leccion_id)',
    );
    await db.execute(
      'CREATE INDEX idx_progreso_usuario ON $tablaProgreso(usuario_id)',
    );
    await db.execute(
      'CREATE INDEX idx_sesiones_usuario_fecha ON $tablaSesiones(usuario_id, fecha)',
    );

    // Datos iniciales
    await SeedData.poblarLecciones(db);
    await SeedData.poblarEjercicios(db);
    await SeedData.poblarLogros(db);
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — USUARIOS
  // ══════════════════════════════════════════════════════════

  Future<int> insertarUsuario(Usuario usuario) async {
    try {
      final database = await db;
      return await database.insert(tablaUsuarios, usuario.toMap());
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  Future<Usuario?> obtenerUsuarioPorId(int id) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaUsuarios,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Usuario.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<List<Usuario>> obtenerTodosLosUsuarios() async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaUsuarios,
        orderBy: 'creado_en ASC',
      );
      return maps.map(Usuario.fromMap).toList();
    } catch (e) {
      throw Exception('Error al listar usuarios: $e');
    }
  }

  Future<int> actualizarUsuario(Usuario usuario) async {
    try {
      final database = await db;
      return await database.update(
        tablaUsuarios,
        usuario.toMap(),
        where: 'id = ?',
        whereArgs: [usuario.id],
      );
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  Future<int> eliminarUsuario(int id) async {
    try {
      final database = await db;
      return await database.delete(
        tablaUsuarios,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — LECCIONES
  // ══════════════════════════════════════════════════════════

  Future<List<Leccion>> obtenerLeccionesPorGrado(int grado) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaLecciones,
        where: 'grado = ?',
        whereArgs: [grado],
        orderBy: 'orden ASC',
      );
      return maps.map(Leccion.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener lecciones: $e');
    }
  }

  Future<Leccion?> obtenerLeccionPorId(int id) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaLecciones,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Leccion.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener lección: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — EJERCICIOS
  // ══════════════════════════════════════════════════════════

  Future<List<Ejercicio>> obtenerEjerciciosPorLeccion(int leccionId) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaEjercicios,
        where: 'leccion_id = ?',
        whereArgs: [leccionId],
      );
      return maps.map(Ejercicio.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener ejercicios: $e');
    }
  }

  /// Obtiene ejercicios filtrados por nivel de dificultad para el motor adaptativo.
  Future<List<Ejercicio>> obtenerEjerciciosPorNivel({
    required int leccionId,
    required int nivelDificultad,
    int limite = 15,
  }) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaEjercicios,
        where: 'leccion_id = ? AND nivel_dificultad = ?',
        whereArgs: [leccionId, nivelDificultad],
        limit: limite,
      );
      return maps.map(Ejercicio.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener ejercicios por nivel: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — PROGRESO
  // ══════════════════════════════════════════════════════════

  Future<void> upsertProgreso(ProgresoLeccion progreso) async {
    try {
      final database = await db;
      await database.insert(
        tablaProgreso,
        progreso.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al guardar progreso: $e');
    }
  }

  Future<ProgresoLeccion?> obtenerProgreso({
    required int usuarioId,
    required int leccionId,
  }) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaProgreso,
        where: 'usuario_id = ? AND leccion_id = ?',
        whereArgs: [usuarioId, leccionId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return ProgresoLeccion.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener progreso: $e');
    }
  }

  Future<List<ProgresoLeccion>> obtenerProgresoDeUsuario(int usuarioId) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaProgreso,
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
      );
      return maps.map(ProgresoLeccion.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener progreso del usuario: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — SESIONES
  // ══════════════════════════════════════════════════════════

  Future<int> insertarSesion(Sesion sesion) async {
    try {
      final database = await db;
      return await database.insert(tablaSesiones, sesion.toMap());
    } catch (e) {
      throw Exception('Error al guardar sesión: $e');
    }
  }

  Future<List<Sesion>> obtenerSesionesPorUsuario(
    int usuarioId, {
    int limite = 30,
  }) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaSesiones,
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'fecha DESC',
        limit: limite,
      );
      return maps.map(Sesion.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener sesiones: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // CRUD — LOGROS
  // ══════════════════════════════════════════════════════════

  Future<List<Logro>> obtenerTodosLosLogros() async {
    try {
      final database = await db;
      final maps = await database.query(tablaLogros);
      return maps.map(Logro.fromMap).toList();
    } catch (e) {
      throw Exception('Error al obtener logros: $e');
    }
  }

  /// Devuelve los IDs de logros que ya tiene el usuario.
  Future<Set<int>> obtenerLogrosDesbloqueados(int usuarioId) async {
    try {
      final database = await db;
      final maps = await database.query(
        tablaLogrosUsuario,
        columns: ['logro_id'],
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
      );
      return maps.map((m) => m['logro_id'] as int).toSet();
    } catch (e) {
      throw Exception('Error al obtener logros desbloqueados: $e');
    }
  }

  Future<void> desbloquearLogro({
    required int usuarioId,
    required int logroId,
  }) async {
    try {
      final database = await db;
      await database.insert(
        tablaLogrosUsuario,
        {
          'usuario_id': usuarioId,
          'logro_id': logroId,
          'fecha_obtenido': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw Exception('Error al desbloquear logro: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // ESTADÍSTICAS AGREGADAS
  // ══════════════════════════════════════════════════════════

  /// Precisión promedio global del usuario (todas las sesiones).
  Future<double> obtenerPrecisionPromedio(int usuarioId) async {
    try {
      final database = await db;
      final result = await database.rawQuery('''
        SELECT
          CAST(SUM(correctas) AS REAL) / NULLIF(SUM(correctas + incorrectas), 0) * 100 AS precision
        FROM $tablaSesiones
        WHERE usuario_id = ?
      ''', [usuarioId]);
      return (result.first['precision'] as double?) ?? 0.0;
    } catch (e) {
      throw Exception('Error al calcular precisión: $e');
    }
  }

  /// Tiempo total estudiado en segundos.
  Future<int> obtenerTiempoTotalEstudiado(int usuarioId) async {
    try {
      final database = await db;
      final result = await database.rawQuery('''
        SELECT COALESCE(SUM(duracion_seg), 0) AS total
        FROM $tablaSesiones
        WHERE usuario_id = ?
      ''', [usuarioId]);
      return (result.first['total'] as int?) ?? 0;
    } catch (e) {
      throw Exception('Error al calcular tiempo total: $e');
    }
  }

  /// Cierra la base de datos (útil en tests).
  Future<void> cerrar() async {
    final database = _db;
    if (database != null) {
      await database.close();
      _db = null;
    }
  }
}
