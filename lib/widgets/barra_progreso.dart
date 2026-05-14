import 'package:flutter/material.dart';
import '../core/constants/colores.dart';

/// Barra de progreso animada para sesiones de ejercicios.
class BarraProgreso extends StatelessWidget {
  final int actual;
  final int total;
  final Color? color;

  const BarraProgreso({
    super.key,
    required this.actual,
    required this.total,
    this.color,
  });

  double get _fraccion => total > 0 ? (actual / total).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final colorBarra = color ?? AppColores.azulCielo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pregunta $actual de $total',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColores.grisOscuro,
              ),
            ),
            Text(
              '${(_fraccion * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorBarra,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _fraccion,
            minHeight: 12,
            backgroundColor: AppColores.grisClaro,
            valueColor: AlwaysStoppedAnimation<Color>(colorBarra),
          ),
        ),
      ],
    );
  }
}

/// Indicador de estrellas (1-3) para resultado de lección.
class IndicadorEstrellas extends StatelessWidget {
  final int estrellas; // 0-3
  final double tamano;

  const IndicadorEstrellas({
    super.key,
    required this.estrellas,
    this.tamano = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final activa = i < estrellas;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            activa ? Icons.star_rounded : Icons.star_outline_rounded,
            color: activa
                ? AppColores.estrellaActiva
                : AppColores.estrellaInactiva,
            size: tamano,
          ),
        );
      }),
    );
  }
}

/// Chip de racha diaria con llama.
class ChipRacha extends StatelessWidget {
  final int dias;

  const ChipRacha({super.key, required this.dias});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColores.gradienteAmarillo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColores.amarillo.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '$dias',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de monedas de oro.
class ChipMonedas extends StatelessWidget {
  final int monedas;

  const ChipMonedas({super.key, required this.monedas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColores.gradienteAmarillo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColores.oro.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🪙', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '$monedas',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
