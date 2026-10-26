# Respuestas — Deber 3

## 1. Rojo antes de verde

**¿Qué mensaje de error mostró `flutter test` en la Parte 2? ¿Por qué era importante ver esa prueba fallar antes de escribir el código?**

Al ejecutar `flutter test`, falló la prueba de la propina del 150 %. Se esperaba que el programa devolviera el mensaje **"La propina no puede superar el 100%"**, pero en lugar de eso aceptó la entrada y devolvió una cuenta.

Era importante ver ese error antes de modificar el código porque así comprobé que la prueba realmente detectaba el problema. Después agregué la validación y la prueba pasó. De esta manera pude seguir el ciclo TDD: primero rojo y después verde.

## 2. Linter vs. IA

**¿Qué aviso mostró `flutter analyze` y qué code smell señaló la IA? ¿Por qué el linter no encontró ese code smell?**

Al ejecutar `flutter analyze`, aparecieron dos avisos que provoqué temporalmente para comprobar cómo funciona el linter:

- `unused_local_variable`: había una variable declarada que no se utilizaba.
- `avoid_print`: había un `print('hola')` dentro del código.

Después eliminé esas líneas y el análisis terminó con `No issues found!`.

Por otro lado, Codex encontró un code smell en `lib/domain/calcular_division.dart`. Las variables `escalaMonto` y `escalaPropina` tenían nombres poco claros, porque representaban factores calculados con potencias de 10 y podían confundirse con la cantidad de decimales.

El linter no detectó ese problema porque los nombres eran válidos y el código funcionaba. Sin embargo, para una persona que lea el código, esos nombres podían ser confusos. El linter detecta reglas específicas, mientras que la IA también puede señalar problemas de claridad y mantenimiento.

## 3. Mi refactorización

**¿Qué code smell elegiste, qué cambió en el código y cómo sabes que la aplicación sigue haciendo exactamente lo mismo?**

Elegí el code smell de los nombres ambiguos en `lib/domain/calcular_division.dart`.

Cambié dos nombres:

- `escalaMonto` por `factorEscalaMonto`.
- `escalaPropina` por `factorEscalaPropina`.

Hice este cambio porque las variables representan factores de escala, no directamente la cantidad de decimales. Los nombres nuevos ayudan a entender mejor la fórmula.

No cambié ninguna operación, condición ni cálculo. Solamente cambiaron los nombres de las variables.

Después ejecuté `flutter test` y las **143 pruebas siguieron pasando**. También revisé el `git diff` y comprobé que únicamente se habían cambiado esos nombres. Por eso puedo decir que la refactorización mejoró la claridad del código sin modificar su comportamiento.

## 4. Coverage

**¿Qué archivo de `lib/` tiene el porcentaje más bajo? ¿Significa eso que ese archivo tiene errores?**

El archivo con menor cobertura fue `lib/main.dart`, con **81,8 %** de sus líneas cubiertas.

Como `flutter test --coverage` fallaba al ejecutar todas las pruebas juntas por un problema con el servicio de Dart, ejecuté las pruebas por grupos y después combiné los archivos de cobertura. Con ese procedimiento obtuve una cobertura global de **97,8 %** de las líneas registradas.

Que `main.dart` tenga una cobertura menor no significa necesariamente que tenga errores. Solo indica que algunas líneas de ese archivo no se ejecutaron durante las pruebas.

Esto puede pasar porque `main.dart` contiene código relacionado con el inicio de la aplicación, que no siempre se ejecuta cuando hacemos pruebas unitarias.

Por eso, considero que el coverage sirve para identificar qué partes del código se probaron, pero un porcentaje alto no garantiza que el programa esté libre de errores.