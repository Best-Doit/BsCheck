## BsCheck — Verificador de billetes bolivianos

**BsCheck** es una aplicación móvil Android **offline** para verificar si un billete boliviano pertenece a un rango de series inhabilitadas.

- **Plataforma**: Android (min. Android 8.0 / API 26)
- **Framework**: Flutter
- **Modo**: 100% offline (no requiere conexión)
- **Estado**: MVP funcional

---

## Características principales

- **Verificación de billetes bolivianos**:
  - Cortes soportados en el MVP: **10 Bs, 20 Bs, 50 Bs**
  - Serie soportada en el MVP: **Serie B**
- **Métodos de ingreso**:
  - Escaneo con cámara (OCR usando Google ML Kit).
  - Ingreso manual de la serie numérica.
- **Resultados claros**:
  - **VÁLIDO**: la serie no está en rangos inhabilitados.
  - **INHABILITADO**: la serie sí pertenece a un rango inhabilitado.
  - **NO RECONOCIDO**: el texto leído/ingresado no se puede interpretar como serie válida.
- **Historial local**:
  - Guarda consultas con fecha/hora, serie, resultado y corte.
  - Solo en el dispositivo (no se envía a ningún servidor).

---

## Arquitectura y diseño

- **Arquitectura**: Clean Architecture (simplificada)
  - `presentation`: pantallas, widgets y lógica de UI.
  - `application`: casos de uso (`ValidateSerialUseCase`) y providers.
  - `domain`: entidades y contratos de repositorio.
  - `data`: data sources (assets, Hive) y repositorios concretos.
- **Carpetas principales**:
  - `lib/core`: constantes y utilidades.
  - `lib/features/validation`: flujo de validación de billetes.
  - `lib/features/history`: manejo de historial local.
  - `assets/rules/rules_v1.json`: archivo de reglas (rangos de series inhabilitadas).

Más detalles funcionales están documentados en:

- `documentacion/planning/` (visión de producto, alcance MVP, requisitos).
- `documentacion/development/` (arquitectura técnica, estructura y modelo de datos).
- `documentacion/design/` (UI del MVP).
- `documentacion/progress/` (historial de sprints y avances).

---

## Flujo de uso en la app

### 1. Pantalla Home

Al abrir BsCheck verás tres acciones principales:

- **Escanear billete**  
  Abre la cámara para capturar la serie del billete y validarla.

- **Ingresar serie**  
  Permite escribir manualmente la serie numérica del billete.

- **Historial**  
  Muestra las últimas verificaciones realizadas en este dispositivo.

### 2. Escanear billete (OCR)

1. Toca **“Escanear billete”**.
2. Alinea la serie del billete dentro del recuadro en pantalla.
3. Toca **“Capturar y validar”**.
4. La app:
   - Lee la imagen con la cámara.
   - Aplica OCR (Google ML Kit).
   - Extrae candidatos numéricos (regex `[0-9]{7,9}`).
   - Escoge el más probable y lo valida contra los rangos locales.
5. Verás una pantalla de **Resultado** con:
   - Estado (VÁLIDO / INHABILITADO / NO RECONOCIDO).
   - Serie detectada.
   - Corte y serie letra (en el MVP, serie fija “B”).

### 3. Ingresar serie manualmente

1. Toca **“Ingresar serie”**.
2. Selecciona el **corte**: 10 Bs, 20 Bs o 50 Bs.
3. Escribe la serie numérica (ejemplo: `87280145`).
4. Toca **“Validar”**.
5. La app convierte el texto a número, lo valida offline y muestra la pantalla de resultado.

### 4. Historial

1. Toca **“Historial”** en la pantalla Home.
2. Verás una lista con:
   - **Serie** (o “(sin serie)” si no se reconoció).
   - **Fecha y hora** de la consulta.
   - **Corte** y **serie letra**.
   - **Resultado** con color:
     - Verde: VÁLIDO.
     - Rojo: INHABILITADO.
     - Gris: NO RECONOCIDO.

Todo el historial se guarda **solo en el dispositivo**, usando Hive.

---

## Instalación y actualizaciones (APK desde GitHub)

Este proyecto está pensado como **open source** y se puede distribuir sin Play Store.

### 1. Requisitos en el teléfono

- Android 8.0 (API 26) o superior.
- Activar la opción para instalar apps desde fuentes externas:
  - En muchas versiones:  
    `Ajustes → Seguridad → Instalar apps desconocidas`  
    Permitir para el navegador / gestor de archivos que usarás.

### 2. Instalación inicial (usuario final)

1. Ve a la página de **Releases** del repositorio de BsCheck en GitHub.
2. Descarga el archivo `app-release.apk` de la última versión.
3. Abre el archivo APK descargado en tu teléfono.
4. Acepta los permisos solicitados (cámara) cuando se te pidan.

La app quedará instalada como **BsCheck** en tu lista de aplicaciones.

### 3. Actualizar a una nueva versión

Cuando se publique una nueva versión:

1. Entra de nuevo a la sección de **Releases** en GitHub.
2. Descarga el nuevo `app-release.apk` (misma app, versión superior).
3. Instala el APK encima de la versión anterior:
   - Android detectará que es la **misma app** (misma firma).
   - Actualizará manteniendo datos locales (incluido historial).

> Nota: no desinstales la app si quieres conservar el historial; simplemente instala la nueva versión encima.

---

## Compilar y ejecutar desde código (para desarrolladores)

### 1. Requisitos locales

- Ubuntu (u otra distro Linux) con:
  - Flutter SDK instalado (`flutter doctor` sin errores críticos).
  - Android SDK + herramientas de línea de comandos (`sdkmanager`).
  - Java JDK 17.
- Dispositivo Android con:
  - **Opciones de desarrollador** activadas.
  - **Depuración USB** activada.

### 2. Clonar el repositorio

```bash
git clone https://github.com/Best-Doit/bscheck.git
cd bscheck
```

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Ejecutar en un dispositivo

1. Conecta el teléfono por USB y acepta la depuración.
2. Verifica que `adb` ve el dispositivo:

```bash
adb devices
```

3. Lanza la app en modo debug:

```bash
flutter run
```

---

## Build de APK release (para publicar en GitHub)

> Importante: para distribución real, deberías firmar el APK con tu **propio keystore**.  
> Mientras tanto, puedes usar la firma debug para pruebas internas.

### 1. Build rápida (debug signing, pruebas)

```bash
flutter build apk --release
```

El archivo se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Ese APK se puede subir a **GitHub Releases** como binario para instalación manual.

### 2. Build firmada con keystore propio (recomendado)

Pasos generales (resumen):

1. Crear un keystore:

```bash
cd android
keytool -genkey -v -keystore bscheck-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bscheck
```

2. Configurar `key.properties` y la firma en `android/app/build.gradle.kts`.  
3. Ejecutar:

```bash
cd ..
flutter build apk --release
```

Después de eso, el APK firmado se distribuye igual que antes (por GitHub o tu canal preferido).

---

## Seguridad y privacidad

- La app **no** recopila datos personales.
- Solo almacena en el dispositivo:
  - Series de billetes verificadas.
  - Fecha/hora de la verificación.
  - Resultado (VÁLIDO / INHABILITADO / NO RECONOCIDO).
- No se envían datos a servidores externos.

**Aviso importante** (definido en el PRD):

> Esta aplicación no es oficial del Banco Central de Bolivia.  
> La información se basa en datos públicos.

Se recomienda mostrar este aviso dentro de la propia app (por ejemplo, en un diálogo “Acerca de”).

---

## Contribuir

Como proyecto open source, se aceptan mejoras y correcciones:

- Issues con:
  - Bugs detectados.
  - Problemas con OCR en ciertos dispositivos.
  - Rango de reglas a actualizar.
- Pull Requests con:
  - Mejoras de UI/UX.
  - Nuevas reglas de series (manteniendo formato JSON).
  - Optimizaciones de performance o arquitectura.

Por favor, revisa la documentación en `documentacion/` (especialmente `planning/` y `development/`) antes de proponer cambios que afecten al comportamiento principal.

---

## Licencia y marca

- El código de BsCheck se publica bajo la licencia **Apache 2.0** (ver archivo `LICENSE`).
- Están permitidos los forks y modificaciones respetando la licencia.
- **No está permitido** usar el nombre **“BsCheck”**, el logo original o presentarse como la app oficial de Best-Doit o del Banco Central de Bolivia en apps derivadas, salvo autorización expresa.

Si publicas un fork:

- Cambia **nombre**, **icono** y **descripciones** para dejar claro que es un proyecto derivado.
- Incluye crédito a este repositorio original (`Best-Doit/BsCheck` en GitHub).

