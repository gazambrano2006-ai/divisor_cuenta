# Guía de ejecución y evidencia de validación

**Verificado**: 2026-10-06, durante `/speckit-implement`.
**Proyecto**: aplicación de una pantalla para dividir la cuenta.
**SDK**: Flutter 3.47.2, canal estable; Dart 3.13.2.

La aplicación está implementada según [plan.md](plan.md), con estado local mediante
`setState`, las capas acordadas y composición de los servicios en `lib/main.dart`.
Se retiraron `cupertino_icons` y `flutter_lints`; las dependencias directas son
únicamente Flutter y `flutter_test` del SDK. Domain utiliza solo Dart.

## Ejecutar desde la raíz del proyecto

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
```

Para Android, elegir un dispositivo conectado o iniciar el emulador existente
Pixel_7. Los valores se calculan solo al pulsar Calcular. Los errores ocultan
cualquier resultado anterior; corregir y volver a calcular recupera la salida.
Los dos modos son Exacto y Hacia arriba, ambos con dos cifras decimales.

En esta sesión `flutter run -d emulator-5554 --release` compiló, instaló y abrió
la aplicación Android. El APK generado en `build/app/outputs/flutter-apk/app-release.apk`
corresponde a la arquitectura x86_64 del emulador de validación; no se presenta
como una compilación para teléfonos ARM.

## Resultados de los comandos

| Comprobación | Resultado observado |
|---|---|
| `flutter pub get` | Correcto; dependencias directas del SDK. |
| `flutter run -d emulator-5554 --release` | Compilación, instalación y apertura correctas en Pixel_7. |
| `flutter run -d chrome --release --no-web-resources-cdn --web-port=7357 --web-hostname=127.0.0.1` | Compilación web y apertura en Chrome correctas; seis casos confirmados manualmente por el usuario. |
| `flutter analyze` | `No issues found!` |
| `flutter test` | 131 pruebas correctas. |
| `dart format --output=none --set-exit-if-changed lib test` | 20 archivos comprobados, cero cambios pendientes. |

Las pruebas se escribieron antes de sus implementaciones: hubo ejecuciones rojas
controladas de validación, US1, US2 y US3, seguidas por sus comprobaciones verdes.
La suite final verifica validación, fórmula, precisión decimal, ambas estrategias,
formato, orquestación, pantalla, recuperación y el funcionamiento con HTTP bloqueado.

## Los seis escenarios en Android sin conexión

Se comprobó el APK release instalado en el emulador Pixel_7, serial
`emulator-5554`, después de cerrar la aplicación y activar modo avión, con WiFi y
datos móviles apagados. El sistema indicó `Active default network: none` antes
de abrir la aplicación. Se realizaron los casos sobre la interfaz real mediante
las herramientas del SDK Android, sin paquetes de integración.

| Caso | Entradas: monto / personas / propina / modo | Salida observada |
|---|---|---|
| CA-001 | `100.00 / 4 / 10 / Exacto` | `27.50 por persona` |
| CA-002 | `90.00 / 3 / 0 / Exacto` | `30.00 por persona` |
| CA-003 | `50.00 / 0 / 0 / Exacto` | `Debe haber al menos una persona`, sin resultado |
| CA-004 | `abc / 3 / 0 / Exacto` | `Monto inválido`, sin resultado |
| CA-005 | `10.00 / 3 / 0 / Exacto` | `3.33 por persona` |
| CA-006 | `10.00 / 3 / 0 / Hacia arriba` | `4.00 por persona` |

**Resultado**: 6/6 correctos. CA-003 y CA-004 se ejecutaron cada uno después de
obtener `27.50`: ambos eliminaron el resultado previo. Los seis casos también
pasaron como pruebas de widgets con creación de clientes HTTP bloqueada.
La conectividad del emulador se restauró a su estado original después de la prueba.

La evidencia local reproducible queda en
`build/verificacion/android-sin-conexion/`: `resultado.json`,
`conectividad-sin-conexion.json`, `registro.txt`, capturas PNG y árboles XML.
Los registros de pruebas se encuentran en `build/verificacion/pruebas-finales.log`.
Estos artefactos de validación están excluidos de Git por el ignore de `build/`.

## Trazabilidad y revisión de arquitectura

| Área crítica | Pruebas y comprobación |
|---|---|
| `ValidarEntrada` | Entradas válidas, precisión, mensajes exactos, cero personas, negativos y otros inválidos; orden de validación. |
| `CalcularDivision` | Propina, división y delegación de la fracción original; no valida ni formatea. |
| Estrategias | Exacto al centavo con empate superior; techo sobre cociente original, cero y enteros; importes grandes. |
| `FormateadorMoneda` | Punto y dos decimales, ceros necesarios y valores grandes sin notación científica. |
| `DivisorController` | Dependencias inyectadas, selección genérica, salida excluyente y errores de programación no ocultados. |
| `PantallaDivisor` | Seis casos, una persona, cero monto, recuperación, resultado previo, alternancia y ausencia de cálculo automático. |
| Sin conexión | Seis casos con HTTP bloqueado y seis casos en APK Android iniciado sin red. |

SC-001 a SC-005 se cumplen en estas comprobaciones: seis escenarios, dos cifras,
errores sin resultado previo, uso sin conexión y todo el flujo en una pantalla.
Los imports respetan `presentation → domain ← data`; presentation no importa data.
La nueva estrategia Hacia arriba se añadió sin cambiar las clases existentes.
Las implementaciones de servicios se construyen únicamente en `main.dart`.
Los 59 archivos fuente y recursos nativos originales comprobados por hash no
cambiaron; no se modificó código de `android/` ni de `ios/`.

La explicación de cada función está en los comentarios del código y en los
[contratos internos](contracts/contratos-internos.md): qué hace, por qué existe,
qué recibe, qué devuelve y qué errores produce.

## Alcance de la verificación

Se verificó Android en el emulador, la interfaz en Chrome y las pruebas del SDK
en Windows. No se afirma
una ejecución en un teléfono físico ni en iOS. El destino de escritorio Windows
requiere Visual Studio, ausente en este equipo; esto no impidió la compilación y
verificación Android. Preparar dependencias y compilar puede requerir descargas;
la aplicación instalada se comprobó sin conexión.

## Verificación Chrome — T040

El 2026-10-06 se ejecutó desde la raíz del proyecto:

```powershell
flutter run -d chrome --release --no-web-resources-cdn --web-port=7357 --web-hostname=127.0.0.1
```

La compilación web terminó correctamente y se abrió la aplicación en Chrome en
`http://127.0.0.1:7357`. El usuario comprobó los siguientes casos en esa ventana
mediante los campos, el selector y el botón Calcular, y confirmó en la sesión:
**"Salio lo esperado"**.

| Caso | Monto / personas / propina / modo | Resultado confirmado por el usuario |
|---|---|---|
| CA-001 | `100.00 / 4 / 10 / Exacto` | `27.50` por persona |
| CA-002 | `90.00 / 3 / 0 / Exacto` | `30.00` por persona |
| CA-003 | `50.00 / 0 / 0 / Exacto` | `Debe haber al menos una persona`, sin resultado |
| CA-004 | `abc / 3 / 0 / Exacto` | `Monto inválido`, sin resultado |
| CA-005 | `10.00 / 3 / 0 / Exacto` | `3.33` por persona |
| CA-006 | `10.00 / 3 / 0 / Hacia arriba` | `4.00` por persona |

La comprobación solicitada y confirmada incluyó repetir CA-003 y CA-004 después
de obtener `27.50`, verificando que desaparece ese resultado previo. Resultado:
**6/6 casos correctos por comprobación manual del usuario en Chrome**.

El control automático de Chrome no estuvo disponible: la conexión de navegador
no exponía Chrome y el helper de ventanas informó que su pipe nativo no existía.
Los intentos del runner web del SDK con JavaScript y WebAssembly permanecieron
en la carga inicial y se detuvieron sin ejecutar pruebas; no se contabilizan
como pruebas aprobadas. Sus registros quedaron en `build/verificacion/`.
Las 131 pruebas aprobadas que constan arriba corresponden a la suite del SDK
ejecutada y validada durante la implementación inicial.

Esta verificación manual cierra el destino Chrome previsto por el plan, sin
cambiar código, dependencias ni carpetas nativas. La apertura y operación sin
conexión siguen acreditadas por el APK Android y las pruebas con HTTP bloqueado;
no se atribuye una comprobación de apertura sin conexión a Chrome.
