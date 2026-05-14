/// Modelo de usuario (niño registrado en la app).
class Usuario {
  final int? id;
  final String nombre;
  final int grado;        // 0=PreK, 1=Kinder, 2=1ro ... 7=6to
  final int avatarIndice;
  final int monedas;
  final int nivelJugador; // 1-20
  final int rachaActual;  // días consecutivos
  final int rachaMejor;
  final DateTime? ultimoEstudio;
  final DateTime creadoEn;
  final List<String> accesoriosMateo; // accesorios desbloqueados en tienda

  const Usuario({
    this.id,
    required this.nombre,
    required this.grado,
    this.avatarIndice = 0,
    this.monedas = 0,
    this.nivelJugador = 1,
    this.rachaActual = 0,
    this.rachaMejor = 0,
    this.ultimoEstudio,
    required this.creadoEn,
    this.accesoriosMateo = const [],
  });

  // ── Serialización ─────────────────────────────────────────

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      grado: map['grado'] as int,
      avatarIndice: map['avatar_indice'] as int? ?? 0,
      monedas: map['monedas'] as int? ?? 0,
      nivelJugador: map['nivel_jugador'] as int? ?? 1,
      rachaActual: map['racha_actual'] as int? ?? 0,
      rachaMejor: map['racha_mejor'] as int? ?? 0,
      ultimoEstudio: map['ultimo_estudio'] != null
          ? DateTime.tryParse(map['ultimo_estudio'] as String)
          : null,
      creadoEn: DateTime.parse(map['creado_en'] as String),
      accesoriosMateo: map['accesorios_mateo'] != null
          ? (map['accesorios_mateo'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'grado': grado,
      'avatar_indice': avatarIndice,
      'monedas': monedas,
      'nivel_jugador': nivelJugador,
      'racha_actual': rachaActual,
      'racha_mejor': rachaMejor,
      'ultimo_estudio': ultimoEstudio?.toIso8601String(),
      'creado_en': creadoEn.toIso8601String(),
      'accesorios_mateo': accesoriosMateo.join(','),
    };
  }

  // ── Copia con campos modificados ─────────────────────────

  Usuario copyWith({
    int? id,
    String? nombre,
    int? grado,
    int? avatarIndice,
    int? monedas,
    int? nivelJugador,
    int? rachaActual,
    int? rachaMejor,
    DateTime? ultimoEstudio,
    DateTime? creadoEn,
    List<String>? accesoriosMateo,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      grado: grado ?? this.grado,
      avatarIndice: avatarIndice ?? this.avatarIndice,
      monedas: monedas ?? this.monedas,
      nivelJugador: nivelJugador ?? this.nivelJugador,
      rachaActual: rachaActual ?? this.rachaActual,
      rachaMejor: rachaMejor ?? this.rachaMejor,
      ultimoEstudio: ultimoEstudio ?? this.ultimoEstudio,
      creadoEn: creadoEn ?? this.creadoEn,
      accesoriosMateo: accesoriosMateo ?? this.accesoriosMateo,
    );
  }

  // ── Lógica de dominio ─────────────────────────────────────

  /// Nombre del nivel basado en puntos.
  String get nombreNivel {
    if (nivelJugador <= 2)  return 'Principiante';
    if (nivelJugador <= 5)  return 'Explorador';
    if (nivelJugador <= 9)  return 'Matemático';
    if (nivelJugador <= 14) return 'Genio';
    return 'Súper Genio';
  }

  /// Nombre del grado para mostrar en UI.
  String get nombreGrado {
    const nombres = [
      'Pre-Kinder', 'Kinder', '1er Grado', '2do Grado',
      '3er Grado', '4to Grado', '5to Grado', '6to Grado',
    ];
    if (grado >= 0 && grado < nombres.length) return nombres[grado];
    return 'Grado $grado';
  }

  /// Monedas necesarias para el siguiente nivel (curva cuadrática).
  int get monedasParaSiguienteNivel => (nivelJugador * nivelJugador * 50);

  /// Verifica si el usuario estudió hoy para mantener la racha.
  bool get estudioHoy {
    if (ultimoEstudio == null) return false;
    final hoy = DateTime.now();
    return ultimoEstudio!.year == hoy.year &&
        ultimoEstudio!.month == hoy.month &&
        ultimoEstudio!.day == hoy.day;
  }

  @override
  String toString() => 'Usuario(id: $id, nombre: $nombre, grado: $grado)';
}
