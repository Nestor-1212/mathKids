import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/colores.dart';
import 'routes.dart';

class MathKidsApp extends ConsumerWidget {
  const MathKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MathKids Panamá',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _temaMathKids(),
    );
  }

  ThemeData _temaMathKids() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColores.azulCielo,
        primary: AppColores.azulCielo,
        secondary: AppColores.amarillo,
        tertiary: AppColores.verde,
        surface: AppColores.fondoPrincipal,
      ),
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: AppColores.fondoPrincipal,

      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColores.azulCielo,
          foregroundColor: AppColores.blanco,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          elevation: 3,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColores.azulCielo,
        foregroundColor: AppColores.blanco,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColores.blanco,
        ),
        elevation: 0,
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColores.blanco,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColores.azulCielo.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColores.azulCielo, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          color: AppColores.grisOscuro,
        ),
      ),

      // Tarjetas
      cardTheme: CardThemeData(
        color: AppColores.fondoTarjeta,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // Chips (nivel, dificultad)
      chipTheme: ChipThemeData(
        backgroundColor: AppColores.azulCielo.withOpacity(0.1),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    );
  }
}
