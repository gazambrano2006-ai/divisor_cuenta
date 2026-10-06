# Contratos internos y responsabilidades

Estos contratos describen la implementación futura. No contienen cuerpos de
servicios ni código de la aplicación. Referencias: [plan](../plan.md) y
[modelo de datos](../data-model.md).

## Contratos de función en domain

`contratos_divisor.dart` declarará dos alias de tipo, sin clases adicionales:

| Contrato | Entrada | Salida | Falla esperada |
|---|---|---|---|
| `ValidacionEntrada` | Tres parámetros `String` llamados `monto`, `personas` y `propina`. | `Cuenta` válida. | `ArgumentError` con `message` de tipo `String` correspondiente a la entrada inválida. |
| `DivisionCuenta` | `Cuenta cuenta` válida y `EstrategiaRedondeo estrategia`. | `Resultado` con centavos finales. | Ninguna para entradas que cumplen sus precondiciones. |

`ValidarEntrada.ejecutar` y `CalcularDivision.ejecutar` respetarán respectivamente
estos contratos. `main.dart` entregará las referencias a esos métodos al
constructor del controlador. Presentation podrá importar los contratos y
entidades de domain, pero no sus clases de servicios para construirlas ni data.

## EstrategiaRedondeo

Único método: `BigInt redondear(BigInt numerador, BigInt denominador)`.

- **Qué hace y por qué existe**: transforma la fracción del pago individual en
  centavos finales según una regla intercambiable.
- **Recibe**: numerador no negativo y denominador estrictamente positivo.
- **Devuelve**: centavos no negativos, expresados como `BigInt`.
- **Errores**: ninguno para entradas válidas. Una llamada fuera de las
  precondiciones es un error de programación, no una entrada de usuario que la
  estrategia deba validar. La interfaz no tiene métodos de validación, etiquetas
  ni formato.

Las implementaciones comparten precondiciones y unidad de salida. CalcularDivision
invoca el método abstracto, sin comprobar el tipo de estrategia.

### RedondeoExacto — data

Tomando `N` y `D` como los argumentos, obtener el cociente entero `q` y el residuo
`r` de `100 × N` dividido entre `D`. Si `2 × r` es mayor o igual que `D`, el
resultado es `q + 1` centavos; en otro caso, `q` centavos. No se trunca siempre ni
se redistribuyen sobrantes. Los empates van al centavo superior.

Ejemplos del contrato: `10 / 3 → 333` centavos; `1005 / 1000 → 101` centavos;
`0 / 1 → 0` centavos.

### RedondeoHaciaArriba — data

Obtener el cociente entero `q` y el residuo `r` de `N` dividido entre `D`.
Si el residuo es cero, devolver `100 × q` centavos. Si es positivo, devolver
`100 × (q + 1)` centavos. Se usa la fracción original, nunca un pago previamente
redondeado al centavo.

Ejemplos: `10 / 3 → 400` centavos; `90 / 3 → 3000` centavos;
`3001 / 1000 → 400` centavos; `0 / 1 → 0` centavos. Una fracción que ya es entera
no aumenta.

## Servicios, controlador y composición

| Función o construcción | Qué hace y por qué existe | Recibe | Devuelve | Errores |
|---|---|---|---|---|
| Constructor de `Cuenta` | Conserva los datos numéricos de una cuenta ya validada; representa una entrada del cálculo. | Coeficientes, escalas y personas del modelo. | Valor inmutable `Cuenta`. | No produce errores de entrada; validación previa obligatoria. |
| `ValidarEntrada.ejecutar` | Analiza y comprueba textos; evita enviar datos inválidos al cálculo. | Monto, personas y propina en texto. | `Cuenta` válida. | `ArgumentError.message`: `Monto inválido`, `Debe haber al menos una persona`, `Número de personas inválido` o `Propina inválida`, según el caso. |
| Ayudante privado de análisis decimal en `ValidarEntrada` | Conserva todas las cifras y determina coeficiente y escala; reutiliza el análisis de monto y propina. | Texto decimal y mensaje del campo. | Coeficiente `BigInt` y escala `int`. | El mismo error de entrada del campo si el texto no es un decimal no negativo válido. |
| Ayudante privado de análisis de personas en `ValidarEntrada` | Analiza un entero positivo en base diez. | Texto de personas. | `BigInt` positivo. | Mensaje obligatorio para cero o negativo; mensaje de personas inválidas para los demás errores. |
| `CalcularDivision.ejecutar` | Aplica la fórmula de cuenta con propina y delega el redondeo; mantiene el cálculo separado de validación y formato. | `Cuenta` válida y estrategia abstracta. | `Resultado` construido con los centavos devueltos por la estrategia. | Ninguno con precondiciones válidas; no captura ni transforma errores de programación. |
| Constructor de `Resultado` | Conserva el pago individual ya redondeado. | Centavos no negativos de la estrategia. | Valor inmutable `Resultado`. | No valida entradas de usuario. |
| `FormateadorMoneda.formatear` | Escribe la cantidad en centavos con punto y dos cifras decimales; separa formato y cálculo. | `Resultado`. | `String`, por ejemplo `27.50`, `3.33`, `4.00` o `0.00`. | Ninguno para un resultado que respeta su contrato. |
| Constructor de `DivisorController` | Recibe explícitamente sus colaboradores; evita dependencias ocultas. | `ValidacionEntrada`, `DivisionCuenta`, mapa de estrategias y `FormateadorMoneda`. | Controlador configurado. | La composición debe proporcionar un registro no vacío: durante US1 basta con al menos una estrategia de redondeo registrada; al finalizar la implementación deben estar registradas ambas estrategias, `Exacto` y `Hacia arriba`. |
| Opciones de `DivisorController` | Expone las etiquetas del registro para que la pantalla pueda mostrar y seleccionar modos sin conocer implementaciones. | Registro inyectado. | Opciones de solo lectura. | Ninguno para un registro válido. |
| `DivisorController.calcular` | Orquesta validar, seleccionar, calcular y formatear; convierte un error de entrada en salida visible. | Tres textos y clave del modo. | Record con solo `resultado` o solo `error` no nulo. | Captura los errores de entrada de validación y usa su `message` sin prefijos. Una clave ausente del registro es un error de programación de la composición. |
| `main` | Construye y conecta las dependencias concretas y arranca Flutter. | Ningún argumento de usuario. | `void`; aplicación con `PantallaDivisor`. | No gestiona errores de entradas ni calcula cuentas. |

El formateador obtiene la parte entera y el residuo de los centavos entre cien y
rellena la parte decimal con ceros a dos posiciones. No convierte a `double`,
no elige una estrategia y no vuelve a redondear. No agrega conversión de moneda
ni formatos regionales adicionales.

## Pantalla y funciones de Flutter

`PantallaDivisor` recibe el controlador por constructor; no construye servicios.
Su `State` tendrá nombres propios en español. Los nombres de overrides y APIs
del SDK se conservan tal como exige Flutter.

| Función | Qué hace y por qué existe | Recibe | Devuelve | Errores |
|---|---|---|---|---|
| `createState` | Crea el estado de la pantalla siguiendo el ciclo de Flutter. | Ninguno. | `State<PantallaDivisor>`. | Ningún error de entrada. |
| `build` | Dibuja los tres campos, selector, botón y salida en una sola pantalla. | `BuildContext`. | Árbol de widgets. | No valida ni calcula. |
| Callbacks de entradas | Conservan el texto que se usará al pulsar Calcular. | Nuevo texto. | `void`. | No producen mensajes de cálculo mientras se escribe. |
| Callback de selección | Conserva una opción ofrecida por el registro. | Opción elegida. | `void`; cambio local mediante `setState`. | Una opción ajena al registro no procede del selector. |
| Callback del botón Calcular | Pide la operación al controlador y asigna juntos resultado y error mediante `setState`. | Entradas actuales y modo. | `void`; salida visible actualizada. | Los errores de entrada llegan como salida del controlador y ocultan el resultado. |

La implementación mantendrá esta explicación para cualquier función privada que
necesite extraer. No se crearán ayudantes, interfaces o funciones sin una
responsabilidad necesaria para este flujo.
