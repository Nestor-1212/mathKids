import 'dart:convert';

/// Tipos de ejercicio disponibles en el motor.
enum TipoEjercicio {
  seleccionMultiple,  // 4 opciones con texto/ícono
  completarBlanco,    // teclado numérico
  arrastrarSoltar,    // drag & drop
  contarObjetos,      // contar objetos en pantalla (PreK / Kinder)
  problemaTexto,      // problema de palabra con ilustración (3°-6°)
}

/// Modelo de ejercicio individual.
class Ejercicio {
  final int? id;
  final int leccionId;
  final TipoEjercicio tipo;
  final String pregunta;
  final List<String> opciones;      // vacío si no aplica
  final String respuestaCorrecta;   // siempre String para unificar
  final int nivelDificultad;        // 1-5 (granular para motor adaptativo)
  final String? imagenPath;         // ruta en assets (opcional)
  final String? pista;              // pista que da Mateo al 2do fallo

  const Ejercicio({
    this.id,
    required this.leccionId,
    required this.tipo,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrecta,
    required this.nivelDificultad,
    this.imagenPath,
    this.pista,
  });

  factory Ejercicio.fromMap(Map<String, dynamic> map) {
    final opcionesJson = map['opciones_json'];
    final List<String> opciones = opcionesJson != null && opcionesJson.toString().isNotEmpty
        ? List<String>.from(json.decode(opcionesJson.toString()))
        : [];

    return Ejercicio(
      id: map['id'] as int?,
      leccionId: map['leccion_id'] as int,
      tipo: TipoEjercicio.values[map['tipo'] as int],
      pregunta: map['pregunta'] as String,
      opciones: opciones,
      respuestaCorrecta: map['respuesta_correcta'] as String,
      nivelDificultad: map['nivel_dificultad'] as int,
      imagenPath: map['imagen_path'] as String?,
      pista: map['pista'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'leccion_id': leccionId,
      'tipo': tipo.index,
      'pregunta': pregunta,
      'opciones_json': json.encode(opciones),
      'respuesta_correcta': respuestaCorrecta,
      'nivel_dificultad': nivelDificultad,
      'imagen_path': imagenPath,
      'pista': pista,
    };
  }

  /// Verifica si la respuesta del niño es correcta (ignora mayúsculas/espacios).
  bool esCorrecta(String respuestaUsuario) {
    return respuestaUsuario.trim().toLowerCase() ==
        respuestaCorrecta.trim().toLowerCase();
  }

  @override
  String toString() => 'Ejercicio(id: $id, tipo: $tipo, pregunta: $pregunta)';
}
