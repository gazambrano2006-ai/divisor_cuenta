# Plan de implementación: Dividir la cuenta de un restaurante

**Branch**: `sdd` | **Date**: 2026-10-01 | **Spec**: [spec.md](spec.md)

**Input**: `specs/001-dividir-cuenta/spec.md` y las decisiones técnicas del usuario.

El script de preparación identifica la funcionalidad como `001-dividir-cuenta` por
su directorio. La rama Git comprobada es `sdd`; no se cambia ni se crea otra rama.

## Resumen

Una pantalla Flutter permite ingresar monto, personas y propina, elegir Exacto o
Hacia arriba y tocar **Calcular**. Muestra el pago individual con dos decimales o
el error de entrada, ocultando cualquier resultado anterior si el cálculo es
inválido. Todo el uso funciona sin conexión, sin almacenamiento.

Se usará estado local con `setState`, las tres capas solicitadas y composición en
`main.dart`. El cálculo recibirá entradas validadas y delegará el redondeo a una
interfaz de domain. La validación y el formato tendrán responsabilidades propias.
Este documento y sus anexos son diseño; no implementan la aplicación.

## Contexto técnico

**Lenguaje y versión**: Dart 3.13.2 con null safety; Flutter 3.47.2, canal `stable`,
verificados mediante `flutter --version` en el SDK local. No se requiere actualizarlo.

**Dependencias**: Flutter y bibliotecas de Dart incluidas en el SDK. Para pruebas,
`flutter_test` del SDK. No se agregarán paquetes externos. La plantilla contiene
`cupertino_icons` y `flutter_lints`: la implementación futura deberá retirarlos de
`pubspec.yaml` y retirar el include de `flutter_lints` en `analysis_options.yaml`,
manteniendo el análisis estático con reglas del analizador. Ninguno se modifica ahora.

**Estado y almacenamiento**: entradas, modo y salida en el `State` de
`PantallaDivisor`; actualizaciones síncronas con `setState`. Sin red, base de datos,
archivos de cuentas ni persistencia.

**Pruebas**: pruebas unitarias de validación, fórmula, estrategias, formato y
orquestación; pruebas de widgets que conviertan CA-001 a CA-006 en verificaciones
ejecutables. `AGENTS.md` requiere autorización antes de modificar `test/`;
la planificación de esas pruebas no modifica esa carpeta ni concede autorización.

**Plataformas**: aplicación Flutter sobre las plataformas ya generadas en el
proyecto. Verificación local en Windows o Chrome; no se modifican `android/` ni `ios/`.

**Tipo de proyecto**: aplicación de una pantalla en el proyecto Flutter existente.

**Rendimiento**: cálculo local síncrono al pulsar el botón; la especificación no
establece objetivos numéricos de rendimiento.

**Restricciones**: nombres propios en español, domain sin Flutter ni paquetes
externos, un solo método en `EstrategiaRedondeo`, servicios construidos en
`main.dart`, sin funciones adicionales ni cambios nativos.

**Escala y alcance**: una cuenta actual, tres entradas, dos modos y una salida de
resultado o error. Sin distribución de sobrantes ni historial.

## Comprobación de la Constitución

La puerta previa a la investigación y la revisión posterior al diseño se evalúan
contra la Constitución 1.0.0. Los resultados siguientes certifican el diseño,
no la ejecución de pruebas de una aplicación todavía inexistente.

| Principio | Antes de fase 0 | Después de fase 1: evidencia del diseño |
|---|---|---|
| Calidad de código — SOLID | Compatible con separación y estrategias inyectadas. | SRP: validar, calcular, redondear y formatear separados. OCP: registro inyectado, sin ramas por tipo. LSP: contrato común de fracción a centavos. ISP: estrategia con un método. DIP: contratos de función de domain inyectados en presentation. |
| Arquitectura | Tres capas y composición exclusiva previstas. | `presentation → domain ← data`; domain solo usa Dart. `main.dart` construye y conecta los servicios, estrategias, controlador, formateador y pantalla. |
| Seguridad | No hacen falta secretos ni claves. | Sin integración externa ni credenciales; no se incorporan secretos al repositorio. |
| Calidad y pruebas | Los seis casos se pueden convertir en pruebas. | Trazabilidad de todos los casos y de las funciones críticas en [quickstart.md](quickstart.md); futura escritura de `test/` sujeta a autorización. |
| Regla de la materia | Responsabilidades y contratos explicables. | [Contratos internos](contracts/contratos-internos.md) indican qué hace cada función, por qué existe, entradas, salidas y errores. |

**Resultado previo y posterior**: diseño conforme, sin excepciones a la Constitución
y sin decisiones pendientes. Las pruebas y la revisión del código corresponden a
la fase de implementación autorizada.

## Estructura del proyecto

### Documentación de esta funcionalidad

```text
specs/001-dividir-cuenta/
  spec.md
  plan.md
  research.md
  data-model.md
  quickstart.md
  contracts/
    contratos-internos.md
    interfaz-pantalla.md
  checklists/requirements.md
```

`tasks.md` corresponde a un comando posterior y no se genera en esta fase.

### Código previsto en la raíz del proyecto

```text
lib/
  main.dart
  domain/
    cuenta.dart
    resultado.dart
    calcular_division.dart
    validar_entrada.dart
    estrategia_redondeo.dart
    contratos_divisor.dart
  data/
    redondeo_exacto.dart
    redondeo_hacia_arriba.dart
  presentation/
    divisor_controller.dart
    formateador_moneda.dart
    pantalla_divisor.dart
test/                         # solo cuando exista autorización para modificarla
  domain/
  data/
  presentation/
  widget_test.dart
```

**Decisión de estructura**: mantener el proyecto actual y usar exactamente las
clases solicitadas. `contratos_divisor.dart` contendrá únicamente alias de tipos
de función para la validación y el cálculo; no añade servicios ni clases. La capa
data implementará las reglas de redondeo solicitadas, sin repositorios ni acceso
a datos persistentes.

## Diseño y flujo de dependencias

1. `main.dart` crea `ValidarEntrada`, `CalcularDivision`, `RedondeoExacto`,
   `RedondeoHaciaArriba` y `FormateadorMoneda`. Inyecta las referencias a los métodos
   de validar y calcular, el formateador y el mapa de estrategias en
   `DivisorController`; después entrega el controlador a `PantallaDivisor`.
2. El mapa relaciona las etiquetas Exacto y Hacia arriba con
   `EstrategiaRedondeo`. La pantalla obtiene las opciones de ese registro. No habrá
   `switch`, `is` ni comparación de clases concretas para elegir una estrategia.
3. Al tocar Calcular, el controlador llama al contrato de validación. Si falla,
   devuelve el mensaje y ningún resultado. Si funciona, llama al contrato de
   cálculo con la `Cuenta` y la estrategia elegida, y entrega el `Resultado` al
   formateador. La pantalla aplica esa salida mediante `setState`.
4. El cálculo conserva una fracción exacta usando coeficientes decimales y
   `BigInt` del SDK. Solo la estrategia convierte la parte individual a centavos.
   El formateador escribe esos centavos con punto y dos cifras, sin redondear.

Los constructores de dependencias de la aplicación se invocan en `main.dart`,
sin dependencias por defecto creadas dentro de otras clases. `Cuenta` y
`Resultado` son valores producidos durante cada operación; los widgets y el
`State` del SDK siguen su ciclo de vida de Flutter. No son implementaciones de
servicios que deban registrarse en la composición.

Agregar una regla futura requeriría una nueva implementación y su registro en
`main.dart`, sin editar las clases existentes. Esta implementación tendrá solo
los dos modos solicitados.

## Fases y validación prevista

- **Fase 0 completada**: [research.md](research.md) resuelve estado, dependencias,
  precisión, contratos y composición.
- **Fase 1 completada**: [data-model.md](data-model.md), los
  [contratos internos](contracts/contratos-internos.md), el
  [contrato de pantalla](contracts/interfaz-pantalla.md) y
  [quickstart.md](quickstart.md) definen el diseño y su validación.
- **Implementación posterior**: crear las clases y conectar la pantalla; retirar
  los dos paquetes de la plantilla y ajustar las opciones de análisis. Convertir
  los casos en pruebas una vez autorizados los cambios en `test/`.
- **Verificación posterior**: `flutter pub get`, `flutter run`, `flutter analyze`
  y `flutter test`. Exigir análisis sin errores y pruebas de aceptación correctas;
  repetir los seis casos con la aplicación instalada y el dispositivo sin conexión.

No se ejecutan estos comandos de implementación para atribuir resultados al
diseño: la aplicación actual sigue siendo la plantilla del contador.
