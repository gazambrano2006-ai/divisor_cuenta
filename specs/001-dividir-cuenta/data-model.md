# Modelo de datos y estado

**Especificación**: [spec.md](spec.md) | **Diseño**: [plan.md](plan.md)

## Cuenta — domain

Valor inmutable de una entrada validada. No valida, calcula ni formatea en su
constructor. Lo crea `ValidarEntrada` después de comprobar los tres textos.

| Campo | Tipo | Significado y regla |
|---|---|---|
| `montoCoeficiente` | `BigInt` | Cifras del monto sin punto; mayor o igual que cero. |
| `montoEscala` | `int` | Cantidad de cifras decimales del monto; mayor o igual que cero. |
| `personas` | `BigInt` | Número de personas; entero mayor o igual que uno. |
| `propinaCoeficiente` | `BigInt` | Cifras del porcentaje sin punto; mayor o igual que cero. |
| `propinaEscala` | `int` | Cantidad de cifras decimales del porcentaje; mayor o igual que cero. |

Ejemplo: monto `100.00` se representa como coeficiente `10000` y escala `2`;
propina `10` como coeficiente `10` y escala `0`. La escala pertenece a la
representación numérica; no limita la entrada a dos decimales. No se convierte a
`double`, ni se impone un máximo numérico ajeno a la especificación.

### Validación previa a su creación

- Monto y propina: textos decimales en base diez, admitiendo enteros y punto
  decimal, no negativos. Conservar todas las cifras; quitar espacios externos.
  Los valores no numéricos, vacíos, `NaN` o infinitos son inválidos. No se exige
  admitir coma, símbolos monetarios ni otros formatos adicionales.
- Personas: texto de un entero en base diez; cero o negativo produce exactamente
  **Debe haber al menos una persona**. Un texto vacío, no numérico o fraccionario
  produce un error de cantidad de personas.
- Monto inválido produce exactamente **Monto inválido**.
- Propina inválida produce un error de propina. Los textos propuestos para los
  dos errores sin texto obligatorio son **Número de personas inválido** y
  **Propina inválida**.
- Si varias entradas fallan, comprobar en orden monto, personas y propina y
  comunicar el primer error. Esta es una decisión de implementación; los casos
  de aceptación dejan válidas las demás entradas.

## Cociente individual — valor intermedio

`CalcularDivision` combina los campos de `Cuenta` como una fracción. No necesita
otra entidad o clase. Si `m` y `p` son los coeficientes, `em` y `ep` sus escalas,
y `k` las personas, la fracción equivalente a la fórmula de FR-004 es:

```text
numerador   = m × (100 × 10^ep + p)
denominador = 10^em × 100 × 10^ep × k
```

Ambos valores son `BigInt`; numerador no negativo y denominador positivo. La
fracción no se redondea antes de entregarla a la estrategia. La división entera
y el residuo determinan el redondeo sin perder cifras.

## EstrategiaRedondeo — contrato de domain

Interfaz abstracta con un único método `redondear(numerador, denominador)`.
Recibe la fracción anterior y devuelve centavos `BigInt` no negativos.
`RedondeoExacto` y `RedondeoHaciaArriba` son las implementaciones de data.
Ambas admiten exactamente las mismas precondiciones; no necesitan comprobaciones
de tipo. Las fórmulas de sus resultados se detallan en los
[contratos internos](contracts/contratos-internos.md).

## Resultado — domain

| Campo | Tipo | Significado y regla |
|---|---|---|
| `centavosPorPersona` | `BigInt` | Importe individual final, no negativo, después de aplicar la estrategia. |

Valor inmutable creado por `CalcularDivision`. No contiene texto, símbolos,
errores ni una colección de pagos diferentes. Todos reciben el mismo importe.
`FormateadorMoneda` convierte sus centavos a texto con dos decimales.

La relación es una `Cuenta` válida más una estrategia elegida que producen un
`Resultado`. No se guardan relaciones ni datos fuera de la operación actual.

## Registro de modos — composición

Mapa inmutable `Map<String, EstrategiaRedondeo>` creado en `main.dart`:

| Etiqueta y clave | Implementación registrada |
|---|---|
| `Exacto` | `RedondeoExacto` |
| `Hacia arriba` | `RedondeoHaciaArriba` |

El controlador y la pantalla conocen las claves y la abstracción, sin importar
data. No hay un enum cerrado ni una rama que identifique clases concretas.

## Estado de presentación

El `State` de `PantallaDivisor` conserva `String monto`, `String personas`,
`String propina`, `String modo`, `String? resultado` y `String? error`.
Las entradas pueden empezar vacías y el selector en Exacto, decisiones permitidas
por la especificación. No hay resultado ni error antes del primer cálculo.

El controlador devuelve un record `({String? resultado, String? error})`:
un cálculo válido tiene solo resultado; uno inválido tiene solo error. No
almacena estado global ni necesita otra clase de salida.

| Estado previo | Acción | Estado visible posterior |
|---|---|---|
| Inicial | Editar campos o seleccionar modo | Solo cambian las entradas o el modo; no se calcula. |
| Cualquiera | Calcular con entradas válidas | Nuevo resultado con dos decimales; error nulo. |
| Cualquiera, incluido resultado válido previo | Calcular con entrada inválida | Error de entrada; resultado nulo. |
| Error | Corregir y volver a calcular con entradas válidas | Resultado nuevo; desaparece el error. |
| Resultado | Elegir otro modo y volver a calcular | Resultado para los mismos datos y la nueva estrategia. |

Editar después de un cálculo no recalcula automáticamente. La salida se reemplaza
en la siguiente pulsación de Calcular. El cálculo es síncrono y `setState` aplica
los textos de salida juntos, evitando conservar un resultado cuando hay un error.
