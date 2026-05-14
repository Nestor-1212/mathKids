import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/constants/assets.dart';
import '../../providers/usuario_provider.dart';
import '../../app/routes.dart';
import '../../widgets/mascota_mateo.dart';

/// Pantalla para crear un nuevo perfil de usuario (niño).
class CrearPerfilScreen extends ConsumerStatefulWidget {
  const CrearPerfilScreen({super.key});

  @override
  ConsumerState<CrearPerfilScreen> createState() => _CrearPerfilScreenState();
}

class _CrearPerfilScreenState extends ConsumerState<CrearPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  int _gradoSeleccionado = 0;
  int _avatarSeleccionado = 0;
  bool _guardando = false;

  static const _grados = [
    'Pre-Kinder (4-5 años)',
    'Kinder (5-6 años)',
    '1er Grado',
    '2do Grado',
    '3er Grado',
    '4to Grado',
    '5to Grado',
    '6to Grado',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      await ref.read(usuarioActivoProvider.notifier).crear(
            nombre: _nombreController.text.trim(),
            grado: _gradoSeleccionado,
            avatarIndice: _avatarSeleccionado,
          );

      if (mounted) context.go(Rutas.home);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear el perfil.')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear perfil')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mateo dando instrucciones ─────────────────
              const Center(
                child: MascotaMateo(
                  estado: EstadoMateo.hablando,
                  mensaje: '¡Cuéntame tu nombre\ny tu grado!',
                  tamano: 130,
                  narrarMensaje: true,
                ),
              ),

              const SizedBox(height: 24),

              // ── Nombre ────────────────────────────────────
              Text('Tu nombre', style: AppTextos.tituloSeccion),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                textCapitalization: TextCapitalization.words,
                style: AppTextos.cuerpoGrande,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu nombre',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Escribe tu nombre';
                  if (v.trim().length < 2) return 'Nombre muy corto';
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // ── Grado ─────────────────────────────────────
              Text('Tu grado', style: AppTextos.tituloSeccion),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _gradoSeleccionado,
                style: AppTextos.cuerpoGrande,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: List.generate(_grados.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(_grados[i]),
                  );
                }),
                onChanged: (v) => setState(() => _gradoSeleccionado = v!),
              ),

              const SizedBox(height: 24),

              // ── Avatar ────────────────────────────────────
              Text('Escoge tu avatar', style: AppTextos.tituloSeccion),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppAssets.avatares.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) {
                    final seleccionado = _avatarSeleccionado == i;
                    return GestureDetector(
                      onTap: () => setState(() => _avatarSeleccionado = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: seleccionado
                                ? AppColores.azulCielo
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: seleccionado
                              ? [
                                  BoxShadow(
                                    color: AppColores.azulCielo.withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.avatares[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CircleAvatar(
                              backgroundColor: AppColores.azulCielo.withOpacity(0.2),
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 36),

              // ── Botón guardar ─────────────────────────────
              ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('¡Empezar a jugar! 🚀'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
