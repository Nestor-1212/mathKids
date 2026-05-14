import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colores.dart';
import '../../core/constants/estilos_texto.dart';
import '../../app/routes.dart';
import '../../widgets/mascota_mateo.dart';

/// Pantalla de bienvenida. Se muestra solo la primera vez
/// o cuando no hay ningún perfil activo.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacidad;
  late Animation<Offset> _deslizamiento;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacidad = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _deslizamiento = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90D9), Color(0xFF2C5F8A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _opacidad,
            child: SlideTransition(
              position: _deslizamiento,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Mascota Mateo ─────────────────────────
                    const MascotaMateo(
                      estado: EstadoMateo.feliz,
                      mensaje: '¡Hola! Soy Mateo,\ntu amigo matemático.',
                      tamano: 180,
                      narrarMensaje: true,
                    ),

                    const SizedBox(height: 32),

                    // ── Título ────────────────────────────────
                    const Text(
                      'MathKids\nPanamá',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Aprende matemáticas\nde forma divertida 🎉',
                      style: AppTextos.cuerpoGrande.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // ── Botones ───────────────────────────────
                    _BotonOnboarding(
                      etiqueta: '¡Vamos a jugar! 🚀',
                      color: AppColores.amarillo,
                      textoColor: AppColores.negro,
                      alPresionar: () => context.push(Rutas.seleccionPerfil),
                    ),

                    const SizedBox(height: 16),

                    _BotonOnboarding(
                      etiqueta: 'Crear nuevo perfil ✏️',
                      color: Colors.white.withOpacity(0.2),
                      textoColor: Colors.white,
                      borde: true,
                      alPresionar: () => context.push(Rutas.crearPerfil),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BotonOnboarding extends StatelessWidget {
  final String etiqueta;
  final Color color;
  final Color textoColor;
  final bool borde;
  final VoidCallback alPresionar;

  const _BotonOnboarding({
    required this.etiqueta,
    required this.color,
    required this.textoColor,
    required this.alPresionar,
    this.borde = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: alPresionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textoColor,
          elevation: borde ? 0 : 4,
          side: borde
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(etiqueta, style: AppTextos.botonPrincipal.copyWith(color: textoColor)),
      ),
    );
  }
}
