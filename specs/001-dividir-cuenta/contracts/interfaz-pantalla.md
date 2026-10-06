# Contrato de la pantalla

**Fuente de requisitos**: [spec.md](../spec.md).

## Interacción pública

Una sola pantalla permite editar **Monto total**, **Número de personas** y
**Propina (%)**, elegir **Exacto** o **Hacia arriba** y tocar **Calcular**.
Los campos permanecen editables para corregir entradas y repetir la operación.
No hay navegación, conexión, historial ni almacenamiento de cuentas.

Antes de la primera pulsación no aparece un resultado. Cambiar entradas o modo
no ejecuta el cálculo. Calcular usa los tres textos y el modo vigentes. Una
operación válida muestra claramente el pago **por persona**, con punto y
exactamente dos cifras decimales. Las etiquetas de campo son decisiones de
presentación; el botón y los mensajes obligatorios conservan su texto exacto.

Una operación inválida muestra el mensaje y ningún resultado, incluyendo uno de
un cálculo anterior. Una operación válida posterior reemplaza ese error con el
nuevo pago. No se muestran ambas salidas simultáneamente.

## Casos de aceptación que deben convertirse en pruebas de widgets

En cada caso, ingresar todos los valores, elegir el modo y pulsar Calcular.

| Caso | Monto | Personas | Propina | Modo | Salida requerida |
|---|---|---|---|---|---|
| CA-001 | `100.00` | `4` | `10` | Exacto | `27.50` por persona; sin error. |
| CA-002 | `90.00` | `3` | `0` | Exacto | `30.00` por persona; sin error. |
| CA-003 | `50.00` | `0` | `0` | Exacto | `Debe haber al menos una persona`; ningún resultado. |
| CA-004 | `abc` | `3` | `0` | Exacto | `Monto inválido`; ningún resultado. |
| CA-005 | `10.00` | `3` | `0` | Exacto | `3.33` por persona; sin redistribución del sobrante. |
| CA-006 | `10.00` | `3` | `0` | Hacia arriba | `4.00` por persona; sin error. |

Para CA-003 y CA-004, repetir también después de obtener `27.50` en CA-001 y
comprobar que desaparece ese resultado. No basta con comprobar solo el mensaje.

## Comportamientos límite y recuperación

- Una persona es válida y paga la cuenta con propina y el modo elegido.
- Cero monto produce `0.00` en ambos modos con los demás datos válidos.
- Personas negativas muestran `Debe haber al menos una persona` y ningún resultado.
- Monto vacío, negativo, no numérico o no finito muestra `Monto inválido` y ningún resultado.
- Personas vacías, no numéricas o fraccionarias muestran un error de entrada sin resultado.
- Propina vacía, negativa, no numérica o no finita muestra un error de entrada sin resultado.
- Corregir una entrada y volver a pulsar Calcular permite recuperar un resultado válido.
- Con `10.00`, `3` personas y `0` de propina, calcular en Exacto, cambiar a Hacia
  arriba y volver a calcular produce `3.33` y después `4.00`; volver a Exacto y
  calcular restaura `3.33`.
- En Hacia arriba, `90.00`, `3` personas y `0` de propina da `30.00`.
- Exacto aplica el empate al centavo superior: `1.005`, `1` persona y `0` de
  propina da `1.01`.
- Hacia arriba usa el cociente original: `3.001`, `1` persona y `0` de propina
  da `4.00`, aunque el formato al centavo de ese cociente sería `3.00`.

Estos ejemplos adicionales verifican reglas ya presentes en la especificación;
no añaden modos ni funcionalidad.

## Uso sin conexión

La aplicación compilada debe abrir y ejecutar los seis casos sin conexión,
con iguales resultados y mensajes. Ninguna función del flujo realizará
comunicaciones de red, leerá una base de datos o solicitará credenciales.

La preparación y compilación del SDK puede requerir descargas; esa etapa no
forma parte de la operación sin conexión del usuario.
