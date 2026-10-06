# Investigación y decisiones técnicas

**Fecha**: 2026-10-01 | **Especificación**: [spec.md](spec.md)

## 1. SDK y dependencias

**Decisión**: usar el SDK estable instalado: Flutter 3.47.2 y Dart 3.13.2,
comprobados con `flutter --version`. Usar solo Flutter, Dart y `flutter_test` del
SDK; retirar `cupertino_icons` y `flutter_lints` durante la implementación futura.

**Motivo**: cumple la elección del usuario. La plantilla incluye ambos paquetes
externos y `analysis_options.yaml` importa las reglas de `flutter_lints`; esa
referencia se retirará junto con el paquete para mantener operativo el análisis.

**Alternativas consideradas**: conservar los paquetes de la plantilla o agregar
paquetes de estado, formato o decimales incumpliría la restricción. Actualizar el
SDK no es necesario para este diseño. No se modifica ningún archivo de SDK,
dependencias ni opciones de análisis en esta fase.

## 2. Estado local de una pantalla

**Decisión**: `PantallaDivisor` será un `StatefulWidget` con textos de entrada,
modo seleccionado, resultado y error locales. Se calcula al pulsar Calcular;
la actualización visible se aplica mediante `setState`.

**Motivo**: Flutter documenta que `setState` actualiza el estado de forma síncrona
y programa la reconstrucción. El cálculo se realizará antes del callback; este
solo asignará el nuevo estado. [API oficial de setState](https://api.flutter.dev/flutter/widgets/State/setState.html).

**Alternativas consideradas**: un gestor de estado externo no está permitido;
notificadores o un estado global no aportan nada al alcance de una pantalla.

## 3. DIP y composición sin clases adicionales

**Decisión**: domain declara dos contratos de función: `ValidacionEntrada` y
`DivisionCuenta`. `main.dart` crea los casos de uso y entrega referencias a sus
métodos al controlador, junto con el registro de estrategias y el formateador.

**Motivo**: el controlador depende de contratos de domain sin construir ni conocer
servicios concretos de data. Los alias de tipos permiten expresar contratos de
función en Dart. [Documentación oficial de typedefs](https://dart.dev/language/typedefs).

**Alternativas consideradas**: inyectar directamente clases concretas de casos de
uso debilita la interpretación explícita de DIP de la Constitución. Añadir una
interfaz y una clase de implementación para cada caso de uso duplicaría las
clases pedidas. Un localizador de servicios ocultaría las dependencias.

## 4. Precisión y redondeo

**Decisión**: conservar monto y propina como coeficiente entero y escala decimal,
y personas como entero `BigInt`. Calcular una fracción de `BigInt` sin convertirla
a `double`. El único método de la estrategia recibe numerador y denominador y
devuelve centavos enteros. `Resultado` contiene esos centavos.

**Motivo**: `BigInt` está incluido en `dart:core` y sus enteros tienen precisión
arbitraria, limitada por la memoria disponible. [API oficial de BigInt](https://api.dart.dev/dart-core/BigInt-class.html).
Esta representación permite aplicar exactamente el empate hacia arriba al
centavo y el techo del cociente original, sin imponer un máximo arbitrario.

**Alternativas consideradas**: `double` es binario IEEE 754 y no representa
exactamente todos los decimales. [API oficial de double](https://api.dart.dev/dart-core/double-class.html).
Además, `toStringAsFixed` usa notación exponencial para magnitudes desde `10^21`,
por lo que no garantiza el formato exigido en todo el alcance.
[API oficial de toStringAsFixed](https://api.dart.dev/dart-core/num/toStringAsFixed.html).
Usar una tolerancia fija altera decisiones en los límites; redondear las entradas
a dos cifras o el total antes de dividir perdería precisión. Un paquete decimal
externo está excluido por el usuario.

No se crea una clase decimal adicional: los campos de `Cuenta` almacenan los
coeficientes y escalas. El formato trabaja directamente sobre los centavos.

## 5. Selección de estrategias y salida del controlador

**Decisión**: inyectar un mapa inmutable de etiquetas y `EstrategiaRedondeo`;
obtener las opciones del mapa y buscar la elegida por clave. Devolver un record
con `String? resultado` y `String? error`, con una sola salida no nula por cálculo.

**Motivo**: las opciones no dependen del tipo concreto de estrategia. Se puede
registrar otra implementación en la composición sin editar las clases. Los
records son valores tipados e inmutables que permiten devolver varios campos
sin otra clase. [Documentación oficial de records](https://dart.dev/language/records).

**Alternativas consideradas**: un enum con un `switch` central obligaría a editar
las clases para una nueva regla; devolver ambos textos simultáneamente permitiría
mostrar un resultado inválido. No se necesita otra clase de estado.

## 6. Pruebas y restricciones del proyecto

**Decisión**: planificar pruebas unitarias y de widgets con las herramientas del
SDK, con trazabilidad de CA-001 a CA-006 y de los casos límite. No escribir pruebas
ni código ahora. Antes de modificar `test/`, debe existir la autorización que
exige `AGENTS.md`.

**Motivo**: la Constitución exige pruebas ejecutables para la funcionalidad
crítica, y el usuario ha limitado esta fase al plan. La prueba del contador actual
deberá reemplazarse cuando se autorice la fase correspondiente.

**Alternativas consideradas**: conformarse con pruebas manuales incumpliría la
Constitución; modificar ahora `test/` excedería esta petición. La comprobación sin
conexión se hará además sobre una compilación instalada, pues la preparación del
SDK con `flutter pub get` puede necesitar descargar artefactos del SDK.

**Pendientes de investigación**: ninguno. La autorización futura para cambios en
`test/` es una condición de ejecución documentada, no una decisión de diseño sin resolver.
