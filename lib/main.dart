import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/database/database_helper.dart';
import 'core/utils/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Forzar orientación vertical (apps infantiles)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Barra de sistema transparente para UI inmersiva
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Inicializar la base de datos (crea tablas y seed en primera ejecución)
  await DatabaseHelper.instancia.db;

  // Inicializar servicio de audio
  await AudioService.instancia.inicializar();

  runApp(
    const ProviderScope(
      child: MathKidsApp(),
    ),
  );
}
