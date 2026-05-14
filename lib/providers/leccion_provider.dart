import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leccion.dart';
import '../models/progreso.dart';
import '../core/database/database_helper.dart';
import 'usuario_provider.dart';

// ── Lecciones por grado ───────────────────────────────────

final leccionesPorGradoProvider =
    FutureProvider.family<List<Leccion>, int>((ref, grado) async {
  return DatabaseHelper.instancia.obtenerLeccionesPorGrado(grado);
});

// ── Progreso del usuario activo ───────────────────────────

final progresoUsuarioProvider =
    FutureProvider<List<ProgresoLeccion>>((ref) async {
  final usuario = ref.watch(usuarioActivoProvider);
  if (usuario == null) return [];
  return DatabaseHelper.instancia.obtenerProgresoDeUsuario(usuario.id!);
});

// ── Mapa: leccionId → ProgresoLeccion ────────────────────

final mapaProgresoProvider =
    FutureProvider<Map<int, ProgresoLeccion>>((ref) async {
  final progreso = await ref.watch(progresoUsuarioProvider.future);
  return {for (final p in progreso) p.leccionId: p};
});

// ── Lección seleccionada actualmente ─────────────────────

final leccionSeleccionadaProvider =
    StateNotifierProvider<LeccionSeleccionadaNotifier, Leccion?>(
  (ref) => LeccionSeleccionadaNotifier(),
);

class LeccionSeleccionadaNotifier extends StateNotifier<Leccion?> {
  LeccionSeleccionadaNotifier() : super(null);

  void seleccionar(Leccion leccion) => state = leccion;
  void limpiar() => state = null;
}

// ── Guardar progreso ──────────────────────────────────────

final guardarProgresoProvider =
    Provider<GuardarProgresoService>((ref) => GuardarProgresoService(ref));

class GuardarProgresoService {
  final Ref _ref;
  GuardarProgresoService(this._ref);

  Future<void> guardar({
    required int leccionId,
    required int estrellas,
    required double precisionPct,
    required bool completada,
  }) async {
    final usuario = _ref.read(usuarioActivoProvider);
    if (usuario == null) return;

    final progresoExistente = await DatabaseHelper.instancia.obtenerProgreso(
      usuarioId: usuario.id!,
      leccionId: leccionId,
    );

    final nuevoProgreso = ProgresoLeccion(
      id: progresoExistente?.id,
      usuarioId: usuario.id!,
      leccionId: leccionId,
      // Solo sobreescribir si el nuevo resultado es mejor
      estrellas: estrellas > (progresoExistente?.estrellas ?? 0)
          ? estrellas
          : (progresoExistente?.estrellas ?? 0),
      precisionPct: precisionPct > (progresoExistente?.precisionPct ?? 0)
          ? precisionPct
          : (progresoExistente?.precisionPct ?? 0),
      intentos: (progresoExistente?.intentos ?? 0) + 1,
      completada: completada || (progresoExistente?.completada ?? false),
      fechaCompletada: completada ? DateTime.now() : progresoExistente?.fechaCompletada,
    );

    await DatabaseHelper.instancia.upsertProgreso(nuevoProgreso);
    _ref.invalidate(progresoUsuarioProvider);
    _ref.invalidate(mapaProgresoProvider);
  }
}
