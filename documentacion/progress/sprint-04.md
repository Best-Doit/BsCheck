# Sprint 04 — UI, historial y pulido MVP

**Estado**: In progress  
**Periodo**: pendiente de definir

## Objetivo del sprint

Completar la **UI del MVP**, el **historial local** y ajustes de performance/UX para preparar una versión instalable de BsCheck para pruebas de campo.

## Alcance

- [x] Pantalla Home
  - [ ] Botones principales: **Scan banknote**, **Enter serial**, **History**.
  - [ ] Diseño simple, con buen contraste, pensando en uso rápido.
- [x] Pantalla de ingreso manual
  - [ ] Campo numérico con validaciones básicas (7–9 dígitos).
  - [ ] Botón **Validate** que usa el caso de uso de validación.
  - [ ] Manejo claro de errores y estado `NOT RECOGNIZED`.
- [x] Pantalla de resultado
  - [ ] Diferenciar claramente **VALID**, **DISABLED**, **NOT RECOGNIZED** (color, iconos, mensajes).
  - [ ] Mostrar serial y (cuando se use) denominación/serie.
- [x] Historial local
  - [ ] Persistir entradas con Hive (`timestamp`, `serial`, `result`).
  - [ ] Pantalla de **History** que muestre la lista ordenada por fecha (más reciente arriba).
- [ ] Ajustes finales
  - [ ] Verificar tiempos de carga de reglas (< 20 ms) y validación (< 5 ms core).
  - [ ] Probar la app en al menos 1–2 dispositivos Android reales.

## Criterios de aceptación

- Usuario puede completar **ciclo completo**: Home → Scan/Enter serial → Resultado → (opcional) History.
- La app funciona **offline**, sin errores, en las rutas principales.
- Historial muestra las consultas más recientes con resultado correcto.

