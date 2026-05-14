import 'package:flutter_tts/flutter_tts.dart';

/// Servicio singleton para narración TTS y efectos de sonido.
/// Toda interacción del niño debe tener respuesta de audio.
class AudioService {
  AudioService._();
  static final AudioService instancia = AudioService._();

  final FlutterTts _tts = FlutterTts();
  bool _inicializado = false;
  bool _habilitado = true; // los padres pueden desactivarlo

  // ── Inicialización ────────────────────────────────────────

  Future<void> inicializar() async {
    if (_inicializado) return;
    try {
      await _tts.setLanguage('es-PA'); // español panameño; fallback a es-US
      await _tts.setSpeechRate(0.45);  // lento para niños
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.15);       // ligeramente agudo, más amigable
      _inicializado = true;
    } catch (_) {
      // Si falla la inicialización, la app sigue funcionando sin audio
      _inicializado = true;
    }
  }

  // ── TTS — Narración de Mateo ──────────────────────────────

  /// Lee en voz alta el texto dado (voz de Mateo).
  Future<void> narrar(String texto) async {
    if (!_habilitado || texto.isEmpty) return;
    await _asegurarInicializado();
    try {
      await _tts.stop();
      await _tts.speak(texto);
    } catch (_) {}
  }

  /// Detiene cualquier narración en curso.
  Future<void> detener() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  // ── Frases estándar de Mateo ──────────────────────────────

  Future<void> bienvenida(String nombreNino) async {
    await narrar('¡Hola $nombreNino! ¿Listo para aprender matemáticas hoy?');
  }

  Future<void> correcto() async {
    const frases = [
      '¡Muy bien! ¡Lo lograste!',
      '¡Excelente! ¡Eres un genio!',
      '¡Correcto! ¡Así se hace!',
      '¡Bacano! ¡Eso estuvo súper!',
      '¡Chulísimo! ¡Sigue así!',
    ];
    await narrar(_frasesAleatorias(frases));
  }

  Future<void> incorrecto() async {
    const frases = [
      'Casi. ¡Inténtalo otra vez!',
      'No te rindas, ¡tú puedes!',
      '¡Ánimo! Prueba de nuevo.',
      'Esta es difícil. ¡Vamos!',
    ];
    await narrar(_frasesAleatorias(frases));
  }

  Future<void> pista(String textoPista) async {
    await narrar('Aquí va una pista: $textoPista');
  }

  Future<void> completarLeccion() async {
    await narrar('¡Felicitaciones! ¡Completaste la lección! ¡Eres un campeón!');
  }

  Future<void> nuevaRacha(int dias) async {
    await narrar('¡Wow! ¡$dias días seguidos estudiando! ¡Increíble!');
  }

  Future<void> leerPregunta(String pregunta) async {
    await narrar(pregunta);
  }

  // ── Configuración ─────────────────────────────────────────

  void setHabilitado(bool valor) => _habilitado = valor;
  bool get estaHabilitado => _habilitado;

  Future<void> cambiarVelocidad(double velocidad) async {
    await _asegurarInicializado();
    await _tts.setSpeechRate(velocidad.clamp(0.2, 1.0));
  }

  // ── Helpers privados ──────────────────────────────────────

  Future<void> _asegurarInicializado() async {
    if (!_inicializado) await inicializar();
  }

  String _frasesAleatorias(List<String> frases) {
    final indice = DateTime.now().millisecond % frases.length;
    return frases[indice];
  }

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
