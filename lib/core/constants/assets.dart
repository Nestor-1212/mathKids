/// Rutas de todos los assets del proyecto.
/// Centralizar aquí evita errores de typo en strings sueltos.
class AppAssets {
  AppAssets._();

  // ── Base paths ────────────────────────────────────────────
  static const _img  = 'assets/images/';
  static const _anim = 'assets/animations/';
  static const _audio = 'assets/audio/';

  // ── Mascota Mateo (animaciones Lottie) ────────────────────
  static const mateoFeliz        = '${_anim}mateo_feliz.json';
  static const mateoTriste       = '${_anim}mateo_triste.json';
  static const mateoSorprendido  = '${_anim}mateo_sorprendido.json';
  static const mateoCelebrando   = '${_anim}mateo_celebrando.json';
  static const mateoDurmiendo    = '${_anim}mateo_durmiendo.json';
  static const mateoHablando     = '${_anim}mateo_hablando.json';

  // ── Imágenes generales ────────────────────────────────────
  static const logo            = '${_img}logo.png';
  static const fondoOnboarding = '${_img}fondo_onboarding.png';
  static const fondoHome       = '${_img}fondo_home.png';
  static const coronaNivel     = '${_img}corona_nivel.png';
  static const medallaNivel    = '${_img}medalla_nivel.png';

  // ── Avatares del usuario ──────────────────────────────────
  static const avatares = <String>[
    '${_img}avatar_nino_1.png',
    '${_img}avatar_nino_2.png',
    '${_img}avatar_nina_1.png',
    '${_img}avatar_nina_2.png',
    '${_img}avatar_robot.png',
    '${_img}avatar_astronauta.png',
  ];

  // ── Íconos de logros ──────────────────────────────────────
  static const logro1erDia      = '${_img}logro_primer_dia.png';
  static const logro7Racha      = '${_img}logro_racha_7.png';
  static const logro30Racha     = '${_img}logro_racha_30.png';
  static const logro100Monedas  = '${_img}logro_100_monedas.png';
  static const logro1000Monedas = '${_img}logro_1000_monedas.png';
  static const logro10Lecciones = '${_img}logro_10_lecciones.png';
  static const logroPerfecto    = '${_img}logro_perfecto.png';
  static const logroVelocidad   = '${_img}logro_velocidad.png';

  // ── Accesorios de Mateo (tienda) ──────────────────────────
  static const mateoBase           = '${_img}mateo_base.png';
  static const mateoSombrero       = '${_img}mateo_sombrero.png';
  static const mateoCapa           = '${_img}mateo_capa.png';
  static const mateoLentes         = '${_img}mateo_lentes.png';
  static const mateoCascoAstro     = '${_img}mateo_casco_astro.png';
  static const mateoCorona         = '${_img}mateo_corona.png';
  static const mateoBanda          = '${_img}mateo_banda.png';

  // ── Imágenes de conteo (ejercicios "¿Cuántos X hay?") ────
  static const conteoManzanas = '${_img}conteo_manzanas.png';
  static const conteoGatos    = '${_img}conteo_gatos.png';
  static const conteoPerros   = '${_img}conteo_perros.png';

  // ── Íconos de materias / temas ───────────────────────────
  static const iconoSuma          = '${_img}icono_suma.png';
  static const iconoResta         = '${_img}icono_resta.png';
  static const iconoMulti         = '${_img}icono_multiplicacion.png';
  static const iconoDivision      = '${_img}icono_division.png';
  static const iconoFracciones    = '${_img}icono_fracciones.png';
  static const iconoGeometria     = '${_img}icono_geometria.png';
  static const iconoMedicion      = '${_img}icono_medicion.png';
  static const iconoEstadistica   = '${_img}icono_estadistica.png';
  static const iconoPatrones      = '${_img}icono_patrones.png';

  // ── Sonidos ───────────────────────────────────────────────
  static const sonidoCorrecto     = '${_audio}correcto.mp3';
  static const sonidoIncorrecto   = '${_audio}incorrecto.mp3';
  static const sonidoCelebracion  = '${_audio}celebracion.mp3';
  static const sonidoMoneda       = '${_audio}moneda.mp3';
  static const sonidoNivel        = '${_audio}subir_nivel.mp3';
  static const sonidoClic         = '${_audio}clic.mp3';
  static const sonidoFondo        = '${_audio}musica_fondo.mp3';
  static const sonidoRacha        = '${_audio}racha.mp3';
}
