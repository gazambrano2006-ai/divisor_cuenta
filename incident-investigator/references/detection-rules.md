# Reglas de detección

## Preparación y trazabilidad

Ordena los eventos por timestamp antes de evaluarlos y conserva sus filas físicas
del CSV original. El encabezado cuenta como fila 1; el número de registro no es el
número de fila. Un registro multilínea se cita por su rango de filas físicas.

`login/failed`, `login/success` y `role_change/success` representan pares exactos
de evento y resultado, aunque el CSV los guarde en columnas separadas. No cuentes
coincidencias de palabras dentro de un mensaje como si fueran esos eventos.

Evalúa ventanas móviles, no bloques fijos del reloj. Una ventana de hasta 5 minutos
incluye sus dos extremos: `[inicio, inicio + 5 minutos]`. Una diferencia exacta de
5 minutos sí cuenta; una mayor no. No evalúes una regla si faltan sus campos
esenciales. Para R1 y R2 también se requieren timestamps interpretables; R3 y R4
pueden evaluarse sin ellos, indicando el timestamp como no disponible. Declara
estas limitaciones.

## R1. Fuerza bruta probable

- Condición: al menos **6 eventos `login/failed`**, de la **misma IP contra el mismo
  usuario**, contenidos en una ventana de **hasta 5 minutos**.
- Evidencia: IP, usuario, cantidad, timestamps del primer y último fallo del
  conjunto que sustenta la alerta, y filas físicas de esos fallos.
- Informa **por separado** si existe un `login/success` de esa misma IP y usuario
  en los **5 minutos siguientes al último fallo del conjunto detectado**. Incluye
  ambos extremos: `[timestamp del último fallo, timestamp del último fallo + 5
  minutos]`. Cita timestamp y filas de cada éxito observado en ese intervalo.
- El éxito posterior no es requisito para la alerta ni prueba de compromiso. Si
  no aparece, informa «no observado» y aclara si el CSV no cubre todo el intervalo.

## R2. Password spraying probable

- Condición: eventos **`login/failed` de una misma IP contra al menos 5 usuarios
  distintos en 5 minutos**, con ambos extremos incluidos.
- Cuenta usuarios distintos, no el total de fallos. Varios fallos contra un solo
  usuario no aumentan la cantidad de usuarios.
- Evidencia: IP, usuarios distintos, intervalo y filas físicas de los fallos.

## R3. Token potencialmente expuesto

- Condición: el campo **`detail` contiene la cadena literal `token=`**.
- Sustituye el valor completo asociado a cada `token=` por **`[REDACTED]`** antes de
  mostrarlo, incluso en citas de filas originales y salidas de herramientas.
  Conserva `token=` y el contexto que no contenga secretos. Si el límite del valor
  es ambiguo, redacta desde `token=` hasta el final del campo, dejando
  `token=[REDACTED]`; no arriesgues exponer parte del token.
- Evidencia: presencia de `token=`, contexto redactado y filas físicas. No afirmes
  que el token sea válido, haya sido utilizado o constituya un ataque confirmado.

## R4. Cambio de rol no aprobado

- Condición: **`role_change/success` con `approved=false`**. Comprueba el campo
  `approved` o ese par clave-valor explícito en `detail`, según el esquema.
- Un valor ausente o desconocido no equivale a `false`.
- Evidencia: evento, resultado, aprobación explícitamente falsa y filas físicas.

## R5. Prevención de falsos positivos

- **Tres fallos aislados no bastan** para declarar fuerza bruta o password
  spraying: deben cumplirse los umbrales y agrupaciones de R1 o R2.
- **`healthcheck` no cuenta como fallo de login**, aunque su resultado sea
  `failed`. Solo los eventos `login/failed` participan en R1 y R2.
- No agregues reglas, umbrales ni atribuciones ajenos a estas condiciones.
