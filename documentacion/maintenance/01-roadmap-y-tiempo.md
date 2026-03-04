## 1. Roadmap futuro (Versión 2 y más allá)

Basado en el PRD, la siguiente versión (v2) podría incluir:

- **Reconocimiento automático de corte**  
  Detectar el valor del billete (10, 20, 50, etc.) directamente desde la imagen, sin que el usuario lo seleccione.

- **Detección de billetes falsos**  
  Añadir heurísticas o modelos adicionales para detectar falsificaciones, no solo rangos inhabilitados oficiales.

- **Actualización automática de reglas**  
  Permitir que la app descargue periódicamente un nuevo `rules_vX.json` desde una fuente oficial o mantenida por la comunidad.

- **Soporte para otros países y monedas**  
  Extender el modelo de datos y la UI para soportar billetes de otros países.

---

## 2. Tiempo estimado de desarrollo (MVP)

El PRD establece una estimación orientativa:

- **Tiempo estimado**: 6–8 horas  
  (para un agente/configuración altamente automatizada y con experiencia en Flutter/Android).

En un entorno real de desarrollo, el tiempo puede variar según:

- Profundidad de pruebas en dispositivos reales.
- Esfuerzo de diseño gráfico adicional.
- Integraciones futuras (actualización de reglas, otros países, etc.).

