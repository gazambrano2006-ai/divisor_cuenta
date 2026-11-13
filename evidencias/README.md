# Procedencia y redacción de las evidencias

Las pruebas y respuestas de esta carpeta proceden de ejecuciones reales. Para publicarlas se conservaron primero los originales en un respaldo privado **fuera del repositorio**, con un manifiesto SHA-256 y copias de las sesiones fuente. La correspondencia entre los alias públicos y las sesiones originales también se conserva allí; su ubicación e identificadores privados no se publican.

## Qué se publica

| Archivo | Naturaleza y tratamiento |
|---|---|
| `activacion_explicita.png` | Captura auténtica de la prueba A. Se revisó mediante OCR local e inspección visual: no muestra rutas personales, nombres de usuario del sistema operativo, identificadores privados ni secretos. Para publicar se retiró únicamente el bloque XMP con identificadores de documento; los datos de imagen se conservaron exactamente. |
| `activacion_explicita.txt` | Extracto redactado de la sesión de la prueba A. Conserva la petición explícita del skill y operaciones reales de lectura con sus resultados. Complementa la captura. |
| `activacion_contextual.txt` | Extracto redactado de la prueba B. Conserva operaciones y salidas que acreditan la lectura del skill y sus reglas ante una petición de investigación sin invocarlo por nombre. |
| `control_negativo.txt` | Extracto redactado de la prueba C, un conteo descriptivo por hora. Distingue los skills presentes en el catálogo de las lecturas efectivamente realizadas; conserva las comprobaciones y el resultado observado. |
| `comparacion_con_skill.txt` | Respuesta auténtica de la corrida CON skill usada en la comparación. Primero se guardó íntegra; la versión publicada sustituye únicamente las rutas personales por referencias relativas y añade una nota editorial. |
| `comparacion_sin_skill.txt` | Transcripción y respuesta auténtica de la corrida independiente SIN skill. La copia previa ya tenía enlaces, rutas y tabla normalizados respecto del mensaje original; se cotejó su contenido. La versión publicada sustituye las rutas personales restantes, elimina espacios finales en líneas vacías y añade una nota editorial. |

SHA-256 del PNG original privado: `6B4F98633E8AC220FF00A23D61D5AD0BC0B28650B222E1C5ADE0085DD436E2B1`.

SHA-256 del PNG publicado, sin metadatos XMP: `3B8F2823A1D3A9923051D0E6EE20C3365231FE5D2452FE8C274E1576AA848C4D`. Se comprobó que todos los bloques `IDAT` y los demás bloques conservados coinciden byte a byte con el original; no se generó, recortó ni recompuso contenido visual.

## Alcance de la redacción

Las trazas de texto son **extractos o proyecciones redactadas, no registros íntegros**. Se omiten rutas personales, identificadores privados de sesión y llamada, y mensajes de configuración o catálogos ajenos a la evidencia necesaria. Se conservan las operaciones relevantes, sus resultados, las referencias a archivos del proyecto y los números de línea de las fuentes. Los alias como `sesion_A.jsonl` identifican las copias privadas; no son nombres originales de sesión.

Las referencias a líneas JSONL pertenecen al registro fuente. Las referencias a filas de `logs_sinteticos.csv` cuentan su encabezado como fila 1. Las rutas del proyecto se expresan respecto de su raíz. Los valores de tokens permanecen ocultos en informes y evidencias.

La redacción no introduce ejecuciones, resultados, capturas ni conclusiones nuevas. Los originales privados permiten cotejar las operaciones y los textos antes de la redacción. La copia pública CON ya no es idéntica byte a byte al mensaje original; su hash anterior a la redacción se conserva en `comparacion.md` y en su propia nota editorial.

`hallazgos.md` también sustituyó una ruta absoluta por `logs_sinteticos.csv`. Las dos copias del skill, sus reglas y el CSV original se conservaron sin cambios. La regla específica de `.gitattributes` preserva los bytes y finales CRLF del CSV e indica a Git que esos finales de línea son válidos. Las pruebas A/B/C son independientes de las dos corridas usadas para comparar CON y SIN skill.

Solo se incorporan a esta participación las evidencias enumeradas en esta nota. Las imágenes de tareas anteriores y el archivo redundante `sin_skill.txt` no forman parte de los cambios de esta entrega.
