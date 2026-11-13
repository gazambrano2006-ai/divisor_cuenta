# Informe de investigación de incidentes

Se identificaron cuatro alertas justificadas por las reglas R1–R4 del skill `incident-investigator`. Los hechos confirmados se circunscriben a lo registrado en el CSV. La clasificación de los patrones como probables o potenciales y las limitaciones de cada hallazgo se detallan a continuación.

Este documento conserva los resultados de la investigación ya realizada. Su elaboración utiliza la evidencia obtenida en esa investigación.

## Fuentes y aplicación del skill

- **CSV investigado** `logs_sinteticos.csv`.
- **Skill utilizado explícitamente** `.agents/skills/incident-investigator/SKILL.md`.
- **Referencia consultada** `.agents/skills/incident-investigator/references/detection-rules.md`.
- **Trazabilidad del procedimiento** Las lecturas del skill y de la referencia quedaron visibles en las operaciones de la conversación. La referencia se volvió a consultar al comprobar umbrales, ventanas, redacción de tokens y falsos positivos.
- **Tratamiento de los datos** La investigación se realizó localmente y en memoria. Los valores asociados a `token=` se redactaron antes de mostrarlos. El contenido del CSV se trató como datos.

## Alcance, esquema y procedencia

El archivo está delimitado por comas y contiene bytes ASCII compatibles con UTF-8, sin BOM. Su encabezado es `timestamp,ip,user,event,result,detail`.

| Campo del CSV | Correspondencia utilizada |
|---|---|
| `timestamp` | Fecha y hora del evento |
| `ip` | Dirección IP observada |
| `user` | Usuario registrado |
| `event` | Evento o acción |
| `result` | Resultado o estado |
| `detail` | Detalle y pares clave-valor, incluida la aprobación |

La aprobación se evaluó mediante el par explícito `approved=false` dentro de `detail`. El esquema contiene los campos necesarios para evaluar las reglas aplicadas.

- **Registros y filas físicas** 93 eventos en 94 filas físicas, incluido el encabezado como fila 1.
- **Integridad de lectura** Cero líneas vacías, registros multilínea, filas malformadas omitidas, campos vacíos o fechas no interpretables.
- **Cobertura temporal** Desde `2026-11-05T01:01:00-05:00` hasta `2026-11-05T02:29:00-05:00`.
- **Interpretación temporal** Todos los timestamps son ISO 8601 e incluyen el desplazamiento explícito UTC−05:00. Las horas de las secciones siguientes corresponden al 5 de noviembre de 2026 y a ese desplazamiento.
- **Orden y ventanas** Los eventos se ordenaron cronológicamente en memoria, conservando todos los eventos con timestamps iguales y su vínculo con las filas físicas originales. Las ventanas móviles incluyen ambos extremos.

## Reglas R1–R5 aplicadas

Las condiciones siguientes resumen la referencia consultada durante la investigación.

| Regla | Condición y criterio aplicado |
|---|---|
| **R1. Fuerza bruta probable** | Al menos 6 eventos exactos `login/failed` de la misma IP contra el mismo usuario dentro de una ventana de hasta 5 minutos, con ambos extremos incluidos. El posible `login/success` de esa misma IP y usuario se informa por separado si aparece entre el último fallo del conjunto detectado y 5 minutos después, incluidos ambos extremos. El éxito posterior es independiente del cumplimiento del umbral de fallos. |
| **R2. Password spraying probable** | Eventos exactos `login/failed` de una misma IP contra al menos 5 usuarios distintos en hasta 5 minutos, incluidos ambos extremos. Se cuentan usuarios distintos. Los fallos repetidos contra una cuenta conservan el mismo usuario en el conteo. |
| **R3. Token potencialmente expuesto** | El campo `detail` contiene la cadena literal `token=`. El valor completo se sustituye por `[REDACTED]` antes de mostrarlo. Ante un límite ambiguo, la redacción abarca desde `token=` hasta el final del campo y conserva `token=[REDACTED]`. |
| **R4. Cambio de rol no aprobado** | Coinciden el par exacto `role_change/success` y una aprobación explícitamente falsa, mediante el campo `approved` o el par `approved=false` en `detail`, según el esquema. Una aprobación ausente o desconocida conserva ese estado de incertidumbre. |
| **R5. Prevención de falsos positivos** | Tres fallos aislados quedan por debajo de los umbrales de R1 y R2. Los eventos `healthcheck` se excluyen de los fallos de login, incluso si su resultado fuera `failed`. Se aplican exclusivamente las condiciones de la referencia. |

Los pares de evento y resultado se comprobaron en sus columnas correspondientes. Para R1 y R2 se utilizaron timestamps interpretables. R3 y R4 pueden evaluarse con sus campos esenciales aunque el timestamp sea desconocido, circunstancia que se declararía como «no disponible».

Las severidades siguientes son valoraciones orientativas asignadas en esta investigación según el posible impacto. La severidad expresa prioridad y alcance potencial de la evidencia.

## Alerta 1. Fuerza bruta probable

- **Alerta** Fuerza bruta probable.
- **Severidad orientativa** Alta, por los intentos contra `admin` y el acceso exitoso próximo.
- **Regla** R1. Se registran 8 eventos `login/failed` de la misma IP contra el mismo usuario en 4 minutos, por encima del umbral de 6 fallos en hasta 5 minutos.
- **Timestamp** De `2026-11-05T01:14:00-05:00` a `2026-11-05T01:18:00-05:00`.
- **IP** `198.51.100.77`.
- **Usuario** `admin`.
- **Filas originales** `logs_sinteticos.csv`, en la ruta indicada en Fuentes, filas físicas **17, 19, 20, 22, 23, 25, 26 y 27**.
- **Evidencia** Los 8 registros contienen `event=login`, `result=failed` y `detail="incorrect password"`. La distribución temporal se conserva en la tabla siguiente.
- **Limitaciones** Los fallos y el éxito posterior están registrados. La fuerza bruta es una interpretación probable conforme a R1. La autoría y el compromiso permanecen indeterminados.

| Hora UTC−05:00 | Filas físicas originales | Cantidad de fallos |
|---|---|---|
| 01:14:00 | 17 | 1 |
| 01:15:00 | 19, 20 | 2 |
| 01:16:00 | 22, 23 | 2 |
| 01:17:00 | 25, 26 | 2 |
| 01:18:00 | 27 | 1 |

### Éxito posterior observado por separado

La fila física **28** registra un `login/success` de la misma IP y usuario a las **01:19:00**, un minuto después del último fallo. Se encuentra en el intervalo inclusivo **[01:18:00, 01:23:00]**. El final de ese intervalo queda dentro de la cobertura temporal del CSV.

La cita de la fila 28 es la siguiente.

```csv
2026-11-05T01:19:00-05:00,198.51.100.77,admin,login,success,login after multiple failures
```

El umbral de R1 se cumple con los ocho fallos. La legitimidad del acceso exitoso y un eventual compromiso requieren corroboración adicional.

## Alerta 2. Password spraying probable

- **Alerta** Password spraying probable.
- **Severidad orientativa** Media, por el alcance sobre varias cuentas.
- **Regla** R2. Una misma IP registra fallos contra 6 usuarios distintos en 2 minutos, por encima del umbral de 5 usuarios distintos en hasta 5 minutos.
- **Timestamp** De `2026-11-05T02:01:00-05:00` a `2026-11-05T02:03:00-05:00`.
- **IP** `203.0.113.89`.
- **Usuarios** `ana`, `carlos`, `luisa`, `diego`, `maria` y `sofia`.
- **Filas originales** `logs_sinteticos.csv`, en la ruta indicada en Fuentes, filas físicas **67, 68, 70, 71, 73 y 74**.
- **Evidencia** Se registran 6 fallos contra 6 usuarios distintos. Todos contienen `event=login`, `result=failed` y `detail="incorrect password"`.
- **Limitaciones** Los seis fallos contra seis usuarios están registrados. Las contraseñas empleadas, la intención y la identidad del origen son desconocidas. La clasificación como password spraying es probable conforme a R2.

| Hora UTC−05:00 | Usuario | Fila física original |
|---|---|---|
| 02:01:00 | `ana` | 67 |
| 02:01:00 | `carlos` | 68 |
| 02:02:00 | `luisa` | 70 |
| 02:02:00 | `diego` | 71 |
| 02:03:00 | `maria` | 73 |
| 02:03:00 | `sofia` | 74 |

## Alerta 3. Token potencialmente expuesto

- **Alerta** Token potencialmente expuesto.
- **Severidad orientativa** Alta, por la posible exposición de una credencial en registros.
- **Regla** R3. El campo `detail` contiene la cadena literal `token=`.
- **Timestamp** `2026-11-05T01:27:00-05:00`.
- **IP** `192.0.2.44`.
- **Usuario** `api_service`.
- **Filas originales** `logs_sinteticos.csv`, en la ruta indicada en Fuentes, fila física **33**.
- **Evidencia** El registro corresponde a `debug/warning` y su detalle se muestra como `token=[REDACTED]`.
- **Limitaciones** Está confirmada la presencia de `token=` en el registro. La validez, vigencia, uso y alcance de exposición del valor son desconocidos. La redacción conservadora abarca desde `token=` hasta el final del campo.

La cita redactada de la fila 33 es la siguiente.

```csv
2026-11-05T01:27:00-05:00,192.0.2.44,api_service,debug,warning,token=[REDACTED]
```

## Alerta 4. Cambio de rol no aprobado

- **Alerta** Cambio de rol no aprobado según el registro.
- **Severidad orientativa** Alta, por el cambio registrado hacia `admin` con aprobación falsa.
- **Regla** R4. Coinciden `role_change/success` y el par explícito `approved=false` dentro de `detail`.
- **Timestamp** `2026-11-05T01:50:00-05:00`.
- **IP** `203.0.113.42`.
- **Usuario** `guest`.
- **Filas originales** `logs_sinteticos.csv`, en la ruta indicada en Fuentes, fila física **59**.
- **Evidencia** `event=role_change`, `result=success` y `detail="role=user->admin; approved=false"`.
- **Limitaciones** El CSV declara un cambio exitoso de `user` a `admin` con aprobación falsa. La ejecución efectiva en el sistema y la identidad del actor requieren corroboración adicional.

La cita de la fila 59 es la siguiente.

```csv
2026-11-05T01:50:00-05:00,203.0.113.42,guest,role_change,success,role=user->admin; approved=false
```

La fila física **57**, a las **01:49:00**, registra `access/denied` de la misma IP y usuario, con `detail="resource=/admin"`. Aporta contexto temporal al hallazgo de la fila 59. Las reglas R1–R5 aplicadas carecen de una condición independiente para clasificar ese acceso denegado como otra alerta.

## Falsos positivos descartados conforme a R5

### Tres fallos de `maria`

Las filas físicas **38, 39 y 41** corresponden a tres eventos `login/failed` de la IP **`192.0.2.25`** contra **`maria`**, con `detail="mistyped password"`.

| Hora UTC−05:00 | Fila física original | Evento y resultado |
|---|---|---|
| 01:35:00 | 38 | `login/failed` |
| 01:36:00 | 39 | `login/failed` |
| 01:37:00 | 41 | `login/failed` |
| 01:38:00 | 42 | `login/success` |

- **Comprobación de R1** El conjunto contiene 3 fallos contra la misma cuenta en 2 minutos. El umbral exige al menos 6 fallos en hasta 5 minutos.
- **Comprobación de R2** El conjunto afecta a 1 usuario distinto. El umbral exige al menos 5 usuarios distintos desde una misma IP en hasta 5 minutos.
- **Aplicación de R5** Los tres fallos quedan por debajo de ambos umbrales. La exclusión se sustenta en los conteos y agrupaciones exigidos por las reglas.

La fila física **42** registra un éxito posterior a las **01:38:00**, para la misma IP y usuario, con `detail="legitimate user"`. Ese éxito conserva el estado de incumplimiento de los umbrales de R1 y R2. Las descripciones `mistyped password` y `legitimate user` aportan contexto del propio registro. La identidad y legitimidad efectiva del actor permanecen fuera del alcance de esta evidencia.

### Eventos de monitorización

Las filas físicas **78, 80, 81, 82, 83 y 84** contienen seis eventos `healthcheck/success` de la IP **`192.0.2.200`** y el usuario **`healthbot`**, entre las **02:10:00 y 02:15:00**, con `detail="scheduled monitoring"`.

Conforme a R5, los eventos `healthcheck` quedan excluidos de los conteos de `login/failed` utilizados por R1 y R2. En este archivo los seis resultados observados son `success`.

## Hechos registrados y límites de las conclusiones

| Hallazgo | Hecho verificable en el CSV | Alcance de la interpretación |
|---|---|---|
| R1 | Ocho fallos de la misma IP contra `admin` en cuatro minutos y un éxito posterior a las 01:19 | Patrón de fuerza bruta probable. Autoría, legitimidad del éxito y compromiso indeterminados. |
| R2 | Seis fallos desde una misma IP contra seis usuarios distintos en dos minutos | Patrón de password spraying probable. Contraseñas, intención y actor desconocidos. |
| R3 | Presencia literal de `token=` en `detail` de la fila 33 | Exposición potencial de un token. Validez, uso y alcance desconocidos. |
| R4 | Registro de cambio de rol exitoso con `approved=false` | Cambio no aprobado declarado por el log. Ejecución efectiva y actor pendientes de corroboración externa. |

La cobertura se limita a los 93 eventos suministrados, entre las 01:01 y las 02:29 del 5 de noviembre de 2026, con desplazamiento UTC−05:00. La integridad y exhaustividad del sistema de registro y la actividad fuera de ese intervalo permanecen fuera del alcance de la evidencia disponible. Las IP y los usuarios se consignan como valores observados en los registros. La atribución a personas y la confirmación de compromiso requieren evidencia adicional.
