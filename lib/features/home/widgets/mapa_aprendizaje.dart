import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colores.dart';
import '../../../core/constants/estilos_texto.dart';
import '../../../models/leccion.dart';
import '../../../models/progreso.dart';
import '../../../app/routes.dart';
import '../../../widgets/barra_progreso.dart';

/// Mapa visual de aprendizaje: burbujas conectadas en zigzag.
/// Cada burbuja representa una lección. Al completarse se ilumina.
class MapaAprendizaje extends StatelessWidget {
  final List<Leccion> lecciones;
  final Map<int, ProgresoLeccion> mapaProgreso;
  final int grado;

  const MapaAprendizaje({
    super.key,
    required this.lecciones,
    required this.mapaProgreso,
    required this.grado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(lecciones.length, (index) {
        final leccion = lecciones[index];
        final progreso = mapaProgreso[leccion.id];
        final completada = progreso?.completada ?? false;
        final estrellas = progreso?.estrellas ?? 0;

        // Determinar si está desbloqueada
        // La primera lección siempre está desbloqueada.
        // Las siguientes se desbloquean cuando la anterior está completada.
        final desbloqueada = index == 0 ||
            (mapaProgreso[lecciones[index - 1].id]?.completada ?? false);

        return _NodoLeccion(
          leccion: leccion,
          indice: index,
          completada: completada,
          desbloqueada: desbloqueada,
          estrellas: estrellas,
          esUltima: index == lecciones.length - 1,
          colorGrado: AppColores.coloresPorGrado[grado] ?? AppColores.azulCielo,
          alPresionar: desbloqueada
              ? () => context.push('/ejercicio/${leccion.id}')
              : null,
        );
      }),
    );
  }
}

class _NodoLeccion extends StatelessWidget {
  final Leccion leccion;
  final int indice;
  final bool completada;
  final bool desbloqueada;
  final int estrellas;
  final bool esUltima;
  final Color colorGrado;
  final VoidCallback? alPresionar;

  const _NodoLeccion({
    required this.leccion,
    required this.indice,
    required this.completada,
    required this.desbloqueada,
    required this.estrellas,
    required this.esUltima,
    required this.colorGrado,
    this.alPresionar,
  });

  // Alterna izquierda/derecha para efecto zigzag
  bool get _esDerecha => indice.isEven;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Conector vertical (excepto el primero) ────────────
        if (indice > 0)
          Padding(
            padding: EdgeInsets.only(
              left: _esDerecha ? 0 : 60,
              right: _esDerecha ? 60 : 0,
            ),
            child: Container(
              height: 32,
              width: 4,
              decoration: BoxDecoration(
                color: completada
                    ? colorGrado
                    : AppColores.grisMedio.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

        // ── Nodo de lección ───────────────────────────────────
        Row(
          mainAxisAlignment: _esDerecha
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: alPresionar,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.75,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: completada
                      ? colorGrado.withOpacity(0.12)
                      : desbloqueada
                          ? Colors.white
                          : AppColores.grisClaro,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: completada
                        ? colorGrado
                        : desbloqueada
                            ? colorGrado.withOpacity(0.3)
                            : AppColores.grisMedio.withOpacity(0.4),
                    width: completada ? 2.5 : 1.5,
                  ),
                  boxShadow: desbloqueada
                      ? [
                          BoxShadow(
                            color: colorGrado.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // ── Círculo indicador ─────────────────────
                    _CirculoIndicador(
                      completada: completada,
                      desbloqueada: desbloqueada,
                      color: colorGrado,
                      numero: indice + 1,
                    ),
                    const SizedBox(width: 14),
                    // ── Info de la lección ────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leccion.subtema,
                            style: AppTextos.tituloTarjeta.copyWith(
                              color: desbloqueada
                                  ? AppColores.negro
                                  : AppColores.grisMedio,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            leccion.tema,
                            style: AppTextos.cuerpoChico.copyWith(
                              color: desbloqueada
                                  ? AppColores.grisOscuro
                                  : AppColores.grisMedio,
                            ),
                          ),
                          if (completada) ...[
                            const SizedBox(height: 6),
                            IndicadorEstrellas(estrellas: estrellas, tamano: 20),
                          ],
                          if (desbloqueada && !completada) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorGrado.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '¡Lista para jugar!',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorGrado,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ── Icono de estado ───────────────────────
                    if (!desbloqueada)
                      const Icon(Icons.lock, color: AppColores.grisMedio, size: 22)
                    else if (completada)
                      Icon(Icons.check_circle, color: colorGrado, size: 28)
                    else
                      Icon(Icons.play_circle_fill, color: colorGrado, size: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CirculoIndicador extends StatelessWidget {
  final bool completada;
  final bool desbloqueada;
  final Color color;
  final int numero;

  const _CirculoIndicador({
    required this.completada,
    required this.desbloqueada,
    required this.color,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completada
            ? color
            : desbloqueada
                ? color.withOpacity(0.15)
                : AppColores.grisMedio.withOpacity(0.2),
        border: Border.all(
          color: desbloqueada ? color : AppColores.grisMedio.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Center(
        child: completada
            ? const Icon(Icons.star, color: Colors.white, size: 24)
            : Text(
                '$numero',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: desbloqueada ? color : AppColores.grisMedio,
                ),
              ),
      ),
    );
  }
}
