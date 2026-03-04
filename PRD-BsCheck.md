# PRD — BsCheck

**Aplicación móvil offline para verificación de billetes bolivianos**

| Campo | Valor |
|-------|--------|
| **Versión** | 1.0 (MVP) |
| **Producto** | BsCheck |
| **Tipo** | Aplicación móvil Android offline |
| **Framework** | Flutter |

---

## 1. Resumen del producto

BsCheck es una aplicación móvil que permite verificar rápidamente si un billete boliviano pertenece a un rango de series inhabilitadas, utilizando escaneo de cámara (OCR) o ingreso manual.

La app está diseñada para:

- comerciantes
- cajeros
- personal de ventas
- usuarios comunes

**Funciona 100% offline** para garantizar velocidad y disponibilidad.

---

## 2. Objetivo del MVP

Permitir que un usuario pueda:

1. Escanear la serie de un billete
2. Verificar en **menos de 1 segundo** si pertenece a un rango inhabilitado
3. Obtener un resultado claro:
   - **VALIDO**
   - **INHABILITADO**
   - **NO RECONOCIDO**

---

## 3. Alcance MVP

El MVP incluirá:

### Verificación de billetes

**Cortes soportados:**

- 10 Bs
- 20 Bs
- 50 Bs

**Serie soportada:**

- Serie B

### Métodos de ingreso

1. **Escaneo con cámara (OCR)**
2. **Ingreso manual**

### Funcionalidades MVP

| Funcionalidad | Estado |
|---------------|--------|
| Escaneo OCR de número de serie | ✔ |
| Validación offline | ✔ |
| Resultado inmediato | ✔ |
| Ingreso manual de serie | ✔ |
| Historial local de consultas | ✔ |
| Funciona sin internet | ✔ |

---

## 4. Usuarios objetivo

**Usuarios primarios:**

- comerciantes
- cajeros
- vendedores
- mercados
- bancos informales

**Escenario típico:** Un comerciante recibe un billete y en 2 segundos lo valida.

---

## 5. Casos de uso

### Caso 1 — Escaneo

1. Usuario abre la app.
2. Presiona: **Escanear billete**
3. La cámara detecta el número de serie.
4. **Resultado:**
   - ⚠ **Billete inhabilitado**  
   - o ✔ **Billete válido**

### Caso 2 — Ingreso manual

1. Usuario introduce: `87280145`
2. **Resultado:** Inhabilitado

---

## 6. Requisitos funcionales

| ID | Requisito |
|----|-----------|
| **RF1** | La app debe poder leer números mediante OCR usando la cámara. |
| **RF2** | La app debe validar la serie contra una base local de rangos. |
| **RF3** | La validación debe tomar menos de 100 ms. |
| **RF4** | La app debe permitir ingreso manual. |
| **RF5** | La app debe guardar historial de consultas. |

---

## 7. Requisitos no funcionales

| ID | Requisito |
|----|-----------|
| **RNF1** | **Offline first** — La app debe funcionar sin internet. |
| **RNF2** | **Rapidez** — Tiempo máximo de verificación: **< 200 ms** |
| **RNF3** | **Tamaño app** — Menor a: **60 MB** |

---

## 8. Arquitectura técnica

**Arquitectura recomendada:** Clean Architecture (simplificada)

**Capas:**

- presentation
- application
- domain
- data

---

## 9. Estructura del proyecto

```
lib/
├── core/
│   ├── constants
│   └── utils
│
├── features/
│   ├── validation/
│   │   ├── presentation/
│   │   │   ├── scan_page.dart
│   │   │   └── result_page.dart
│   │   ├── application/
│   │   │   └── validate_serial_usecase.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── banknote_serial.dart
│   │   │   │   └── validation_result.dart
│   │   │   └── repositories/
│   │   │       └── rules_repository.dart
│   │   └── data/
│   │       ├── datasources/
│   │       │   └── rules_local_datasource.dart
│   │       └── repositories/
│   │           └── rules_repository_impl.dart
│   │
│   └── history/
│       ├── presentation/
│       │   └── history_page.dart
│       └── data/
│           └── history_local_datasource.dart
```

---

## 10. Stack tecnológico

| Componente | Versión / Especificación |
|------------|--------------------------|
| **Framework** | Flutter 3.24.0 |
| **Dart** | Dart 3.5 |
| **Android mínimo** | Android 8.0 (API 26) |

---

## 11. Librerías recomendadas

| Categoría | Librería | Versión |
|-----------|----------|---------|
| **Estado** | flutter_riverpod | ^2.5.1 |
| **OCR** | google_mlkit_text_recognition | ^0.11.0 |
| **Cámara** | camera | ^0.11.0 |
| **Storage local** | hive | ^2.2.3 |
| **Storage local** | hive_flutter | ^1.1.0 |
| **Utilidades** | equatable | ^2.0.5 |
| **Utilidades** | intl | ^0.19.0 |
| **Generación código** | build_runner | ^2.4.9 |
| **Generación código** | hive_generator | ^2.0.1 |

---

## 12. Modelo de datos

### RuleRange

Representa un rango de series inhabilitadas.

```dart
class RuleRange {
  final int denomination;
  final String series;
  final int start;
  final int end;
}
```

**Ejemplo:**

```json
{
  "denomination": 10,
  "series": "B",
  "start": 77100001,
  "end": 77550000
}
```

---

## 13. Algoritmo de validación

**Paso 1:** Convertir serie a número: `87280145`

**Paso 2:** Buscar en rangos.

### Optimización

- Los rangos se ordenan por: **start**
- Se usa: **binary search**
- **Complejidad:** O(log n)

---

## 14. Archivo de reglas

**Archivo local:** `assets/rules/rules_v1.json`

**Formato:**

```json
{
  "version": 1,
  "currency": "BOB",
  "rules": [
    {
      "denomination": 10,
      "series": "B",
      "start": 77100001,
      "end": 77550000
    },
    {
      "denomination": 20,
      "series": "B",
      "start": 87280145,
      "end": 91646549
    }
  ]
}
```

---

## 15. OCR pipeline

```
camera frame
    ↓
MLKit OCR
    ↓
text extraction
    ↓
regex filter
    ↓
serial candidate
    ↓
validation
```

**Regex sugerido:** `[0-9]{7,9}`

---

## 16. UI MVP

### Pantallas

| Pantalla | Descripción |
|----------|-------------|
| **Home** | Botones: *Escanear billete*, *Ingresar serie*, *Historial* |
| **Escaneo** | Vista cámara, overlay guía, resultado inmediato |
| **Resultado** | ✔ Billete válido / ⚠ Billete inhabilitado / ❓ No reconocido |
| **Historial** | Lista: fecha, serie, resultado |

---

## 17. Seguridad

- La app **no almacena datos personales**.
- Solo guarda: **historial de series verificadas**.

---

## 18. Performance

| Métrica | Objetivo |
|---------|----------|
| Carga de reglas | < 20 ms |
| Validación | < 5 ms |

---

## 19. Roadmap futuro

**Versión 2:**

- Reconocimiento automático de corte
- Detección de billetes falsos
- Actualización automática de reglas
- Soporte otros países

---

## 20. Nombre de paquete

```
com.newreboot.bscheck
```

---

## 21. Branding

| Elemento | Valor |
|----------|--------|
| **App name** | BsCheck |
| **Tagline** | Verificador de billetes bolivianos |

---

## 22. Licencia

La app debe mostrar aviso:

> Esta aplicación no es oficial del Banco Central de Bolivia.  
> La información se basa en datos públicos.

---

## 23. Entregables del agente

El agente debe producir:

- Flutter project
- Estructura clean architecture
- OCR funcional
- Motor de validación
- UI básica
- Archivo `rules.json`

---

## 24. Tiempo estimado de desarrollo

Para un agente bien configurado: **6 — 8 horas**

---

*Documento PRD — BsCheck v1.0 (MVP)*
