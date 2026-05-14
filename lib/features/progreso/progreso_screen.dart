import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/database/database_helper.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/leccion_provider.dart';
import '../../widgets/barra_progreso.dart';
import '../../widgets/mascota_mateo.dart';

/// Pantalla de estadísticas de progreso del niño.
class ProgresoScreen extends ConsumerWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActivoProvider);
    if (usuario == null) return const SizedBox.shrink();

    final asyncProgreso = ref.watch(progresoUsuarioProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: asyncProgreso.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar progreso')),
        data: (progreso) {
          final completadas = progreso.where((p) => p.completada).length;
          final precisionPromedio = progreso.isNotEmpty
              ? progreso
                      .where((p) => p.completada)
                      .fold(0.0, (s, p) => s + p.precisionPct) /
                  (completadas > 0 ? completadas : 1)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mateo feliz ───────────────────────────────
                Center(
                  child: MascotaMateo(
                    estado: completadas > 0
                        ? EstadoMateo.celebrando
                        : EstadoMateo.hablando,
                    mensaje: completadas > 0
                        ? '¡Vas muy bien, ${ usuario.nombre}!'
                        : '¡Completa lecciones para ver\ntu progreso!',
                    tamano: 130,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Stat cards ────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                      icono: '📚',
                      valor: '$completadas',
                      etiqueta: 'Lecciones\ncompletadas',
                      color: AppColores.azulCielo,
                    ),
                    _StatCard(
                      icono: '🎯',
                      valor: '${precisionPromedio.toStringAsFixed(0)}%',
                      etiqueta: 'Precisión\npromedio',
                      color: AppColores.verde,
                    ),
                    _StatCard(
                      icono: '🔥',
                      valor: '${usuario.rachaActual}',
                      etiqueta: 'Racha\nactual',
                      color: AppColores.naranja,
                    ),
                    _StatCard(
                      icono: '🪙',
                      valor: '${usuario.monedas}',
                      etiqueta: 'Monedas\ntotales',
                      color: AppColores.amarillo,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Nivel del jugador ─────────────────────────
                Text('Nivel de jugador', style: AppTextos.tituloSeccion),
                const SizedBox(height: 12),
                _TarjetaNivel(usuario: usuario),

                const SizedBox(height: 24),

                // ── Récord de racha ───────────────────────────
                if (usuario.rachaMejor > 0) ...[
                  Text('Mejor racha', style: AppTextos.tituloSeccion),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColores.gradienteAmarillo,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Text('🏆', style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${usuario.rachaMejor} días seguidos',
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '¡Tu mejor marca!',
                              style: AppTextos.cuerpoNormal.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icono;
  final String valor;
  final String etiqueta;
  final Color color;

  const _StatCard({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icono, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            etiqueta,
            style: AppTextos.cuerpoChico,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TarjetaNivel extends StatelessWidget {
  final dynamic usuario;
  const _TarjetaNivel({required this.usuario});

  @override
  Widget build(BuildContext context) {
    final nivel = usuario.nivelJugador as int;
    final nombre = usuario.nombreNivel as String;
    final monedasActuales = usuario.monedas as int;
    final monedasSiguiente = usuario.monedasParaSiguienteNivel as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColores.gradienteAzul,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⭐', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Nivel $nivel',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (nivel < 20) ...[
            Text(
              'Faltan ${monedasSiguiente - monedasActuales} monedas para nivel ${nivel + 1}',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: monedasActuales / monedasSiguiente,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColores.amarillo),
              ),
            ),
          ] else
            const Text(
              '¡Nivel máximo alcanzado! 🎉',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColores.amarillo,
              ),
            ),
        ],
      ),
    );
  }
}
