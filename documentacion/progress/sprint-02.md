# Sprint 02 — Motor de validación offline

**Estado**: Planned  
**Periodo**: pendiente de definir

## Objetivo del sprint

Implementar el **motor de validación offline** de series de billetes bolivianos a partir del archivo local de reglas, con rendimiento O(log n) y preparado para usarse desde la UI.

## Alcance

- [x] Modelo de dominio
  - [ ] `RuleRange` en `features/validation/domain/entities/rule_range.dart`.
  - [ ] `BanknoteSerial` y `ValidationResult` en `features/validation/domain/entities/`.
- [x] Repositorio de reglas
  - [ ] Interfaz `RulesRepository` en `features/validation/domain/repositories/rules_repository.dart`.
  - [ ] Data source local `RulesLocalDataSource` que lea `assets/rules/rules_v1.json`.
  - [ ] Implementación `RulesRepositoryImpl` en `features/validation/data/repositories/`.
- [x] Caso de uso de validación
  - [ ] `ValidateSerialUseCase` en `features/validation/application/validate_serial_usecase.dart`.
  - [ ] Algoritmo:
    - Convertir el serial (string) a entero.
    - Filtrar por denominación + serie.
    - Buscar en rangos ordenados usando **binary search**.
    - Devolver `ValidationResult` (VALID / DISABLED / NOT_RECOGNIZED).
- [ ] Pruebas básicas
  - [ ] Tests unitarios mínimos del caso de uso con datos de ejemplo de `rules_v1.json`.

## Criterios de aceptación

- Dado un serial que esté **dentro** de un rango inhabilitado, el caso de uso devuelve `DISABLED`.
- Dado un serial que **no esté** en ningún rango, devuelve `VALID`.
- Dado un input que no se pueda parsear correctamente (longitud incorrecta, caracteres no numéricos), devuelve `NOT_RECOGNIZED`.
- La validación de un serial en memoria tarda **menos de 100 ms** en dispositivos típicos.

## Notas

- La lógica de validación debe ser **independiente de la UI** y del OCR; ambos solo proveen un `String` de serial.
- El archivo `rules_v1.json` debe poder sustituirse en el futuro por versiones nuevas sin cambiar el contrato del repositorio.

