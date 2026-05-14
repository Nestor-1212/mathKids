import 'package:flutter/material.dart';

/// Paleta de colores oficial de MathKids Panamá.
class AppColores {
  AppColores._();

  // ── Primarios ──────────────────────────────────────────────
  static const azulCielo = Color(0xFF4A90D9);
  static const amarillo  = Color(0xFFFFD234);
  static const verde     = Color(0xFF4CAF50);
  static const naranja   = Color(0xFFFF8C42);

  // ── Secundarios ────────────────────────────────────────────
  static const azulOscuro   = Color(0xFF2C5F8A);
  static const verdeOscuro  = Color(0xFF388E3C);
  static const rojo         = Color(0xFFE53935); // solo respuesta incorrecta
  static const morado       = Color(0xFF9C27B0);
  static const rosado       = Color(0xFFE91E90);

  // ── Neutros ────────────────────────────────────────────────
  static const blanco      = Color(0xFFFFFFFF);
  static const grisClaro   = Color(0xFFF5F5F5);
  static const grisMedio   = Color(0xFFBDBDBD);
  static const grisOscuro  = Color(0xFF616161);
  static const negro       = Color(0xFF212121);

  // ── Fondos de pantalla ────────────────────────────────────
  static const fondoPrincipal = Color(0xFFF0F8FF); // azul muy claro
  static const fondoTarjeta   = Color(0xFFFFFFFF);

  // ── Gamificación ──────────────────────────────────────────
  static const oro      = Color(0xFFFFD700);
  static const plata    = Color(0xFFC0C0C0);
  static const bronce   = Color(0xFFCD7F32);
  static const estrellaActiva   = Color(0xFFFFD234);
  static const estrellaInactiva = Color(0xFFDDDDDD);

  // ── Niveles de dificultad ─────────────────────────────────
  static const facil   = Color(0xFF4CAF50);
  static const medio   = Color(0xFFFFD234);
  static const dificil = Color(0xFFFF8C42);
  static const experto = Color(0xFFE53935);

  // ── Gradientes ────────────────────────────────────────────
  static const gradienteAzul = LinearGradient(
    colors: [Color(0xFF4A90D9), Color(0xFF2C5F8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradienteVerde = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradienteAmarillo = LinearGradient(
    colors: [Color(0xFFFFE566), Color(0xFFFFD234)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradienteCelebracion = LinearGradient(
    colors: [Color(0xFFFFD234), Color(0xFFFF8C42)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Colores por grado ─────────────────────────────────────
  static const coloresPorGrado = <int, Color>{
    0: Color(0xFFFF8C42), // Pre-Kinder — naranja cálido
    1: Color(0xFFFFD234), // Kinder — amarillo
    2: Color(0xFF4CAF50), // 1er grado — verde
    3: Color(0xFF4A90D9), // 2do grado — azul cielo
    4: Color(0xFF9C27B0), // 3er grado — morado
    5: Color(0xFFE91E90), // 4to grado — rosado
    6: Color(0xFF00BCD4), // 5to grado — cian
    7: Color(0xFFE53935), // 6to grado — rojo vibrante
  };
}
