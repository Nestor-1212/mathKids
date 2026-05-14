import 'package:flutter/material.dart';
import 'colores.dart';

/// Estilos tipográficos de MathKids Panamá.
/// Fuente base: Nunito (redondeada, amigable para niños).
/// Tamaño mínimo en ejercicios: 18sp (especificación de UX infantil).
class AppTextos {
  AppTextos._();

  // ── Títulos ───────────────────────────────────────────────
  static const tituloPantalla = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColores.negro,
    letterSpacing: -0.5,
  );

  static const tituloSeccion = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColores.negro,
  );

  static const tituloTarjeta = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColores.negro,
  );

  // ── Ejercicios (tamano mínimo 18sp) ──────────────────────
  static const pregunta = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColores.negro,
    height: 1.4,
  );

  static const opcionRespuesta = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColores.negro,
  );

  static const numeroPrincipal = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColores.azulOscuro,
  );

  static const numeroSecundario = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColores.azulCielo,
  );

  // ── Cuerpo ────────────────────────────────────────────────
  static const cuerpoGrande = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColores.grisOscuro,
    height: 1.5,
  );

  static const cuerpoNormal = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColores.grisOscuro,
    height: 1.5,
  );

  static const cuerpoChico = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColores.grisMedio,
  );

  // ── Botones ───────────────────────────────────────────────
  static const botonPrincipal = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColores.blanco,
    letterSpacing: 0.5,
  );

  static const botonSecundario = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColores.azulCielo,
  );

  // ── Gamificación ──────────────────────────────────────────
  static const monedas = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColores.oro,
  );

  static const nivelJugador = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColores.azulCielo,
    letterSpacing: 1.0,
  );

  // ── Celebración ───────────────────────────────────────────
  static const celebracion = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColores.blanco,
    shadows: [
      Shadow(
        color: Color(0x66000000),
        blurRadius: 8,
        offset: Offset(2, 2),
      ),
    ],
  );

  // ── Mateo (diálogos de la mascota) ───────────────────────
  static const burbujaMateo = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColores.negro,
    height: 1.4,
  );
}
