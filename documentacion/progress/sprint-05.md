# Sprint 05 — Cierre de brechas MVP

**Estado**: Done  
**Periodo**: 2026-03-04

## Objetivo del sprint

Cerrar brechas críticas detectadas contra el PRD MVP para dejar la app en estado de validación final.

## Alcance

- [x] Estabilizar build Android release.
- [x] Alinear flujo de escaneo con cortes del MVP (10/20/50).
- [x] Corregir parseo de serial para entrada OCR/manual con caracteres no numéricos.
- [x] Inicializar almacenamiento local (Hive) al arranque.
- [ ] Completar reglas oficiales de 50 Bs en `rules_v1.json` (bloqueado por falta de dataset fuente).

## Implementación realizada

- Android:
  - [x] `compileSdk` y `targetSdk` fijados en 36.
  - [x] `minSdk` fijado en 26 (alineado al PRD).
  - [x] Minify deshabilitado en release para evitar bloqueo de build en esta fase.
  - [x] Dependencia `google_mlkit_text_recognition` actualizada a versión estable reciente para compatibilidad con toolchain actual.
- Validación:
  - [x] Escaneo ahora permite seleccionar corte 10/20/50 y lo usa en validación, resultado e historial.
  - [x] Regex de limpieza de serial corregida a `\D`.
- Arranque:
  - [x] `Hive.initFlutter()` agregado en `main()` antes de iniciar la app.

## Validación de salida

- [x] `flutter test` pasando.
- [x] `flutter build apk --release` generando APK correctamente.
- [x] Tamaño bajo 60 MB usando artefactos de distribución por ABI.
  - `app-armeabi-v7a-release.apk` = **28.0 MB**.
  - `app-arm64-v8a-release.apk` = **34.9 MB**.
  - `app-x86_64-release.apk` = **36.8 MB**.
- [ ] APK universal bajo 60 MB.
  - Resultado actual: `app-release.apk` = **85.4 MB**.

## Riesgos y pendientes

- Falta cargar rangos inhabilitados oficiales para 50 Bs en el archivo de reglas.
- Se requiere testear en dispositivo real los tiempos objetivo del PRD (RF3/RNF2).
