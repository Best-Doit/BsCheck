## BsCheck — Verificador de billetes bolivianos

**BsCheck** es una aplicación móvil Android **100% offline** para verificar si un billete boliviano pertenece a un rango de series inhabilitadas por el **Banco Central de Bolivia (BCB)**, basada en datos públicos de la Nueva Serie B.

- **Plataforma**: Android (mín. Android 8.0 / API 26)
- **Framework**: Flutter 3 · Dart 3
- **Application ID**: `bo.bestdoit.bscheck`
- **Versión**: 1.0.0
- **Repositorio**: [github.com/Best-Doit/BsCheck](https://github.com/Best-Doit/BsCheck)
- **Licencia**: Apache 2.0

---

## Características principales

- **Cortes soportados**: 10 Bs · 20 Bs · 50 Bs
- **Serie soportada**: Serie B (Nueva Serie BCB)
- **Métodos de ingreso**:
  - Escaneo con cámara (OCR — Google ML Kit)
  - Ingreso manual de la serie numérica
- **Resultados**:
  - ✅ **VÁLIDO** — la serie no está en rangos inhabilitados
  - ⛔ **INHABILITADO** — la serie pertenece a un rango inhabilitado
  - ❓ **NO RECONOCIDO** — el texto no se puede interpretar como serie válida
- **Historial local**: guarda consultas (serie, corte, resultado, fecha/hora) solo en el dispositivo
- **Sin internet, sin registro, sin servidores externos**

---

## Rangos de series inhabilitadas (verificados)

| Denominación | Rangos | Fuente |
|---|---|---|
| **10 Bs** | 10 rangos (67.250.001 – 92.250.000) | BCB — confirmado |
| **20 Bs** | 16 rangos (87.280.145 – 120.950.000) | BCB — confirmado |
| **50 Bs** | 12 rangos (77.100.001 – 109.850.000) | BCB — confirmado |

Los rangos están en `assets/rules/rules_v1.json` y se validan mediante **búsqueda binaria** en memoria local.

---

## Arquitectura

```
lib/
├── main.dart                        # Tema global Material 3, inicialización
├── features/
│   ├── navigation/presentation/     # MainShellPage (NavigationBar)
│   ├── onboarding/presentation/     # OnboardingPage (primera vez)
│   ├── validation/
│   │   ├── presentation/            # HomePage, ScanPage, ManualInputPage, ResultPage
│   │   ├── application/             # ValidateSerialUseCase, providers (Riverpod)
│   │   ├── domain/                  # Entidades (BanknoteSerial, ValidationResult, RuleRange)
│   │   └── data/                    # RulesRepositoryImpl, RulesLocalDataSource
│   └── history/
│       ├── presentation/            # HistoryPage
│       └── data/                    # HistoryLocalDataSourceImpl (Hive)
└── presentation/widgets/            # AppButton, HistoryListItem
assets/
└── rules/rules_v1.json              # Rangos de series inhabilitadas
test/
└── validation_ranges_test.dart      # 33 tests — 10/20/50 Bs + edge cases
```

**Stack técnico**:
- `flutter_riverpod` — gestión de estado
- `google_mlkit_text_recognition` — OCR
- `camera` — acceso a cámara
- `hive` / `hive_flutter` — almacenamiento local
- `url_launcher` — apertura de links externos

---

## Flujo de uso

### Pantalla Home
- Banner **"Serie B · Banco Central de Bolivia"**
- Botón principal: **Escanear billete** (recomendado)
- Botones secundarios: **Manual** · **Historial**
- Botón **Info** (ícono ℹ): abre diálogo con descripción, características y link a GitHub

### Escanear billete (OCR)
1. Selecciona el **corte** del billete (10 / 20 / 50 Bs) — botones grandes, táctiles
2. Alinea la serie del billete dentro del marco de la cámara
3. Toca **"Capturar y validar"**
4. La app aplica OCR, extrae la serie y valida offline

### Ingresar serie manualmente
1. Selecciona el **corte** del billete
2. Escribe la serie (7–9 dígitos)
3. Toca **"Validar billete"**

### Historial
- Agrupado por fecha (Hoy / Ayer / Esta semana / mes)
- Estadísticas rápidas: Válidos · Inhabilitados · Total
- Badge de color por resultado

---

## Instalación desde GitHub (sin Play Store)

Para dispositivos **sin Google Play** o instalación directa:

### Requisitos
- Android 8.0 (API 26) o superior
- Activar: `Ajustes → Seguridad → Instalar apps desconocidas`

### Instalar
1. Ve a [Releases](https://github.com/Best-Doit/BsCheck/releases)
2. Descarga `app-release.apk` de la versión más reciente
3. Abre el APK en tu teléfono y acepta los permisos

### Actualizar
- Descarga el nuevo `app-release.apk` e instala encima del anterior
- No desinstales — se conserva el historial local

---

## Desarrollo y contribución

### Requisitos
- Flutter SDK ≥ 3.11
- Android SDK (compileSdk 36, minSdk 26)

### Comandos principales
```bash
# Instalar dependencias
flutter pub get

# Correr en debug
flutter run

# Ejecutar tests (33 tests)
flutter test

# Análisis estático
flutter analyze

# Build release (Play Store)
flutter build appbundle --release

# Build APK (distribución directa)
flutter build apk --release
```

### Estructura de reglas
El archivo `assets/rules/rules_v1.json` tiene este formato:
```json
{
  "version": 1,
  "currency": "BOB",
  "rules": [
    { "denomination": 10, "series": "B", "start": 67250001, "end": 67700000 },
    ...
  ]
}
```
Para añadir nuevos rangos: agregar entradas con `denomination`, `series`, `start`, `end`.

### Contribuir
- **Issues**: bugs, problemas OCR, rangos a actualizar
- **Pull Requests**: mejoras UI/UX, nuevas reglas, optimizaciones
- Revisar `documentacion/` antes de proponer cambios al comportamiento principal

---

## Privacidad y seguridad

- La app **no** recopila datos personales
- Todo el historial se guarda **solo en el dispositivo** (Hive local)
- No hay conexiones a servidores externos
- Código abierto y auditable

> **Aviso**: esta aplicación no es oficial del Banco Central de Bolivia.  
> La información se basa en datos públicos y no constituye asesoramiento financiero.

---

## Licencia

Apache 2.0 — ver archivo `LICENSE`.

Forks permitidos respetando la licencia. **No está permitido** usar el nombre "BsCheck", el logo original ni presentarse como app oficial de Best-Doit o del BCB en apps derivadas sin autorización expresa.

Crédito a [Best-Doit/BsCheck](https://github.com/Best-Doit/BsCheck) en proyectos derivados.
