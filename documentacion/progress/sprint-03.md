# Sprint 03 — OCR y flujo de escaneo

**Estado**: Planned  
**Periodo**: pendiente de definir

## Objetivo del sprint

Implementar el **flujo de escaneo con cámara + OCR** para obtener el número de serie del billete en el dispositivo y conectarlo con el motor de validación.

## Alcance

- [ ] Configuración de permisos y cámara
  - [ ] Añadir permisos de cámara en `AndroidManifest.xml`.
  - [ ] Configurar plugin `camera` para vista previa en pantalla.
- [ ] Pipeline OCR
  - [ ] Integrar `google_mlkit_text_recognition`.
  - [ ] Implementar extracción de texto desde fotogramas de la cámara.
  - [ ] Aplicar regex `[0-9]{7,9}` para filtrar candidatos.
  - [ ] Estrategia simple para elegir el mejor candidato (p.ej. más largo, posición en overlay).
- [ ] Integración con validación
  - [ ] Enviar el serial reconocido al `ValidateSerialUseCase`.
  - [ ] Mostrar el resultado en una pantalla de **Resultado**.

## Criterios de aceptación

- La pantalla de **Scan** muestra la cámara en vivo con un overlay guía.
- Cuando se detecta un serial válido, el usuario ve el resultado en < 1 s.
- Si el OCR no reconoce ningún patrón numérico válido, se muestra `NOT RECOGNIZED`.

