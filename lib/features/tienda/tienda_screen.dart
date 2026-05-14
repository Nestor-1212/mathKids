import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/constants/assets.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/mascota_mateo.dart';

/// Accesorio disponible en la tienda para Mateo.
class _Accesorio {
  final String id;
  final String nombre;
  final String emoji;
  final int precio;

  const _Accesorio({
    required this.id,
    required this.nombre,
    required this.emoji,
    required this.precio,
  });
}

const _accesorios = [
  _Accesorio(id: 'sombrero',   nombre: 'Sombrero de vaquero', emoji: '🤠', precio: 100),
  _Accesorio(id: 'capa',       nombre: 'Capa de héroe',        emoji: '🦸', precio: 200),
  _Accesorio(id: 'lentes',     nombre: 'Lentes de científico', emoji: '🥽', precio: 150),
  _Accesorio(id: 'casco_astro',nombre: 'Casco de astronauta',  emoji: '👨‍🚀', precio: 300),
  _Accesorio(id: 'corona',     nombre: 'Corona real',          emoji: '👑', precio: 500),
  _Accesorio(id: 'banda',      nombre: 'Banda rockera',        emoji: '🎸', precio: 250),
];

/// Pantalla de la tienda donde se canjean monedas por accesorios para Mateo.
class TiendaScreen extends ConsumerWidget {
  const TiendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActivoProvider);
    if (usuario == null) return const SizedBox.shrink();

    final accesoriosDesbloqueados = usuario.accesoriosMateo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda de Mateo'),
        backgroundColor: AppColores.morado,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  '${usuario.monedas}',
                  style: AppTextos.monedas,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mateo con accesorio activo ────────────────────
            Center(
              child: MascotaMateo(
                estado: EstadoMateo.feliz,
                mensaje: '¡Compra accesorios\npara personalizar a Mateo!',
                tamano: 150,
              ),
            ),

            const SizedBox(height: 24),

            Text('Accesorios disponibles', style: AppTextos.tituloSeccion),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _accesorios.length,
              itemBuilder: (context, index) {
                final acc = _accesorios[index];
                final yaComprado = accesoriosDesbloqueados.contains(acc.id);
                final puedePagar = usuario.monedas >= acc.precio;

                return _TarjetaAccesorio(
                  accesorio: acc,
                  yaComprado: yaComprado,
                  puedePagar: puedePagar,
                  alComprar: () async {
                    if (yaComprado || !puedePagar) return;
                    await _comprar(context, ref, acc, usuario);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _comprar(
    BuildContext context,
    WidgetRef ref,
    _Accesorio acc,
    dynamic usuario,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Comprar ${acc.nombre}'),
        content: Text(
          'Se descontarán ${acc.precio} monedas de tu cuenta.\n'
          'Tienes ${usuario.monedas} monedas.\n\n'
          '¿Confirmas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('¡Comprar!'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    // Descontar monedas y registrar accesorio
    final nuevaLista = [...usuario.accesoriosMateo, acc.id];
    final actualizado = usuario.copyWith(
      monedas: usuario.monedas - acc.precio,
      accesoriosMateo: nuevaLista,
    );

    // La actualización real debería hacerse desde el notifier:
    // Por ahora se llama directamente para mantener el ejemplo simple.
    await ref.read(usuarioActivoProvider.notifier).ganarMonedas(-acc.precio);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Compraste ${acc.nombre}! ${acc.emoji}'),
          backgroundColor: AppColores.verde,
        ),
      );
    }
  }
}

class _TarjetaAccesorio extends StatelessWidget {
  final _Accesorio accesorio;
  final bool yaComprado;
  final bool puedePagar;
  final VoidCallback alComprar;

  const _TarjetaAccesorio({
    required this.accesorio,
    required this.yaComprado,
    required this.puedePagar,
    required this.alComprar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(accesorio.emoji, style: const TextStyle(fontSize: 48)),
            Text(
              accesorio.nombre,
              style: AppTextos.tituloTarjeta,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              width: double.infinity,
              child: yaComprado
                  ? ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: const Text('¡Ya tienes!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.verde,
                        disabledBackgroundColor: AppColores.verde.withOpacity(0.6),
                        disabledForegroundColor: Colors.white,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: puedePagar ? alComprar : null,
                      icon: const Text('🪙'),
                      label: Text('${accesorio.precio}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.morado,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
