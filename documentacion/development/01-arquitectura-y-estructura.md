## 1. Arquitectura técnica

**Enfoque:** Clean Architecture (simplificada).

Capas principales:

- **presentation**  
  Widgets/UI y lógica de presentación (pantallas, estados).

- **application**  
  Casos de uso y orquestación (por ejemplo, `ValidateSerialUseCase`).

- **domain**  
  Entidades de negocio y contratos de repositorio.

- **data**  
  Implementaciones concretas de repositorios y data sources (assets, Hive, etc.).

---

## 2. Estructura de proyecto (objetivo)

```text
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

Esta estructura separa claramente:

- Lógica de negocio de validación.
- Acceso a datos (reglas y almacenamiento de historial).
- UI de validación e historial.

---

## 3. Stack tecnológico

| Componente           | Versión / Especificación (PRD) |
|----------------------|---------------------------------|
| Flutter              | 3.24.0 (o estable equivalente) |
| Dart                 | 3.5                            |
| Android mínimo       | Android 8.0 (API 26)           |

### 3.1 Librerías recomendadas

| Categoría         | Paquete                          |
|-------------------|----------------------------------|
| Estado            | `flutter_riverpod` ^2.5.1        |
| OCR               | `google_mlkit_text_recognition` ^0.11.0 |
| Cámara            | `camera` ^0.11.0                 |
| Storage local     | `hive` ^2.2.3                    |
| Storage local UI  | `hive_flutter` ^1.1.0            |
| Utilidades        | `equatable` ^2.0.5               |
| Utilidades        | `intl` ^0.19.0                   |
| Código generado   | `build_runner` ^2.4.9            |
| Código generado   | `hive_generator` ^2.0.1          |

---

## 4. Modelo de datos: reglas de inhabilitación

### 4.1 Entidad `RuleRange`

Representa un **rango de series inhabilitadas** para un corte y serie específicos.

```dart
class RuleRange {
  final int denomination;
  final String series;
  final int start;
  final int end;
}
```

Ejemplo:

```json
{
  "denomination": 10,
  "series": "B",
  "start": 77100001,
  "end": 77550000
}
```

### 4.2 Archivo de reglas

Ruta en el proyecto:

```text
assets/rules/rules_v1.json
```

Formato:

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

## 5. Algoritmo de validación

### 5.1 Pasos

1. **Convertir serie a número**  
   - Ejemplo: `87280145` → `87280145` (int).

2. **Filtrar reglas por corte y serie**  
   - Por ejemplo: denominación 20 Bs, serie B.

3. **Buscar en rangos ordenados**  
   - Los rangos se ordenan por el campo `start`.
   - Se utiliza **búsqueda binaria (binary search)** para decidir si el número está dentro de alguno de los intervalos `[start, end]`.

### 5.2 Complejidad

- Búsqueda: **O(log n)** sobre la lista de rangos.

### 5.3 OCR pipeline (alto nivel)

```text
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

- Regex sugerida para extracción de series: `[0-9]{7,9}`.

---

## 6. Nombre de paquete

Nombre de paquete propuesto en el PRD:

```text
com.newreboot.bscheck
```

Debe configurarse como:

- `applicationId` en `android/app/build.gradle.kts`.
- `namespace` en el mismo archivo.

