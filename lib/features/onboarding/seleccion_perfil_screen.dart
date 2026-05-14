import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/constants/assets.dart';
import '../../models/usuario.dart';
import '../../providers/usuario_provider.dart';
import '../../app/routes.dart';
import '../../widgets/mascota_mateo.dart';

/// Pantalla de selección de perfil existente.
class SeleccionPerfilScreen extends ConsumerWidget {
  const SeleccionPerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUsuarios = ref.watch(listaUsuariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Quién eres tú?'),
        leading: const BackButton(),
      ),
      body: asyncUsuarios.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error al cargar perfiles')),
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return _SinPerfiles(
              alCrear: () => context.push(Rutas.crearPerfil),
            );
          }
          return _ListaPerfiles(
            usuarios: usuarios,
            alSeleccionar: (u) async {
              await ref.read(usuarioActivoProvider.notifier).seleccionar(u.id!);
              if (context.mounted) context.go(Rutas.home);
            },
            alCrearNuevo: () => context.push(Rutas.crearPerfil),
          );
        },
      ),
    );
  }
}

class _ListaPerfiles extends StatelessWidget {
  final List<Usuario> usuarios;
  final ValueChanged<Usuario> alSeleccionar;
  final VoidCallback alCrearNuevo;

  const _ListaPerfiles({
    required this.usuarios,
    required this.alSeleccionar,
    required this.alCrearNuevo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const MascotaMateo(
            estado: EstadoMateo.hablando,
            mensaje: 'Toca tu nombre para entrar.',
            tamano: 120,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: usuarios.length + 1, // +1 para el botón "crear"
              itemBuilder: (context, index) {
                if (index == usuarios.length) {
                  return _TarjetaAgregarPerfil(alPresionar: alCrearNuevo);
                }
                return _TarjetaPerfil(
                  usuario: usuarios[index],
                  alPresionar: () => alSeleccionar(usuarios[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPerfil extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback alPresionar;

  const _TarjetaPerfil({required this.usuario, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    final colorGrado = AppColores.coloresPorGrado[usuario.grado] ?? AppColores.azulCielo;
    final avatarPath = usuario.avatarIndice < AppAssets.avatares.length
        ? AppAssets.avatares[usuario.avatarIndice]
        : null;

    return GestureDetector(
      onTap: alPresionar,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorGrado.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: colorGrado, width: 3),
              ),
              child: avatarPath != null
                  ? ClipOval(
                      child: Image.asset(
                        avatarPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          size: 40,
                          color: colorGrado,
                        ),
                      ),
                    )
                  : Icon(Icons.person, size: 40, color: colorGrado),
            ),
            const SizedBox(height: 10),
            Text(
              usuario.nombre,
              style: AppTextos.tituloTarjeta,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              usuario.nombreGrado,
              style: AppTextos.cuerpoChico.copyWith(color: colorGrado),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 2),
                Text(
                  '${usuario.monedas}',
                  style: AppTextos.cuerpoChico.copyWith(
                    color: AppColores.grisOscuro,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAgregarPerfil extends StatelessWidget {
  final VoidCallback alPresionar;
  const _TarjetaAgregarPerfil({required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alPresionar,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColores.verde.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColores.verde.withOpacity(0.5),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(Icons.add, size: 36, color: AppColores.verde),
            ),
            const SizedBox(height: 10),
            Text(
              'Nuevo\nperfil',
              style: AppTextos.cuerpoNormal.copyWith(
                color: AppColores.verde,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SinPerfiles extends StatelessWidget {
  final VoidCallback alCrear;
  const _SinPerfiles({required this.alCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MascotaMateo(
              estado: EstadoMateo.sorprendido,
              mensaje: 'Aún no hay perfiles.\n¡Crea el tuyo!',
              tamano: 150,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: alCrear,
              child: const Text('Crear mi perfil ✏️'),
            ),
          ],
        ),
      ),
    );
  }
}
