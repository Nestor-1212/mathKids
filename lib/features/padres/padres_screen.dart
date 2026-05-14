import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/audio_service.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/mascota_mateo.dart';

/// Pantalla de zona de padres con PIN de acceso.
class PadresScreen extends ConsumerStatefulWidget {
  const PadresScreen({super.key});

  @override
  ConsumerState<PadresScreen> createState() => _PadresScreenState();
}

class _PadresScreenState extends ConsumerState<PadresScreen> {
  bool _autenticado = false;
  final _pinController = TextEditingController();
  String? _errorPin;

  static const _pinKey = 'math_kids_pin_padres';
  static const _pinDefecto = '1234';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verificarPin() async {
    final prefs = await SharedPreferences.getInstance();
    final pinGuardado = prefs.getString(_pinKey) ?? _pinDefecto;

    if (_pinController.text == pinGuardado) {
      setState(() {
        _autenticado = true;
        _errorPin = null;
      });
    } else {
      setState(() => _errorPin = 'PIN incorrecto. Intenta de nuevo.');
      _pinController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona de padres'),
        backgroundColor: AppColores.azulOscuro,
      ),
      body: _autenticado ? _PanelPadres(ref: ref) : _PantallaPIN(
        controller: _pinController,
        error: _errorPin,
        alVerificar: _verificarPin,
      ),
    );
  }
}

// ── Pantalla de ingreso de PIN ─────────────────────────────

class _PantallaPIN extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback alVerificar;

  const _PantallaPIN({
    required this.controller,
    required this.error,
    required this.alVerificar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 64,
              color: AppColores.azulOscuro,
            ),
            const SizedBox(height: 16),
            Text('Zona de Padres', style: AppTextos.tituloPantalla),
            const SizedBox(height: 8),
            Text(
              'Ingresa el PIN para acceder.\nPIN por defecto: 1234',
              style: AppTextos.cuerpoNormal,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: AppTextos.numeroPrincipal.copyWith(fontSize: 32),
              decoration: InputDecoration(
                hintText: '••••',
                errorText: error,
                counterText: '',
              ),
              onSubmitted: (_) => alVerificar(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: alVerificar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColores.azulOscuro,
              ),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panel principal de padres ──────────────────────────────

class _PanelPadres extends ConsumerWidget {
  final WidgetRef ref;
  const _PanelPadres({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioActivoProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ────────────────────────────────────
          const Center(
            child: MascotaMateo(
              estado: EstadoMateo.feliz,
              mensaje: 'Aquí puedes controlar\nla experiencia de tu hijo.',
              tamano: 120,
            ),
          ),

          const SizedBox(height: 24),

          if (usuario != null) ...[
            Text('Perfil activo', style: AppTextos.tituloSeccion),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: AppColores.azulCielo, size: 32),
                title: Text(usuario.nombre, style: AppTextos.tituloTarjeta),
                subtitle: Text(usuario.nombreGrado),
                trailing: Text('Nivel ${usuario.nivelJugador}',
                    style: AppTextos.nivelJugador),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Configuración de audio ────────────────────────
          Text('Configuración', style: AppTextos.tituloSeccion),
          const SizedBox(height: 12),
          _SwitchAjuste(
            icono: Icons.volume_up,
            titulo: 'Narración de voz (Mateo)',
            descripcion: 'Mateo habla durante los ejercicios',
            valor: AudioService.instancia.estaHabilitado,
            alCambiar: (v) => AudioService.instancia.setHabilitado(v),
          ),

          const SizedBox(height: 8),

          // ── Cambiar PIN ───────────────────────────────────
          const SizedBox(height: 16),
          Text('Seguridad', style: AppTextos.tituloSeccion),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColores.azulCielo.withOpacity(0.3)),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.lock_reset, color: AppColores.azulCielo),
            title: const Text('Cambiar PIN de padres'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _mostrarCambiarPin(context),
          ),

          const SizedBox(height: 24),

          // ── Estadísticas del hijo ─────────────────────────
          if (usuario != null) ...[
            Text('Estadísticas de ${usuario.nombre}',
                style: AppTextos.tituloSeccion),
            const SizedBox(height: 12),
            _TarjetaEstadisticas(usuarioId: usuario.id!),
          ],
        ],
      ),
    );
  }

  Future<void> _mostrarCambiarPin(BuildContext context) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: 'Ingresa nuevo PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length >= 4) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('math_kids_pin_padres', controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN actualizado correctamente')),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _SwitchAjuste extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final bool valor;
  final ValueChanged<bool> alCambiar;

  const _SwitchAjuste({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.valor,
    required this.alCambiar,
  });

  @override
  State<_SwitchAjuste> createState() => _SwitchAjusteState();
}

class _SwitchAjusteState extends State<_SwitchAjuste> {
  late bool _valor;

  @override
  void initState() {
    super.initState();
    _valor = widget.valor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(widget.icono, color: AppColores.azulCielo),
        title: Text(widget.titulo, style: AppTextos.cuerpoGrande),
        subtitle: Text(widget.descripcion, style: AppTextos.cuerpoChico),
        value: _valor,
        activeColor: AppColores.verde,
        onChanged: (v) {
          setState(() => _valor = v);
          widget.alCambiar(v);
        },
      ),
    );
  }
}

class _TarjetaEstadisticas extends StatelessWidget {
  final int usuarioId;
  const _TarjetaEstadisticas({required this.usuarioId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        DatabaseHelper.instancia.obtenerPrecisionPromedio(usuarioId),
        DatabaseHelper.instancia.obtenerTiempoTotalEstudiado(usuarioId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final precision = (snapshot.data![0] as double).toStringAsFixed(1);
        final tiempoSeg = snapshot.data![1] as int;
        final minutos = tiempoSeg ~/ 60;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MiniStat('🎯', '$precision%', 'Precisión'),
                _MiniStat('⏱️', '${minutos}min', 'Tiempo\ntotal'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icono;
  final String valor;
  final String etiqueta;

  const _MiniStat(this.icono, this.valor, this.etiqueta);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icono, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColores.azulOscuro,
          ),
        ),
        Text(etiqueta, style: AppTextos.cuerpoChico, textAlign: TextAlign.center),
      ],
    );
  }
}
