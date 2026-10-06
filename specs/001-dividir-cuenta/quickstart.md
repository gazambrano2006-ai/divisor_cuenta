# Guía de validación después de implementar

Esta guía no acredita pruebas ejecutadas: en la fase de planificación solo se
han generado documentos. La aplicación existente sigue siendo la plantilla
Flutter del contador. Ejecutar ahora sus pruebas no comprobaría esta funcionalidad.

## Requisitos previos

- Usar el proyecto existente y el SDK Flutter en canal estable. En este equipo se
  comprobó Flutter 3.47.2 con Dart 3.13.2. Confirmar con `flutter --version`.
- Tener la aplicación implementada según [plan.md](plan.md) y un dispositivo o
  destino Flutter disponible para `flutter run`.
- Haber retirado `cupertino_icons`, `flutter_lints` y el include externo de análisis
  durante la implementación; mantener solo dependencias del SDK.
- Contar con autorización antes de crear o modificar pruebas en `test/`, como
  establece `AGENTS.md`. La prueba actual del contador no cubre dividir cuentas.

## Comandos desde la raíz del proyecto Flutter

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
```

`flutter run` abre la aplicación en un destino disponible; detener la ejecución
antes de continuar con los comandos siguientes. Para la verificación local puede
elegirse Windows o Chrome según las herramientas instaladas, sin modificar
`android/` ni `ios/`.

Resultados requeridos: resolución de dependencias del SDK correcta, aplicación
ejecutable, `flutter analyze` sin errores y todas las pruebas correctas. No
silenciar errores ni excluir `lib/` o `test/` del análisis para cumplir la comprobación.

## Trazabilidad de las pruebas ejecutables previstas

| Área crítica | Verificación necesaria | Casos y requisitos cubiertos |
|---|---|---|
| `ValidarEntrada` | Rechazar monto inválido, cero y negativos de personas; errores adicionales; admitir una persona y monto cero. | CA-003, CA-004; FR-008 a FR-010 y casos límite. |
| `CalcularDivision` | Fórmula de propina y división a partir de una Cuenta válida; delegación a una estrategia sustituible. | CA-001, CA-002, CA-005, CA-006; FR-004. |
| Ambas estrategias | Contrato común de fracción a centavos; Exacto al centavo con empate hacia arriba; Hacia arriba sobre cociente original; cero y entero. | FR-005, FR-006 y casos límite. |
| `FormateadorMoneda` | Dos cifras y punto en `27.50`, `3.33`, `4.00` y `0.00`; sin notación científica para importes grandes. | FR-007; SC-002. |
| `DivisorController` | Dependencias recibidas por constructor; error o resultado excluyentes; cambio de modo y recuperación. | FR-003, FR-010, FR-011. |
| `PantallaDivisor` | Ingresar datos, elegir modo, pulsar el botón y comprobar salida; sin resultado inicial ni cálculo automático. | CA-001 a CA-006; FR-001 a FR-003; SC-001 a SC-003, SC-005. |

Las pruebas de widgets seguirán el [contrato de pantalla](contracts/interfaz-pantalla.md)
y comprobarán los mensajes exactos y la ausencia de cualquier resultado en casos
inválidos. Las unitarias usarán los [contratos internos](contracts/contratos-internos.md),
con valores esperados derivados de la especificación, sin copiar la fórmula de
implementación dentro de la propia prueba.

Incluir especialmente una persona, cero monto, error después de un resultado
válido, recuperación, alternancia de modos, `1.005 → 1.01` en Exacto y
`3.001 → 4.00` en Hacia arriba. Una estrategia de prueba puede verificar la
delegación sin comprobar el tipo concreto usado por el cálculo.

## Comprobación de extremo a extremo

1. Abrir la aplicación y comprobar que solo hay una pantalla y ningún resultado inicial.
2. Ejecutar los seis casos del contrato de pantalla: exigir `6 de 6` correctos.
3. Después de un resultado válido, ejecutar CA-003 y CA-004: exigir el mensaje
   obligatorio y la desaparición del resultado previo en ambos casos.
4. Corregir los datos y volver a calcular; alternar los dos modos pulsando
   Calcular después de cada selección.
5. Preparar e instalar una compilación antes de desconectar el dispositivo;
   cerrarla, desactivar la conexión, volver a abrirla y repetir CA-001 a CA-006.
   Exigir `6 de 6` iguales, sin solicitar Internet. No depender de cargar una
   página web desde un servidor remoto para esa comprobación.

## Revisión de arquitectura y explicación del estudiante

Revisar imports: domain solo usa Dart; presentation importa contratos y entidades
de domain, nunca data; data importa el contrato de domain. La construcción de
dependencias de la aplicación debe estar en `main.dart`.

Comprobar que una regla nueva solo necesitaría implementarse y registrarse en
la composición, y que las reglas existentes comparten el contrato sin
comprobaciones de tipo. Revisar que la operación no usa red, persistencia ni secretos.

El estudiante debe explicar cada función con los cinco puntos de los contratos:
qué hace, por qué existe, qué recibe, qué devuelve y qué errores produce. Los
tests, el análisis y esa explicación se comprobarán cuando haya código; este
plan no sustituye esas verificaciones.
