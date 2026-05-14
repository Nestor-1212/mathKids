import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/usuario.dart';
import '../core/database/database_helper.dart';

// ── Provider: lista de todos los usuarios ─────────────────

final listaUsuariosProvider = FutureProvider<List<Usuario>>((ref) async {
  return DatabaseHelper.instancia.obtenerTodosLosUsuarios();
});

// ── Provider: usuario activo de la sesión ─────────────────

final usuarioActivoProvider =
    StateNotifierProvider<UsuarioActivoNotifier, Usuario?>((ref) {
  return UsuarioActivoNotifier();
});

class UsuarioActivoNotifier extends StateNotifier<Usuario?> {
  UsuarioActivoNotifier() : super(null);

  final _db = DatabaseHelper.instancia;

  /// Selecciona el usuario activo (se llama desde la pantalla de perfil).
  Future<void> seleccionar(int usuarioId) async {
    final usuario = await _db.obtenerUsuarioPorId(usuarioId);
    state = usuario;
  }

  /// Crea un nuevo usuario y lo pone como activo.
  Future<void> crear({
    required String nombre,
    required int grado,
    required int avatarIndice,
  }) async {
    final nuevo = Usuario(
      nombre: nombre,
      grado: grado,
      avatarIndice: avatarIndice,
      creadoEn: DateTime.now(),
    );
    final id = await _db.insertarUsuario(nuevo);
    state = nuevo.copyWith(id: id);
  }

  /// Suma monedas y verifica si sube de nivel.
  Future<void> ganarMonedas(int cantidad) async {
    final u = state;
    if (u == null) return;

    final nuevasMonedas = u.monedas + cantidad;
    final nuevasMonedas2 = nuevasMonedas;

    // Calcular nuevo nivel basado en monedas acumuladas históricas
    int nuevoNivel = u.nivelJugador;
    while (nuevoNivel < 20 &&
        nuevasMonedas2 >= _monedasParaNivel(nuevoNivel + 1)) {
      nuevoNivel++;
    }

    final actualizado = u.copyWith(
      monedas: nuevasMonedas2,
      nivelJugador: nuevoNivel,
    );
    await _db.actualizarUsuario(actualizado);
    state = actualizado;
  }

  /// Actualiza la racha diaria del usuario.
  Future<void> actualizarRacha() async {
    final u = state;
    if (u == null) return;

    final ahora = DateTime.now();
    final ultimoEstudio = u.ultimoEstudio;

    int nuevaRacha = u.rachaActual;

    if (ultimoEstudio == null) {
      nuevaRacha = 1;
    } else {
      final diferencia = ahora.difference(ultimoEstudio).inDays;
      if (diferencia == 1) {
        nuevaRacha = u.rachaActual + 1; // continuó la racha
      } else if (diferencia > 1) {
        nuevaRacha = 1; // rompió la racha
      }
      // diferencia == 0: mismo día, no cambia la racha
    }

    final actualizado = u.copyWith(
      rachaActual: nuevaRacha,
      rachaMejor: nuevaRacha > u.rachaMejor ? nuevaRacha : u.rachaMejor,
      ultimoEstudio: ahora,
    );
    await _db.actualizarUsuario(actualizado);
    state = actualizado;
  }

  /// Recarga el usuario desde la base de datos.
  Future<void> recargar() async {
    final u = state;
    if (u?.id == null) return;
    state = await _db.obtenerUsuarioPorId(u!.id!);
  }

  /// Cierra la sesión del usuario activo.
  void cerrarSesion() => state = null;

  int _monedasParaNivel(int nivel) => nivel * nivel * 50;
}
