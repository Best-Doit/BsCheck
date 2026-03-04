# QA Checklist de Campo — BsCheck v1.0.0

Fecha: **/**/______  
Versión app: **1.0.0**  
Dispositivo: ____________________  
Android: ____________  
Tester: ____________________

---

## Criterio de aprobación

- `APTO`: todos los casos **críticos** pasan.
- `NO APTO`: falla al menos 1 caso crítico.

---

## 1. Arranque y onboarding

| ID    | Caso | Resultado esperado | Estado | Notas |
|-------|------|--------------------|--------|-------|
| QA-01 | Abrir app por primera vez | Muestra onboarding (4 slides) | | |
| QA-02 | Slide 1 — Condolencias | Icono oscuro, texto condolencia, fondo claro | | |
| QA-03 | Slide 2 — Serie B / BCB | Icono banco, texto BCB | | |
| QA-04 | Slide 3 — Escanea o escribe | Icono escáner, descripción | | |
| QA-05 | Slide 4 — Datos públicos | Botón "Comenzar" visible | | |
| QA-06 | Botón "Omitir" | Salta al Home directamente | | |
| QA-07 | Segunda apertura | No muestra onboarding, va directo a Home | | |

---

## 2. Home

| ID    | Caso | Resultado esperado | Estado | Notas |
|-------|------|--------------------|--------|-------|
| QA-08 | Pantalla Home | Header verde, banner BCB, 3 acciones, botón TikTok | | |
| QA-09 | Barra de estado | Iconos blancos sobre el header verde | | |
| QA-10 | Banner BCB | "Serie B · Banco Central de Bolivia" visible | | |
| QA-11 | Botón "ℹ Info" | Abre diálogo con descripción, características y link GitHub | | |
| QA-12 | Link GitHub en diálogo | Abre github.com/Best-Doit/BsCheck en el navegador | | |
| QA-13 | Botón TikTok | Abre tiktok.com/@best_doit en el navegador | | |
| QA-14 | NavigationBar inferior | Tabs: Inicio · Escanear · Manual · Historial visibles | | |

---

## 3. Escanear billete (OCR)

| ID              | Caso | Resultado esperado | Estado | Notas |
|-----------------|------|--------------------|--------|-------|
| QA-15           | Abrir escáner | Cámara se inicializa, fondo claro en UI | | |
| QA-16           | Botones de corte | 3 tarjetas grandes: 10 / 20 / 50 Bs, selección visual clara | | |
| QA-17           | Selector de corte | Al tocar cambia el corte activo (tarjeta verde seleccionada) | | |
| QA-18           | Preview cámara | Se ve sin distorsión (relación de aspecto correcta) | | |
| QA-19           | Marco de escaneo | Marco centrado con esquinas L-shape en verde | | |
| QA-20 (Crítico) | Flash Off/Auto/On | Cambia de estado correctamente con el botón | | |
| QA-21 (Crítico) | Flash al ir a Resultado | Linterna se apaga al navegar a resultado | | |
| QA-22 (Crítico) | Flash al salir de escáner | Linterna se apaga al salir de pantalla | | |
| QA-23 (Crítico) | Captura y validación | Detecta serie y muestra resultado correcto | | |
| QA-24           | Captura borrosa / sin serie | No rompe la app, muestra "NO RECONOCIDO" | | |

---

## 4. Ingreso manual

| ID              | Caso | Resultado esperado | Estado | Notas |
|-----------------|------|--------------------|--------|-------|
| QA-25           | Abrir manual | Header verde, iconos barra blancos, botones corte grandes | | |
| QA-26           | Botones de corte | 3 tarjetas grandes: 10 / 20 / 50 Bs | | |
| QA-27           | Campo serie | Acepta solo dígitos, muestra contador X/9 | | |
| QA-28           | Botón limpiar (✕) | Limpia el campo cuando hay texto | | |
| QA-29 (Crítico) | Validar serie 10 Bs inhabilitada | Ej: `80000000` → INHABILITADO | | |
| QA-30 (Crítico) | Validar serie 20 Bs inhabilitada | Ej: `87280145` → INHABILITADO | | |
| QA-31 (Crítico) | Validar serie 50 Bs inhabilitada | Ej: `85000000` → INHABILITADO | | |
| QA-32 (Crítico) | Validar serie válida | Serie fuera de rangos → VÁLIDO | | |
| QA-33           | Serie menor de 7 dígitos | Muestra error, no permite validar | | |
| QA-34           | Campo vacío | Muestra error "Ingresa la serie del billete" | | |

---

## 5. Resultado

| ID    | Caso | Resultado esperado | Estado | Notas |
|-------|------|--------------------|--------|-------|
| QA-35 | Resultado INHABILITADO | Hero rojo/naranja, ícono ⚠, texto claro | | |
| QA-36 | Resultado VÁLIDO | Hero verde, ícono ✓, texto "Billete aparentemente válido" | | |
| QA-37 | Resultado NO RECONOCIDO | Hero neutro, ícono ?, texto explicativo | | |
| QA-38 | Detalle: serie, corte, letra | Muestra los datos de la verificación | | |
| QA-39 | Botón "Nueva verificación" | Vuelve a la pantalla anterior (escáner o manual) | | |
| QA-40 | Botón "Volver al inicio" | Navega a Home | | |

---

## 6. Historial

| ID    | Caso | Resultado esperado | Estado | Notas |
|-------|------|--------------------|--------|-------|
| QA-41 | Historial vacío | Muestra estado vacío con ícono y mensaje descriptivo | | |
| QA-42 | Historial con datos | Lista agrupada por fecha (Hoy / Ayer / mes) | | |
| QA-43 | Estadísticas rápidas | Tarjetas: Válidos · Inhabilitados · Total | | |
| QA-44 | Badge de resultado | Verde=válido, Rojo=inhabilitado, Gris=no reconocido | | |
| QA-45 | Orden | Más reciente primero | | |
| QA-46 | Limpiar historial | Borra todos los registros correctamente | | |

---

## 7. Estabilidad general

| ID    | Caso | Resultado esperado | Estado | Notas |
|-------|------|--------------------|--------|-------|
| QA-47 | Rotar pantalla en escáner | No cierra la app | | |
| QA-48 | Minimizar y retomar | App continúa normalmente | | |
| QA-49 | Sin permisos de cámara | Muestra mensaje de error claro, no crashea | | |
| QA-50 | Uso prolongado (10 min) | No hay cierres ni pérdida de memoria visible | | |

---

## Resultado final

- Casos críticos aprobados: ____ / 10
- Total casos evaluados: ____ / 50
- Resultado global: `APTO / NO APTO`

**Observaciones:**
-
-
-
