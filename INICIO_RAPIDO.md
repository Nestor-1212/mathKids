# MathKids Panamá — Inicio rápido

## Requisitos
- Flutter 3.22+ instalado y en PATH
- Android Studio o VS Code con plugin Flutter
- Dispositivo Android o emulador (API 21+)

## Pasos para correr el proyecto

```bash
cd Desktop/math-kids-panama

# 1. Instalar dependencias
flutter pub get

# 2. Agregar fuente Nunito (descargar desde fonts.google.com)
#    Colocar en: assets/fonts/
#      - Nunito-Regular.ttf
#      - Nunito-Bold.ttf
#      - Nunito-ExtraBold.ttf

# 3. Agregar placeholder para animaciones Lottie (mientras se diseñan)
#    Colocar un archivo JSON vacío en assets/animations/ con cada nombre
#    definido en AppAssets (mateo_feliz.json, etc.)
#    Puedes usar: https://lottiefiles.com para encontrar owls/birds animados

# 4. Correr la app
flutter run
```

## Estructura de archivos creados

```
lib/
├── main.dart                          ← Entrada, init DB + audio
├── app/
│   ├── app.dart                       ← MaterialApp + tema
│   └── routes.dart                    ← GoRouter con guard de auth
├── core/
│   ├── constants/
│   │   ├── colores.dart               ← Paleta completa
│   │   ├── estilos_texto.dart         ← Tipografía Nunito
│   │   └── assets.dart                ← Rutas de assets
│   ├── database/
│   │   ├── database_helper.dart       ← SQLite CRUD completo
│   │   └── seed_data.dart             ← Lecciones MEDUCA + ejercicios
│   └── utils/
│       ├── audio_service.dart         ← TTS Mateo + sonidos
│       └── adaptive_engine.dart       ← Motor adaptativo (sube/baja dificultad)
├── models/
│   ├── usuario.dart
│   ├── leccion.dart
│   ├── ejercicio.dart
│   └── progreso.dart                  ← ProgresoLeccion + Sesion + Logro
├── providers/
│   ├── usuario_provider.dart          ← Estado usuario activo + monedas + racha
│   ├── leccion_provider.dart          ← Lecciones + progreso + guardar
│   └── ejercicio_provider.dart        ← Motor adaptativo como StateNotifier
├── widgets/
│   ├── mascota_mateo.dart             ← Mateo con 6 estados Lottie + burbuja
│   ├── boton_respuesta.dart           ← Botón con estados y animaciones
│   ├── barra_progreso.dart            ← Progreso + estrellas + racha + monedas
│   └── confetti_overlay.dart          ← Confetti de 3 cañones
└── features/
    ├── onboarding/
    │   ├── onboarding_screen.dart     ← Bienvenida con gradiente
    │   ├── seleccion_perfil_screen.dart ← Grid de perfiles
    │   └── crear_perfil_screen.dart   ← Form nombre + grado + avatar
    ├── home/
    │   ├── home_screen.dart           ← SliverAppBar + mapa
    │   └── widgets/mapa_aprendizaje.dart ← Zigzag de burbujas
    ├── ejercicio/
    │   ├── ejercicio_screen.dart      ← Motor adaptativo + feedback Mateo
    │   └── widgets/pregunta_completar.dart ← Teclado numérico táctil
    ├── progreso/progreso_screen.dart  ← Estadísticas + nivel + racha
    ├── recompensas/recompensas_screen.dart ← Logros bloqueados/desbloqueados
    ├── tienda/tienda_screen.dart      ← Accesorios para Mateo
    └── padres/padres_screen.dart      ← PIN + config audio + estadísticas
```

## Credenciales
- PIN de padres por defecto: **1234**

## Próximos pasos (Fase 2)
- [ ] Agregar animaciones Lottie reales para Mateo
- [ ] Agregar imágenes de avatares en assets/images/
- [ ] Implementar ejercicios de arrastrar y soltar (DragTarget)
- [ ] Implementar ejercicios de contar objetos (Pre-K / Kinder)
- [ ] Panel de maestros (versión premium)
- [ ] Integrar Firebase para sincronización multi-dispositivo
- [ ] Modo sin conexión con indicador visible
