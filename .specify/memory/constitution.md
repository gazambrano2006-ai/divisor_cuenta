<!--
Informe de impacto de sincronización (material temporal de revisión)
- Versión: plantilla sin versión → 1.0.0; adopción inicial.
- Principios definidos: Calidad de código; Arquitectura; Seguridad;
  Calidad y pruebas; Regla de la materia.
- Secciones añadidas: contenido de los cinco principios solicitados.
- Secciones omitidas: restricciones adicionales y flujo de desarrollo de la
  plantilla, porque el usuario no ha definido otros principios.
- Gobernanza: no se añaden políticas ni obligaciones distintas de las solicitadas.
- Archivos relacionados: plantillas y código de la aplicación sin cambios.
- Pendientes: ninguno.
Este informe es temporal y debe retirarse antes de confirmar el documento en Git.
-->

# participacion7 Constitution

## Core Principles

### I. Calidad de código

El código respeta SOLID:

- **SRP**: una clase, una razón de cambio. El cálculo no valida ni formatea.
- **OCP**: agregar una nueva regla de redondeo no obliga a editar las clases existentes.
- **LSP**: cualquier implementación de una interfaz puede sustituir a otra sin
  comprobar su tipo.
- **ISP**: interfaces pequeñas, sin métodos innecesarios.
- **DIP**: presentation depende de abstracciones de domain, nunca de clases
  concretas de data.

### II. Arquitectura

- Capas: presentation, domain y data.
- Dependencias: `presentation → domain ← data`.
- Domain no puede importar Flutter.
- `main.dart` es el único lugar donde se instancian implementaciones concretas.

### III. Seguridad

Nunca guardar secretos ni claves de API en el repositorio.

### IV. Calidad y pruebas

- Toda funcionalidad crítica debe tener pruebas.
- Los criterios de aceptación deben convertirse en pruebas ejecutables.

### V. Regla de la materia

El estudiante debe poder explicar cada función generada: qué hace, por qué existe,
qué recibe, qué devuelve y qué errores produce.

## Governance

El contenido normativo de esta constitución se limita a los cinco principios
solicitados por el usuario. No se establecen otros principios ni reglas adicionales.

**Version**: 1.0.0 | **Ratified**: 2026-10-01 | **Last Amended**: 2026-10-01
