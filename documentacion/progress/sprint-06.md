# Sprint 06 — UI/UX completo, corrección de reglas y preparación para publicación

**Estado**: Done  
**Periodo**: 2026-03-04  
**Sesión**: [Chat de sesión](7f005a48-dca5-421d-af45-4f5e6f216afd)

---

## Objetivo del sprint

Elevar la app de un estado de MVP funcional a una **versión 1.0.0 lista para distribución pública** en Play Store y GitHub Releases, con UI moderna y profesional, backend correctamente verificado y configuración de firma Android en orden.

---

## Tareas completadas

### UI/UX — Rediseño completo (Material 3 fintech)

- [x] `main.dart` — `ThemeData` con `ColorScheme.fromSeed`, tipografía Roboto/Inter, CardThemeData, FilledButton, OutlinedButton, NavigationBarTheme, SegmentedButtonTheme.
- [x] `home_page.dart`:
  - Header verde con `AnnotatedRegion` para iconos de barra blancos.
  - Banner BCB ("Serie B · Banco Central de Bolivia").
  - Botones de acción rediseñados (`_PrimaryAction`, `_SecondaryAction`).
  - Diálogo "Acerca de" completamente reescrito (descripción, features, link GitHub).
  - Botón TikTok: fondo blanco, ícono verde, badge con gradiente oficial celeste→rosa.
  - Eliminado el texto "Proyecto comunitario de Best-Doit".
- [x] `scan_page.dart`:
  - Fondo claro (eliminado el fondo negro anterior).
  - Botones de corte: tarjetas grandes 72px, táctiles, verde cuando seleccionado.
  - Instrucciones numeradas claras (① ②).
  - Fix de preview distorsionado: `FittedBox(fit: BoxFit.cover)` dentro de `SizedBox.expand`.
  - Flash restyled acorde al tema claro.
- [x] `manual_input_page.dart`:
  - `AnnotatedRegion` para iconos blancos sobre header verde.
  - Botones de corte iguales al scan (consistencia).
  - Instrucciones numeradas.
- [x] `history_page.dart`:
  - Estadísticas rápidas (tarjetas: Válidos / Inhabilitados / Total).
  - Agrupación temporal (Hoy / Ayer / Esta semana / este mes).
  - Badges de resultado con color.
- [x] `result_page.dart` — Hero visual por resultado (verde/rojo/gris).
- [x] `onboarding_page.dart`:
  - Slide nuevo al inicio: condolencias accidente aéreo + utilidad de la app offline.
  - Flag `isCondolence` para renderizado distinto (tema oscuro, respetuoso).
  - Eliminado ribbon "Q.E.P.D." (redundante).

---

### Backend — Corrección de reglas (`rules_v1.json`)

Error detectado: los rangos de 10 Bs y 50 Bs estaban invertidos en el archivo.

- [x] **10 Bs**: 10 rangos correctamente asignados (ej.: `67.250.001 – 67.700.000`, `76.310.012 – 85.139.995`).
- [x] **20 Bs**: 16 rangos verificados sin cambios (ej.: `87.280.145 – 91.646.549`).
- [x] **50 Bs**: 12 rangos correctamente asignados (ej.: `77.100.001 – 77.550.000`, `78.900.001 – 96.350.000`).

---

### Tests — Suite completa alineada

- [x] `validation_ranges_test.dart` reescrito desde cero post-corrección de reglas.
- [x] 33 tests pasando — **`flutter test`: 0 errores**.
  - 10 Bs: límites inferior/superior, rangos grandes, fuera de rango.
  - 20 Bs: inicio/fin primer rango, rango intermedio, fuera de rango.
  - 50 Bs: primer rango, rango grande (78.9M–96.3M), último rango, fuera de rango.
  - Aislamiento: misma serie en distintos denominaciones da resultados distintos.
  - Edge cases: series vacías, muy cortas, muy largas, texto puro.

---

### Android — Configuración de release y publicación

- [x] `pubspec.yaml`: versión `1.0.0+1`, `applicationId` → `bo.bestdoit.bscheck`.
- [x] `android/app/build.gradle.kts`:
  - `namespace`/`applicationId` = `bo.bestdoit.bscheck`.
  - `compileSdk` y `targetSdk` = 36, `minSdk` = 26.
  - `signingConfigs { create("release") }` cargado desde `key.properties`.
  - `buildTypes.release` usa el signing de release.
- [x] `android/app/src/main/kotlin/.../MainActivity.kt`: package actualizado a `bo.bestdoit.bscheck`.
- [x] `AndroidManifest.xml`: bloque `<queries>` con intents `https` y `http` para `url_launcher` en Android 11+.
- [x] Keystore generado (externo al repo): `bscheck-release-key.jks`, alias `bscheck`, CN=Best Doit, O=New Reboot, L=Cochabamba, C=BO.
- [x] `android/key.properties` referenciado en build (ignorado por `.gitignore`).

---

### Análisis estático

- [x] `flutter analyze`: **0 errores, 0 warnings** al cierre del sprint.

Errores corregidos durante el sprint:
- `CardTheme` → `CardThemeData` (tipo incorrecto en ThemeData).
- `surfaceVariant` → `surfaceContainerHighest` (deprecated en M3).
- Import `flutter/services.dart` faltante en `scan_page.dart`.
- `separatorBuilder: (_, __)` → `(_, i)` (lint de variable no usada).
- Linker: package `bo.bestdoit.bscheck` no encontrado por `MainActivity.kt` aún en `com.example.bscheck`.

---

## Validación de salida

- [x] `flutter test` — **35 tests pasando** (33 reglas + 2 widget).
- [x] `flutter analyze` — **0 issues**.
- [x] `flutter build apk --release` — APK firmado generado.
- [x] APK instalado y probado en dispositivo físico (Android 12).
- [x] Links externos verificados (GitHub + TikTok abren correctamente).
- [x] Barra de estado: iconos blancos en pantallas con header verde.
- [x] Preview de cámara sin distorsión.

---

## Tamaños de APK release

| Artefacto | Tamaño |
|---|---|
| `app-armeabi-v7a-release.apk` | ~28 MB |
| `app-arm64-v8a-release.apk` | ~35 MB |
| `app-x86_64-release.apk` | ~37 MB |
| `app-release.apk` (universal) | ~85 MB |

Para GitHub Releases se distribuye preferentemente el APK por ABI o el universal.

---

## Riesgos / pendientes futuros

- Subir a Google Play Store (cuenta de desarrollador activa, AAB listo).
- Publicar primera GitHub Release con tag `v1.0.0` y APKs adjuntos.
- Monitorear feedback de OCR en distintos modelos de dispositivos.
- Evaluar habilitar `isMinifyEnabled = true` (actualmente deshabilitado por precaución con ML Kit).
