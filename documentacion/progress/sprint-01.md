# Sprint 01 — Entorno y cimientos

**Estado**: Done  
**Periodo**: a definir (ej. 2026-03-04 → 2026-03-05)

## Objetivo del sprint

Dejar listo el **entorno de desarrollo** y los **cimientos del proyecto Flutter** para poder empezar a construir las features del MVP sin bloqueos técnicos.

## Alcance

- [x] Entorno Android listo sin Android Studio
  - Instalación de Flutter en Ubuntu 24.04.
  - Instalación de Android SDK (command line tools).
  - Configuración de `ANDROID_HOME` y `ANDROID_SDK_ROOT`.
  - Aceptación de licencias (`flutter doctor --android-licenses`).
  - `flutter doctor` con **Android toolchain OK**.
- [x] Creación del proyecto Flutter `bscheck`
  - `flutter create --project-name bscheck .` en la carpeta del proyecto.
  - Verificación de que la app de ejemplo corre en Android (pendiente de primer run real en dispositivo/emulador si se desea documentar).
- [x] Estructura básica de documentación
  - Carpeta `documentacion/`.
  - Subcarpetas: `planning`, `design`, `development`, `maintenance`, `progress`.
  - Documento `MVP-Requirements.md` en `planning` consolidando el PRD del MVP.
- [x] Base técnica inicial del proyecto
  - Creación de estructura base en `lib/` según Clean Architecture simplificada:
    - `core/constants`, `core/utils`.
    - `features/validation/...` (presentation, application, domain, data).
    - `features/history/...` (presentation, data).
  - Configuración de `pubspec.yaml` con librerías recomendadas para el MVP.
  - Registro del asset `assets/rules/rules_v1.json`.

## Resultado del sprint

- El proyecto **bscheck** existe y compila como app Flutter base.
- El entorno Android está listo para desarrollar y probar en dispositivos/emuladores.
- El MVP está claramente definido en `MVP-Requirements.md`.
- Hay una estructura inicial de carpetas alineada con la arquitectura deseada.

## Notas y decisiones

- Se decidió trabajar primero solo con **Android**, dejando iOS y otras plataformas para sprints futuros.
- No se instala Android Studio; se usan solo **Android command line tools**.
- La documentación de alto nivel (PRD y MVP) se mantiene separada en `PRD-BsCheck.md` y `documentacion/planning/MVP-Requirements.md`.

