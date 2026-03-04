# Guía de instalación — Entorno Android (sin Android Studio)

Entorno para desarrollar **BsCheck** en Flutter para Android en **Ubuntu 24.04**, sin instalar Android Studio.

---

## Estado actual de tu sistema (revisión)

| Componente        | Estado        | Notas                    |
|------------------|---------------|--------------------------|
| **Flutter**      | No instalado  | —                        |
| **Dart**         | No instalado  | Viene con Flutter        |
| **Android SDK**  | No instalado  | ANDROID_HOME vacío       |
| **ADB**          | No instalado  | Parte de platform-tools  |
| **Java (JDK)**   | No instalado  | Necesario para compilar  |

---

## Resumen de pasos

1. Dependencias del sistema (apt)
2. Java (OpenJDK 17)
3. Flutter SDK
4. Android SDK (solo command-line tools)
5. Variables de entorno
6. Licencias Android
7. Verificación con `flutter doctor`

---

## 1. Dependencias del sistema

Instala paquetes necesarios para Flutter y compilación en Linux:

```bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config
```

Para Android (bibliotecas 32-bit y otras):

```bash
sudo apt-get install -y libc6 libstdc++6 lib32z1 libbz2-1.0
```

Opcional para desarrollo desktop Linux con Flutter:

```bash
sudo apt-get install -y libgtk-3-dev liblzma-dev libstdc++-12-dev
```

---

## 2. Java (JDK)

Flutter/Android necesita JDK para compilar. Usa OpenJDK 17 (recomendado para Android):

```bash
sudo apt install -y openjdk-17-jdk
```

Comprueba:

```bash
java -version
# Debe mostrar openjdk 17.x.x
javac -version
```

---

## 3. Flutter SDK

### Opción A — Snap (recomendada en Ubuntu)

```bash
sudo snap install flutter --classic
```

Luego añade Flutter al PATH si no se añade solo. Comprueba con:

```bash
which flutter
flutter --version
```

Si `which flutter` no encuentra nada, añade manualmente (Snap suele instalar en `/snap/bin`):

```bash
echo 'export PATH="/snap/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Opción B — Manual (versión concreta, p. ej. 3.24 para BsCheck)

Crea carpeta y descarga el SDK estable para Linux:

```bash
mkdir -p ~/develop
cd ~/develop
# Revisa la última estable en: https://docs.flutter.dev/release/archive
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz
tar -xf flutter_linux_3.24.5-stable.tar.xz
```

Añade Flutter al PATH (bash):

```bash
echo 'export PATH="$HOME/develop/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verifica:

```bash
flutter --version
dart --version
```

---

## 4. Android SDK (sin Android Studio)

Se usan solo las **Android Command Line Tools** y luego `sdkmanager` para instalar lo necesario.

### 4.1 Crear estructura de carpetas

```bash
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk
```

### 4.2 Descargar Command Line Tools

Página oficial:  
https://developer.android.com/studio#command-tools  

En “Command line tools only”, elige **Linux**.

Enlace directo (puede cambiar; si falla, descarga desde la página):

```bash
cd ~/Android/Sdk
# Ejemplo con versión reciente (comprueba la URL actual en developer.android.com)
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*_latest.zip
rm commandlinetools-linux-*_latest.zip
```

### 4.3 Estructura que espera Flutter/sdkmanager

El contenido de `cmdline-tools` debe estar en `cmdline-tools/latest/`:

```bash
cd ~/Android/Sdk
mkdir -p cmdline-tools
mv cmdline-tools cmdline-tools-temp 2>/dev/null || true
# Si al descomprimir obtuviste una carpeta "cmdline-tools":
mv cmdline-tools-temp cmdline-tools 2>/dev/null || true
# Si dentro hay solo una carpeta (ej. "latest" o "12.0"), renómbrala/estructura así:
# cmdline-tools/
#   latest/
#     bin/
#     lib/
#     ...
ls cmdline-tools/
```

Si al descomprimir ves una sola carpeta tipo `cmdline-tools/12.0/` o similar:

```bash
cd ~/Android/Sdk
mkdir -p cmdline-tools
mv cmdline-tools/12.0 cmdline-tools/latest   # usa el nombre que tengas (12.0, 13.0, etc.)
```

Comprueba que exista:

```bash
~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --version
```

### 4.4 Instalar paquetes Android necesarios

Acepta licencias y instala platform-tools (incluye **ADB**), build-tools y una plataforma (API 34 para Android 14, adecuado para Flutter):

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

yes | sdkmanager --licenses

sdkmanager "platform-tools"
sdkmanager "build-tools;34.0.0"
sdkmanager "platforms;android-34"
```

Para BsCheck (Android mínimo API 26 según PRD) también puedes instalar:

```bash
sdkmanager "platforms;android-26"
```

Comprueba ADB:

```bash
adb version
```

---

## 5. Variables de entorno

Añade a `~/.bashrc` (o `~/.profile`) para que queden fijas:

```bash
# Flutter (si instalaste manual en ~/develop/flutter)
# export PATH="$HOME/develop/flutter/bin:$PATH"

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$PATH"
```

Aplica:

```bash
source ~/.bashrc
```

Comprueba:

```bash
echo $ANDROID_HOME
# Debe ser: /home/tu_usuario/Android/Sdk
which adb
# Debe apuntar a .../Android/Sdk/platform-tools/adb
```

---

## 6. Aceptar licencias de Android (Flutter)

Cuando Flutter y Android SDK estén instalados:

```bash
flutter doctor --android-licenses
```

Acepta todas las que pida (suele ser `y` + Enter).

Debes ver al final algo como: **All SDK package licenses accepted.**

---

## 7. Verificación final

```bash
flutter doctor -v
```

Salida esperada (sin Android Studio está bien):

- **Flutter**: OK  
- **Android toolchain**: OK (con “Android SDK at …” y “Android SDK built for …”)  
- **Android licenses**: OK  

Si aparece algo de “Android Studio not found” o “cmdline-tools”, es opcional para tu caso; lo importante es que **Android toolchain** y **Android licenses** estén en verde.

Prueba que vea un dispositivo o emulador (con dispositivo conectado por USB o emulador encendido):

```bash
flutter devices
```

---

## Resumen de comandos (copiar y pegar)

Orden sugerido (ajusta si ya tienes algo instalado):

```bash
# 1. Sistema
sudo apt-get update -y
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libc6 libstdc++6 lib32z1 libbz2-1.0

# 2. Java
sudo apt install -y openjdk-17-jdk

# 3. Flutter (Snap)
sudo snap install flutter --classic
echo 'export PATH="/snap/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 4. Android SDK
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*_latest.zip
# Ajustar estructura cmdline-tools/latest según lo que descomprimió (ver sección 4.3)

export ANDROID_HOME=$HOME/Android/Sdk
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
yes | sdkmanager --licenses
sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-34"

# 5. Variables en .bashrc
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 6. Licencias Flutter
flutter doctor --android-licenses

# 7. Verificación
flutter doctor -v
```

---

## Dispositivo físico (opcional)

1. En el móvil: **Ajustes → Acerca del teléfono → Toca 7 veces “Número de compilación”**.  
2. **Ajustes → Opciones de desarrollador**: activa **Depuración USB**.  
3. Conecta por USB y acepta “Permitir depuración USB” en el teléfono.  
4. Comprueba: `adb devices` y `flutter devices`.

---

## Emulador (opcional, sin Android Studio)

Con command line tools puedes instalar un system image y crear un AVD por consola:

```bash
sdkmanager "system-images;android-34;google_apis;x86_64"
# Crear AVD (nombre, device, imagen)
# Luego usar: emulator -avd NombreDelAVD
```

La creación del AVD desde línea de comandos es un poco más técnica; si más adelante quieres emulador, se puede detallar en otra sección.

---

## Referencias

- [Flutter – Install on Linux](https://docs.flutter.dev/install/linux)
- [Flutter – Android setup](https://docs.flutter.dev/platform-integration/android/setup)
- [Android – Command line tools](https://developer.android.com/studio#command-tools)
- [Android – sdkmanager](https://developer.android.com/tools/sdkmanager)

---

*Documento para el proyecto BsCheck — desarrollo Android sin Android Studio.*
