import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/database/database_helper.dart';
import '../../models/progreso.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/mascota_mateo.dart';

final _logrosProvider = FutureProvider<_LogrosData>((ref) async {
  final usuario = ref.watch(usuarioActivoProvider);
  if (usuario == null) return _LogrosData([], {});

  final todos = await DatabaseHelper.instancia.obtenerTodosLosLogros();
  final desbloqueados =
      await DatabaseHelper.instancia.obtenerLogrosDesbloqueados(usuario.id!);

  return _LogrosData(todos, desbloqueados);
});

class _LogrosData {
  final List<Logro> todos;
  final Set<int> desbloqueados;
  _LogrosData(this.todos, this.desbloqueados);
}

/// Pantalla de logros y recompensas.
class RecompensasScreen extends ConsumerWidget {
  const RecompensasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLogros = ref.watch(_logrosProvider);
    final usuario = ref.watch(usuarioActivoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis logros'),
        backgroundColor: AppColores.naranja,
      ),
      body: asyncLogros.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar logros')),
        data: (data) {
          final desbloqueados =
              data.todos.where((l) => data.desbloqueados.contains(l.id)).toList();
          final bloqueados =
              data.todos.where((l) => !data.desbloqueados.contains(l.id)).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Mateo celebrando ──────────────────────────
                Center(
                  child: MascotaMateo(
                    estado: desbloqueados.isNotEmpty
                        ? EstadoMateo.celebrando
                        : EstadoMateo.hablando,
                    mensaje: desbloqueados.isNotEmpty
                        ? '¡Tienes ${desbloqueados.length} logros!'
                        : '¡Completa lecciones para\ndesbloquear logros!',
                    tamano: 130,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Chip de monedas ───────────────────────────
                if (usuario != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppColores.gradienteAmarillo,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            '${usuario.monedas} monedas',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                if (desbloqueados.isNotEmpty) ...[
                  Text('Logros desbloqueados (${desbloqueados.length})',
                      style: AppTextos.tituloSeccion),
                  const SizedBox(height: 12),
                  ...desbloqueados.map((l) => _TarjetaLogro(
                        logro: l,
                        desbloqueado: true,
                      )),
                  const SizedBox(height: 24),
                ],

                if (bloqueados.isNotEmpty) ...[
                  Text('Por desbloquear (${bloqueados.length})',
                      style: AppTextos.tituloSeccion),
                  const SizedBox(height: 12),
                  ...bloqueados.map((l) => _TarjetaLogro(
                        logro: l,
                        desbloqueado: false,
                      )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaLogro extends StatelessWidget {
  final Logro logro;
  final bool desbloqueado;

  const _TarjetaLogro({required this.logro, required this.desbloqueado});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: desbloqueado
            ? AppColores.amarillo.withOpacity(0.1)
            : AppColores.grisClaro,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: desbloqueado
              ? AppColores.amarillo.withOpacity(0.5)
              : AppColores.grisMedio.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: desbloqueado
                  ? AppColores.amarillo.withOpacity(0.2)
                  : AppColores.grisMedio.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                desbloqueado ? '🏆' : '🔒',
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  logro.nombre,
                  style: AppTextos.tituloTarjeta.copyWith(
                    color: desbloqueado
                        ? AppColores.negro
                        : AppColores.grisMedio,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  logro.descripcion,
                  style: AppTextos.cuerpoChico.copyWith(
                    color: desbloqueado
                        ? AppColores.grisOscuro
                        : AppColores.grisMedio,
                  ),
                ),
              ],
            ),
          ),
          if (desbloqueado)
            const Icon(Icons.check_circle, color: AppColores.verde, size: 26),
        ],
      ),
    );
  }
}
