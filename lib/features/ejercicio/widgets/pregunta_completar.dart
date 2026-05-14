import 'package:flutter/material.dart';
import '../../../core/constants/colores.dart';
import '../../../core/constants/estilos_texto.dart';

/// Widget para ejercicios de "completar el espacio en blanco".
/// Muestra un teclado numérico grande y amigable para niños.
class PreguntaCompletar extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool deshabilitado;

  const PreguntaCompletar({
    super.key,
    required this.onSubmit,
    this.deshabilitado = false,
  });

  @override
  State<PreguntaCompletar> createState() => _PreguntaCompletarState();
}

class _PreguntaCompletarState extends State<PreguntaCompletar> {
  String _entrada = '';

  void _presionarTecla(String tecla) {
    if (widget.deshabilitado) return;
    setState(() {
      if (_entrada.length < 6) _entrada += tecla;
    });
  }

  void _borrar() {
    if (_entrada.isEmpty) return;
    setState(() => _entrada = _entrada.substring(0, _entrada.length - 1));
  }

  void _confirmar() {
    if (_entrada.isEmpty || widget.deshabilitado) return;
    widget.onSubmit(_entrada);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Display de la respuesta ───────────────────────────
        Container(
          constraints: const BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColores.azulCielo, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColores.azulCielo.withOpacity(0.2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            _entrada.isEmpty ? '?' : _entrada,
            style: AppTextos.numeroPrincipal.copyWith(
              color: _entrada.isEmpty
                  ? AppColores.grisMedio
                  : AppColores.azulOscuro,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // ── Teclado numérico ──────────────────────────────────
        _TecladoNumerico(
          alPresionar: _presionarTecla,
          alBorrar: _borrar,
          alConfirmar: _entrada.isNotEmpty ? _confirmar : null,
        ),
      ],
    );
  }
}

class _TecladoNumerico extends StatelessWidget {
  final ValueChanged<String> alPresionar;
  final VoidCallback alBorrar;
  final VoidCallback? alConfirmar;

  const _TecladoNumerico({
    required this.alPresionar,
    required this.alBorrar,
    required this.alConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    const numeros = ['7','8','9','4','5','6','1','2','3'];
    return Column(
      children: [
        // Fila 7-8-9
        _FilaTeclado(teclas: numeros.sublist(0, 3), alPresionar: alPresionar),
        const SizedBox(height: 8),
        // Fila 4-5-6
        _FilaTeclado(teclas: numeros.sublist(3, 6), alPresionar: alPresionar),
        const SizedBox(height: 8),
        // Fila 1-2-3
        _FilaTeclado(teclas: numeros.sublist(6, 9), alPresionar: alPresionar),
        const SizedBox(height: 8),
        // Fila 0 + borrar + confirmar
        Row(
          children: [
            Expanded(child: _Tecla(label: '0', alPresionar: () => alPresionar('0'))),
            const SizedBox(width: 8),
            Expanded(
              child: _TeclaAccion(
                icono: Icons.backspace_outlined,
                color: AppColores.naranja,
                alPresionar: alBorrar,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TeclaAccion(
                icono: Icons.check_circle,
                color: alConfirmar != null ? AppColores.verde : AppColores.grisMedio,
                alPresionar: alConfirmar,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilaTeclado extends StatelessWidget {
  final List<String> teclas;
  final ValueChanged<String> alPresionar;

  const _FilaTeclado({required this.teclas, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: teclas
          .expand((t) => [
                Expanded(child: _Tecla(label: t, alPresionar: () => alPresionar(t))),
                if (t != teclas.last) const SizedBox(width: 8),
              ])
          .toList(),
    );
  }
}

class _Tecla extends StatelessWidget {
  final String label;
  final VoidCallback alPresionar;

  const _Tecla({required this.label, required this.alPresionar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: alPresionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColores.azulOscuro,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColores.azulCielo.withOpacity(0.3),
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextos.numeroPrincipal.copyWith(fontSize: 28),
        ),
      ),
    );
  }
}

class _TeclaAccion extends StatelessWidget {
  final IconData icono;
  final Color color;
  final VoidCallback? alPresionar;

  const _TeclaAccion({
    required this.icono,
    required this.color,
    required this.alPresionar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: alPresionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        child: Icon(icono, size: 28, color: color),
      ),
    );
  }
}
