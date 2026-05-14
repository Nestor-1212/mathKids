import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usuario_provider.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/seleccion_perfil_screen.dart';
import '../features/onboarding/crear_perfil_screen.dart';
import '../features/home/home_screen.dart';
import '../features/ejercicio/ejercicio_screen.dart';
import '../features/progreso/progreso_screen.dart';
import '../features/recompensas/recompensas_screen.dart';
import '../features/tienda/tienda_screen.dart';
import '../features/padres/padres_screen.dart';

// ── Nombres de rutas ──────────────────────────────────────

class Rutas {
  Rutas._();
  static const onboarding     = '/';
  static const seleccionPerfil = '/perfiles';
  static const crearPerfil    = '/crear-perfil';
  static const home           = '/home';
  static const ejercicio      = '/ejercicio/:leccionId';
  static const progreso       = '/progreso';
  static const recompensas    = '/recompensas';
  static const tienda         = '/tienda';
  static const padres         = '/padres';
}

// ── Provider del router ──────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final usuarioActivo = ref.watch(usuarioActivoProvider);

  return GoRouter(
    initialLocation: Rutas.onboarding,
    redirect: (context, state) {
      final tieneUsuario = usuarioActivo != null;
      final estaEnOnboarding = state.matchedLocation == Rutas.onboarding ||
          state.matchedLocation == Rutas.seleccionPerfil ||
          state.matchedLocation == Rutas.crearPerfil;

      // Si no tiene usuario activo y no está en onboarding, redirigir
      if (!tieneUsuario && !estaEnOnboarding) {
        return Rutas.onboarding;
      }
      // Si ya tiene usuario activo y está en onboarding, ir al home
      if (tieneUsuario && estaEnOnboarding) {
        return Rutas.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Rutas.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Rutas.seleccionPerfil,
        builder: (context, state) => const SeleccionPerfilScreen(),
      ),
      GoRoute(
        path: Rutas.crearPerfil,
        builder: (context, state) => const CrearPerfilScreen(),
      ),
      GoRoute(
        path: Rutas.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Rutas.ejercicio,
        builder: (context, state) {
          final leccionId = int.parse(state.pathParameters['leccionId']!);
          return EjercicioScreen(leccionId: leccionId);
        },
      ),
      GoRoute(
        path: Rutas.progreso,
        builder: (context, state) => const ProgresoScreen(),
      ),
      GoRoute(
        path: Rutas.recompensas,
        builder: (context, state) => const RecompensasScreen(),
      ),
      GoRoute(
        path: Rutas.tienda,
        builder: (context, state) => const TiendaScreen(),
      ),
      GoRoute(
        path: Rutas.padres,
        builder: (context, state) => const PadresScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.error}'),
      ),
    ),
  );
});
