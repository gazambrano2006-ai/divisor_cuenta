# Comparación — Participación Cyber Detective

Se comparó **una corrida independiente por condición**, SIN skill y CON `incident-investigator`, sobre el mismo `logs_sinteticos.csv`. Es una comparación descriptiva de dos respuestas, **no una evaluación estadística**. No se realizaron mediciones comparativas de tiempo ni consumo de tokens.

## Respuestas y procedencia

- **CON skill:** [respuesta con rutas redactadas](evidencias/comparacion_con_skill.txt). Primero se guardó una copia exacta del mensaje final auténtico; ese original se conserva fuera del repositorio. La versión publicada sustituye las rutas personales por referencias relativas y añade una nota editorial; no se presenta como una copia íntegra.
- **SIN skill:** [evidencia con rutas redactadas](evidencias/comparacion_sin_skill.txt), que contiene la transcripción y la respuesta de la sesión independiente en `cyber-control-sin-skill`. Antes de redactarla se cotejó con su mensaje final auténtico: el contenido coincidía tras normalizar únicamente enlaces, rutas y espacios de la tabla. El original también se conserva fuera del repositorio. La versión publicada sustituye rutas personales, elimina espacios finales en líneas vacías y añade una nota editorial.
- La [nota de procedencia y redacción](evidencias/README.md) documenta los cambios y el respaldo privado de los originales. Se conservaron los hallazgos, conteos, citas y limitaciones; no se fabricaron operaciones ni resultados.
- Los CSV de ambos directorios son idénticos: SHA-256 `7D8219E9F8C9DD995BE0C2DC038F4F7E67F0F12446B4FDC07FADF508BEFB5DA8`. Contienen 93 registros y el encabezado en la fila física 1.

## Tabla de comparación

| Criterio | Investigación SIN skill | Investigación CON skill |
|---|---|---|
| Procedimiento reproducible | Incluye transcripción de comandos y comprobaciones locales; declara los 93 registros, el criterio de numeración de filas y la zona horaria. Presenta un análisis coherente sin organizarlo como aplicación formal de R1–R5. | Documenta codificación, delimitador, mapeo de campos, cobertura y conservación de timestamps iguales. Explica R1–R5, los umbrales y las ventanas móviles con ambos extremos incluidos; separa el éxito posterior de los fallos. |
| Citas de filas originales | Cita correctamente los fallos contra `admin` (17, 19, 20, 22, 23, 25, 26, 27), el éxito (28), el token (33), el cambio de rol (59) y los fallos contra varias cuentas (67, 68, 70, 71, 73, 74). | Cita las mismas filas correctas y reproduce líneas del CSV con su número físico y el token oculto. Se comprobaron sus 23 citas literales contra el original, sin discrepancias salvo la redacción prevista del secreto. |
| Alertas sustentadas | Identifica cuatro: elevación no aprobada, probable fuerza bruta, token expuesto en el log e intentos compatibles con password spraying. Matiza sus conclusiones. | Identifica las mismas cuatro: R1 por 8 fallos en 4 minutos, R2 por 6 usuarios en 2 minutos, R3 por `token=` en `detail` y R4 por `role_change/success` con `approved=false`. Añade severidades orientativas y sus motivos. |
| Falsos positivos evitados | Distingue los tres errores de contraseña de `maria` y su éxito posterior (38, 39, 41, 42), los healthchecks (78, 80–84) y un reintento aislado de `carlos` (51, 53). | Descarta los tres fallos de `maria` porque no alcanzan R1/R2 y excluye los healthchecks de los fallos de login, conforme a R5. No genera alertas adicionales por los demás fallos aislados. |
| Protección de tokens | Oculta parte del valor y no muestra el token completo. La copia existente y la respuesta auténtica se comprobaron en memoria contra el secreto del CSV, sin publicarlo. | Sustituye el valor completo por `token=[REDACTED]` en la cita y evita exponerlo en las salidas de herramientas. La copia guardada tampoco contiene el valor completo. |
| Reconocimiento de incertidumbre | Advierte que el éxito no confirma acceso de un atacante, que no se sabe si hubo una contraseña común y que los pares 19–20, 22–23 y 25–26 podrían ser intentos repetidos o duplicación del registro. | Explica que las coincidencias de reglas y el éxito posterior no prueban intrusión o autoría; tampoco confirma validez o uso del token ni una sesión común para el cambio de rol. No desarrolla tan explícitamente la posible duplicación de registros. |
| Aporte concreto del skill | La investigación independiente también obtiene buenos resultados y aporta una observación útil sobre duplicados. No necesitó el skill para encontrar las cuatro alertas. | Aporta criterios explícitos y reutilizables para decidir, contar, citar, redactar secretos y declarar límites. Su contribución observable es la formalización y trazabilidad del procedimiento; no aumentó el número de alertas encontradas en esta muestra. |

La diferencia sobre duplicados merece conservarse. CON skill cuenta los ocho registros originales sin eliminar eventos con timestamps iguales, como exige su procedimiento. SIN skill señala que, al colapsar los tres pares idénticos, quedarían cinco fallos. Esa alternativa no alcanzaría el umbral formal de seis de R1. El CSV por sí solo no permite determinar si hubo ocho intentos distintos o duplicación durante el registro. Esta observación complementa el análisis CON skill; no se añadió retrospectivamente a su respuesta.

Las dos respuestas respaldan los mismos cuatro hallazgos y citan filas correctas. Con una corrida por condición no se puede atribuir al skill una mejora general de precisión o rendimiento. Aquí se observa una explicación más formal del procedimiento CON skill y una advertencia más explícita sobre duplicados SIN skill.

## Verificación de la activación en la corrida comparada

La activación CON skill se verificó mediante **llamadas reales de lectura y sus resultados**, anteriores al análisis, no por la aparición de R1–R5 en la respuesta. Los números siguientes corresponden a líneas físicas de los archivos JSONL locales, no a filas del CSV.

**Registro CON:** alias público `sesion_comparacion_CON.jsonl`. El registro original y su correspondencia privada con este alias se conservan fuera del repositorio. Las referencias siguientes son proyecciones redactadas de operaciones reales; se omiten los identificadores privados de sesión y de llamada.

| Evidencia local | Comprobación |
|---|---|
| Línea 18, `custom_tool_call` | Ejecuta `Get-Content -LiteralPath '.agents/skills/incident-investigator/SKILL.md' -Raw`. |
| Línea 20, salida vinculada a la llamada de la línea 18 | Devuelve `exit_code = 0` y el contenido con `name: incident-investigator`. |
| Línea 22, `custom_tool_call` | Ejecuta `Get-Content -LiteralPath '.agents/skills/incident-investigator/references/detection-rules.md' -Encoding UTF8 -Raw`. |
| Línea 24, salida vinculada a la llamada de la línea 22 | Devuelve `exit_code = 0`, `# Reglas de detección` y las reglas del archivo. |
| Línea 52, `response_item/message`, rol `assistant`, fase `final_answer` | Contiene la respuesta auténtica. Se conserva la copia exacta original fuera del repositorio y se publica su versión con rutas redactadas en `evidencias/comparacion_con_skill.txt`. |

SHA-256 de la copia CON **original, anterior a la redacción**: `5BCED5E76600DEB94D0B3B8F7FF2EB14203835659FB7FBB933D94AF7C31D1000`.

**Registro SIN:** alias público `sesion_comparacion_SIN.jsonl`, conservado fuera del repositorio. La línea 1 identifica el directorio `cyber-control-sin-skill`; la línea 70 contiene el mensaje final auténtico (`response_item/message`, rol `assistant`, fase `final_answer`) usado para cotejar la copia existente. No se observaron lecturas del skill en las llamadas de esa sesión ni en las de sus dos subagentes.

Las pruebas A, B y C se documentan en `evidencias/activacion_explicita.txt`, `evidencias/activacion_contextual.txt` y `evidencias/control_negativo.txt`. La prueba B corresponde a otra corrida; no se usó para dar por activado el skill en esta comparación. No fue necesario reconstruir ninguna respuesta ni fabricar registros o capturas.
