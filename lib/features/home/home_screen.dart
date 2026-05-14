import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../models/leccion.dart';
import '../../models/progreso.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/leccion_provider.dart';
import '../../app/routes.dart';
import '../../widgets/barra_progreso.dart';
import '../../widgets/mascota_mateo.dart';
import 'widgets/mapa_aprendizaje.dart';

/// Pantalla principal (home) con el mapa de aprendizaje del grado del niño.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActivoProvider);

    if (usuario == null) return const SizedBox.shrink();

    final asyncLecciones = ref.watch(
      leccionesPorGradoProvider(usuario.grado),
    );
    final asyncMapa = ref.watch(mapaProgresoProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar deslizable ─────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColores.gradienteAzul),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Row(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Text(
                        usuario.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${usuario.nombre}! 👋',
                            style: AppTextos.tituloTarjeta.copyWith(
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            usuario.nombreGrado,
                            style: AppTextos.cuerpoNormal.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            usuario.nombreNivel,
                            style: AppTextos.nivelJugador.copyWith(
                              color: AppColores.amarillo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Chips de racha y monedas
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ChipRacha(dias: usuario.rachaActual),
                        const SizedBox(height: 6),
                        ChipMonedas(monedas: usuario.monedas),
                      ],
                    ),
                  ],
                ),
              ),
              title: Text(
                'MathKids',
                style: AppTextos.tituloSeccion.copyWith(color: Colors.white),
              ),
              titlePadding:
                  const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.family_restroom, color: Colors.white),
                tooltip: 'Zona de padres',
                onPressed: () => context.push(Rutas.padres),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.white),
                tooltip: 'Mi progreso',
                onPressed: () => context.push(Rutas.progreso),
              ),
            ],
          ),

          // ── Cuerpo: mapa de aprendizaje ───────────────────
          SliverToBoxAdapter(
            child: asyncLecciones.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Error al cargar las lecciones.'),
              ),
              data: (lecciones) => asyncMapa.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (mapa) => _CuerpoHome(
                  lecciones: lecciones,
                  mapaProgreso: mapa,
                  grado: usuario.grado,
                ),
              ),
            ),
          ),
        ],
      ),
      // ── Bottom navigation ──────────────────────────────────
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Tienda',
          ),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 1: context.push(Rutas.recompensas);
            case 2: context.push(Rutas.tienda);
          }
        },
      ),
    );
  }
}

class _CuerpoHome extends StatelessWidget {
  final List<Leccion> lecciones;
  final Map<int, ProgresoLeccion> mapaProgreso;
  final int grado;

  const _CuerpoHome({
    required this.lecciones,
    required this.mapaProgreso,
    required this.grado,
  });

  @override
  Widget build(BuildContext context) {
    if (lecciones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: MascotaMateo(
            estado: EstadoMateo.durmiendo,
            mensaje: 'No hay lecciones aún.\n¡Vuelve pronto!',
          ),
        ),
      );
    }

    final completadas = mapaProgreso.values.where((p) => p.completada).length;
    final total = lecciones.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Progreso general ───────────────────────────────
          const SizedBox(height: 8),
          BarraProgreso(
            actual: completadas,
            total: total,
            color: AppColores.coloresPorGrado[grado] ?? AppColores.azulCielo,
          ),

          const SizedBox(height: 24),

          Text('Tu camino de aprendizaje', style: AppTextos.tituloSeccion),
          const SizedBox(height: 16),

          // ── Mapa visual de lecciones ──────────────────────
          MapaAprendizaje(
            lecciones: lecciones,
            mapaProgreso: mapaProgreso,
            grado: grado,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
