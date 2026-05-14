/// Progreso del usuario en una lección específica.
class ProgresoLeccion {
  final int? id;
  final int usuarioId;
  final int leccionId;
  final int estrellas;      // 0-3
  final double precisionPct; // 0.0-100.0
  final int intentos;
  final bool completada;
  final DateTime? fechaCompletada;

  const ProgresoLeccion({
    this.id,
    required this.usuarioId,
    required this.leccionId,
    this.estrellas = 0,
    this.precisionPct = 0.0,
    this.intentos = 0,
    this.completada = false,
    this.fechaCompletada,
  });

  factory ProgresoLeccion.fromMap(Map<String, dynamic> map) {
    return ProgresoLeccion(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      leccionId: map['leccion_id'] as int,
      estrellas: map['estrellas'] as int? ?? 0,
      precisionPct: (map['precision_pct'] as num?)?.toDouble() ?? 0.0,
      intentos: map['intentos'] as int? ?? 0,
      completada: (map['completada'] as int?) == 1,
      fechaCompletada: map['fecha_completada'] != null
          ? DateTime.tryParse(map['fecha_completada'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'leccion_id': leccionId,
      'estrellas': estrellas,
      'precision_pct': precisionPct,
      'intentos': intentos,
      'completada': completada ? 1 : 0,
      'fecha_completada': fechaCompletada?.toIso8601String(),
    };
  }

  ProgresoLeccion copyWith({
    int? id,
    int? usuarioId,
    int? leccionId,
    int? estrellas,
    double? precisionPct,
    int? intentos,
    bool? completada,
    DateTime? fechaCompletada,
  }) {
    return ProgresoLeccion(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      leccionId: leccionId ?? this.leccionId,
      estrellas: estrellas ?? this.estrellas,
      precisionPct: precisionPct ?? this.precisionPct,
      intentos: intentos ?? this.intentos,
      completada: completada ?? this.completada,
      fechaCompletada: fechaCompletada ?? this.fechaCompletada,
    );
  }
}

/// Resumen de una sesión de estudio completa.
class Sesion {
  final int? id;
  final int usuarioId;
  final DateTime fecha;
  final int duracionSeg;
  final int correctas;
  final int incorrectas;
  final int monedasGanadas;

  const Sesion({
    this.id,
    required this.usuarioId,
    required this.fecha,
    required this.duracionSeg,
    required this.correctas,
    required this.incorrectas,
    required this.monedasGanadas,
  });

  int get totalPreguntas => correctas + incorrectas;

  double get precision => totalPreguntas > 0
      ? (correctas / totalPreguntas) * 100
      : 0.0;

  factory Sesion.fromMap(Map<String, dynamic> map) {
    return Sesion(
      id: map['id'] as int?,
      usuarioId: map['usuario_id'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      duracionSeg: map['duracion_seg'] as int,
      correctas: map['correctas'] as int,
      incorrectas: map['incorrectas'] as int,
      monedasGanadas: map['monedas_ganadas'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'fecha': fecha.toIso8601String(),
      'duracion_seg': duracionSeg,
      'correctas': correctas,
      'incorrectas': incorrectas,
      'monedas_ganadas': monedasGanadas,
    };
  }
}

/// Logro desbloqueado por el usuario.
class Logro {
  final int? id;
  final String nombre;
  final String descripcion;
  final String condicion;  // ej: "racha_7", "monedas_100"
  final String iconoPath;

  const Logro({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.condicion,
    required this.iconoPath,
  });

  factory Logro.fromMap(Map<String, dynamic> map) {
    return Logro(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String,
      condicion: map['condicion'] as String,
      iconoPath: map['icono_path'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'condicion': condicion,
      'icono_path': iconoPath,
    };
  }
}
