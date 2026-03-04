## 1. Requisitos funcionales (RF)

| ID    | Requisito                                                                 |
|-------|---------------------------------------------------------------------------|
| RF1   | La app debe poder leer números mediante **OCR** usando la cámara.        |
| RF2   | La app debe validar la serie contra una **base local de rangos**.        |
| RF3   | La validación debe tomar **menos de 100 ms** (núcleo de búsqueda).       |
| RF4   | La app debe permitir **ingreso manual** de la serie.                     |
| RF5   | La app debe guardar un **historial local** de consultas.                 |

---

## 2. Requisitos no funcionales (RNF)

| ID    | Requisito                                                                 |
|-------|---------------------------------------------------------------------------|
| RNF1  | **Offline first** — La app debe funcionar **sin internet**.              |
| RNF2  | **Rapidez** — Tiempo máximo de verificación (end-to-end) **< 200 ms**.   |
| RNF3  | **Tamaño app** — El tamaño del binario Android debe ser **< 60 MB**.     |

---

## 3. Seguridad y privacidad

- La app **no almacena datos personales** (no hay cuentas ni login).
- Solo se guarda localmente:
  - Historial de series verificadas.
  - Fecha/hora de verificación.
  - Resultado (VÁLIDO / INHABILITADO / NO RECONOCIDO).
- No se hacen llamadas a servidores externos en el flujo principal del MVP.

---

## 4. Performance objetivo

### 4.1 Métricas clave

| Métrica           | Objetivo    |
|-------------------|------------|
| Carga de reglas   | < 20 ms    |
| Validación núcleo | < 5 ms     |

Donde:

- *Carga de reglas* = lectura y parseo del archivo `rules_v1.json` en memoria.
- *Validación núcleo* = búsqueda de la serie en los rangos ya cargados (algoritmo O(log n)).

### 4.2 Comportamiento esperado

- La latencia percibida por el usuario (desde tener la serie hasta ver el resultado en pantalla) debe ser:
  - Idealmente inferior a **200 ms** en dispositivos de gama media.
  - Sin bloqueos visibles de UI.

---

## 5. Licencia y aviso legal

La app debe mostrar en algún lugar visible (por ejemplo, en un diálogo “Acerca de” o en el README):

> Esta aplicación no es oficial del Banco Central de Bolivia.  
> La información se basa en datos públicos.

Este aviso debe mantenerse en todas las distribuciones del proyecto (APK, README, documentación).

---

## 6. Entregables del MVP

El MVP se considera completo cuando el proyecto incluye:

- Proyecto Flutter funcional.
- Estructura basada en **Clean Architecture** simplificada.
- **OCR funcional** para leer la serie desde la cámara.
- **Motor de validación offline** basado en rangos.
- **UI básica**:
  - Home, Escaneo, Ingreso manual, Resultado, Historial.
- Archivo de reglas local: `assets/rules/rules_v1.json`.

