## 1. Resumen del producto

BsCheck es una aplicación móvil Android que permite verificar rápidamente si un billete boliviano pertenece a un **rango de series inhabilitadas**, utilizando:

- Escaneo de cámara (OCR).
- Ingreso manual de la serie.

Está pensada para:

- Comerciantes.
- Cajeros.
- Personal de ventas.
- Usuarios comunes en general.

La app funciona **100% offline** para garantizar:

- Velocidad de respuesta.
- Disponibilidad incluso sin conexión a internet.

---

## 2. Objetivo del MVP

El MVP tiene como objetivo permitir que un usuario pueda:

1. **Escanear** la serie de un billete usando la cámara (OCR), o ingresarla manualmente.
2. **Verificar en menos de 1 segundo** si la serie pertenece a un rango inhabilitado.
3. Obtener un resultado claro:
   - **VÁLIDO**
   - **INHABILITADO**
   - **NO RECONOCIDO**

---

## 3. Alcance del MVP

### 3.1 Verificación de billetes

**Cortes soportados (MVP):**

- 10 Bs
- 20 Bs
- 50 Bs

**Serie soportada (MVP):**

- Serie **B**

### 3.2 Métodos de ingreso

- **Escaneo con cámara (OCR)**:
  - Usa la cámara del dispositivo para capturar la serie.
- **Ingreso manual**:
  - Usuario escribe la serie numérica del billete.

### 3.3 Funcionalidades mínimas

- Escaneo OCR de número de serie.
- Validación totalmente **offline**.
- Resultado inmediato.
- Ingreso manual de serie.
- Historial local de consultas.
- Funcionamiento sin conexión a internet.

---

## 4. Usuarios objetivo

**Usuarios primarios:**

- Comerciantes.
- Cajeros.
- Vendedores.
- Mercados.
- Bancos informales.

**Escenario típico:**

> Un comerciante recibe un billete y en **2 segundos** lo valida con BsCheck antes de aceptarlo.

---

## 5. Casos de uso principales

### Caso 1 — Escaneo con cámara

1. El usuario abre la app.
2. Toca **“Escanear billete”**.
3. La cámara detecta la serie del billete (OCR).
4. La app muestra el resultado:
   - ⚠ **Billete inhabilitado**, o  
   - ✔ **Billete válido**.

### Caso 2 — Ingreso manual

1. El usuario abre la app.
2. Toca **“Ingresar serie”**.
3. Introduce la serie, por ejemplo: `87280145`.
4. La app indica el resultado (por ejemplo, **Inhabilitado**).

---

## 6. Branding y mensaje

- **Nombre del producto**: BsCheck
- **Tagline**: *Verificador de billetes bolivianos*

Este branding debe reflejarse en:

- Nombre de la app que ve el usuario.
- Pantalla Home y README.

