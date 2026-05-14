/// Modelo de lección. Cada lección agrupa ejercicios de un subtema.
class Leccion {
  final int? id;
  final int grado;          // 0=PreK … 7=6to
  final String tema;        // "Suma y resta"
  final String subtema;     // "Suma hasta 20"
  final int dificultad;     // 1=fácil, 2=medio, 3=difícil
  final int totalEjercicios;
  final int orden;          // orden dentro del grado para el mapa

  const Leccion({
    this.id,
    required this.grado,
    required this.tema,
    required this.subtema,
    required this.dificultad,
    required this.totalEjercicios,
    required this.orden,
  });

  factory Leccion.fromMap(Map<String, dynamic> map) {
    return Leccion(
      id: map['id'] as int?,
      grado: map['grado'] as int,
      tema: map['tema'] as String,
      subtema: map['subtema'] as String,
      dificultad: map['dificultad'] as int,
      totalEjercicios: map['total_ejercicios'] as int,
      orden: map['orden'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'grado': grado,
      'tema': tema,
      'subtema': subtema,
      'dificultad': dificultad,
      'total_ejercicios': totalEjercicios,
      'orden': orden,
    };
  }

  /// Etiqueta de dificultad para UI.
  String get etiquetaDificultad {
    switch (dificultad) {
      case 1: return 'Fácil';
      case 2: return 'Medio';
      case 3: return 'Difícil';
      default: return 'Normal';
    }
  }

  @override
  String toString() => 'Leccion(id: $id, grado: $grado, subtema: $subtema)';
}
