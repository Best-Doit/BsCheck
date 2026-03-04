## UI del MVP

La UI del MVP se compone de cuatro pantallas principales:

| Pantalla   | Descripción                                                                 |
|-----------|------------------------------------------------------------------------------|
| Home      | Acceso rápido a *Escanear billete*, *Ingresar serie* y *Historial*.         |
| Escaneo   | Vista de cámara con overlay para alinear la serie y acción de capturar.     |
| Resultado | Muestra si el billete es válido, inhabilitado o no reconocido.              |
| Historial | Lista con fecha, serie, resultado y corte de las verificaciones pasadas.    |

---

## 1. Home

Elementos:

- Título: **BsCheck**.
- Texto descriptivo: “Verificador de billetes bolivianos”.
- Botones:
  - **Escanear billete** (acción principal, botón prominente).
  - **Ingresar serie** (botón secundario).
  - **Historial** (botón de texto).

Objetivo:

- Minimizar toques y tiempo para validar un billete en un escenario real de uso (comercio, mercado, etc.).

---

## 2. Pantalla de escaneo

Elementos:

- Vista previa de la cámara (cámara trasera).
- Overlay rectangular donde se debe alinear la serie del billete.
- Mensaje sobreimpreso:

> Alinea la serie del billete dentro del recuadro

- Botón inferior:
  - **“Capturar y validar”**:
    - Captura un frame.
    - Ejecuta OCR.
    - Valida la serie y navega a la pantalla de resultado.

Comportamiento esperado:

- Si la serie se reconoce y es válida/inválida → mostrar resultado acorde.
- Si no se puede extraer una serie → mostrar estado **NO RECONOCIDO**.

---

## 3. Pantalla de resultado

Debe mostrar de forma clara y rápida:

- Estado del billete:
  - ✔ **Billete válido** (color verde).
  - ⚠ **Billete inhabilitado** (color rojo/ámbar).
  - ❓ **No reconocido** (color gris/neutro).
- Detalles:
  - Serie numérica.
  - Corte (10 / 20 / 50 Bs).
  - Serie letra (en MVP: “B”).

Acciones:

- Botón **Volver** para regresar al flujo anterior (normalmente Home).
- (Opcional en futuras versiones) Acción para volver a escanear o validar otro billete directamente.

---

## 4. Pantalla de historial

Elementos:

- Lista de entradas con:
  - Serie.
  - Fecha y hora de verificación.
  - Corte y serie letra.
  - Resultado (VÁLIDO / INHABILITADO / NO RECONOCIDO) con color.

Orden:

- Las entradas más recientes deben aparecer **arriba**.

Uso:

- Permite al usuario revisar verificaciones recientes en caso de duda o auditoría básica.

