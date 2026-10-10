# Análisis de la especificación y la Constitution

## 1. Análisis de la especificación

Para este análisis se toma como enunciado cada escenario de aceptación, edge case,
requisito funcional, criterio de éxito y assumption independiente.

La pregunta usada para clasificar cada enunciado fue:

> ¿Este enunciado seguiría siendo válido si la aplicación estuviera hecha en React?

### Escenarios de aceptación

| Enunciado de la spec | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Justificación |
|---|---|---|---|
| CA-001: 100.00, 4 personas y 10% de propina en modo Exacto produce 27.50 por persona. | QUÉ | Intacto | Define un resultado esperado independiente del framework. |
| CA-002: 90.00, 3 personas y 0% de propina en modo Exacto produce 30.00. | QUÉ | Intacto | Es un criterio funcional verificable. |
| CA-005: 10.00 entre 3 personas en modo Exacto produce 3.33 sin redistribuir el centavo restante. | QUÉ | Intacto | Define una regla de cálculo, no una tecnología. |
| CA-003: con 0 personas se muestra exactamente "Debe haber al menos una persona" y no se muestra resultado. | QUÉ | Intacto | Define validación y comportamiento observable. |
| CA-004: con monto `abc` se muestra exactamente "Monto inválido" y no se muestra resultado. | QUÉ | Intacto | Es una regla de validación independiente de Flutter o React. |
| CA-006: 10.00 entre 3 personas en modo Hacia arriba produce 4.00. | QUÉ | Intacto | Define una regla de negocio. |
| Cambiar de Exacto a Hacia arriba cambia el resultado de 3.33 a 4.00 y al volver a Exacto retorna a 3.33. | QUÉ | Intacto | Describe comportamiento esperado del sistema. |
| Sin conexión, CA-001 a CA-006 producen los mismos resultados y mensajes. | QUÉ | Intacto | Es un requisito de funcionamiento independiente del framework. |

### Edge Cases

| Enunciado de la spec | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Justificación |
|---|---|---|---|
| Una sola persona es válida y recibe la cuenta completa con propina y redondeo. | QUÉ | Intacto | Regla de negocio. |
| Un monto 0.00 con al menos una persona produce 0.00 en ambos modos. | QUÉ | Intacto | Regla funcional. |
| Personas menor o igual que cero produce "Debe haber al menos una persona". | QUÉ | Intacto | Regla de validación. |
| Un monto vacío, no numérico, no finito o negativo produce "Monto inválido". | QUÉ | Intacto | Regla de validación. |
| Personas vacías, no numéricas o no enteras son inválidas. | QUÉ | Intacto | Regla funcional. |
| Una propina vacía, no numérica, no finita o negativa es inválida. | QUÉ | Intacto | Regla funcional. |
| Si después de un cálculo válido se hace uno inválido, el resultado anterior desaparece. | QUÉ | Intacto | Describe comportamiento observable. |
| En Hacia arriba, una parte ya entera no aumenta. | QUÉ | Intacto | Regla de redondeo. |
| Hacia arriba se aplica al cociente original y no a un valor previamente redondeado a dos decimales. | QUÉ | Intacto | Regla del cálculo. |

### Functional Requirements

| Enunciado de la spec | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Justificación |
|---|---|---|---|
| FR-001: la aplicación ofrece en una sola pantalla monto, personas y porcentaje de propina. | QUÉ | Intacto | Describe la interacción requerida, no el framework. |
| FR-002: se puede elegir Exacto o Hacia arriba, existe un botón "Calcular" y se muestra resultado o error. | QUÉ | Intacto | Define comportamiento de la interfaz sin imponer tecnología. |
| FR-003: el cálculo se ejecuta con los datos y modo actuales al tocar "Calcular" y antes del primer cálculo no hay resultado. | QUÉ | Intacto | Describe comportamiento observable. |
| FR-004: la propina se calcula sobre el monto y la parte sin redondear sigue la fórmula indicada. | QUÉ | Intacto | Regla matemática del negocio. |
| FR-005: en Exacto todas las personas pagan igual y se muestran dos decimales sin redistribuir sobrantes. | QUÉ | Intacto | Regla de negocio y presentación del resultado. |
| FR-006: en Hacia arriba se usa el menor entero mayor o igual al cociente y se muestra con dos decimales. | QUÉ | Intacto | Regla de redondeo. |
| FR-007: el resultado válido indica cuánto paga cada persona con exactamente dos decimales. | QUÉ | Intacto | Criterio observable. |
| FR-008: personas debe ser un entero mayor o igual que uno y cero o negativo produce el mensaje definido. | QUÉ | Intacto | Regla de validación. |
| FR-009: un monto inválido muestra exactamente "Monto inválido". | QUÉ | Intacto | Regla de validación. |
| FR-010: cualquier entrada inválida muestra error y oculta cualquier resultado previo. | QUÉ | Intacto | Comportamiento funcional. |
| FR-011: al corregir los datos se puede volver a calcular en la misma pantalla. | QUÉ | Intacto | Comportamiento esperado. |
| FR-012: entrada, validación y cálculo funcionan sin conexión y sin red ni base de datos. | QUÉ | Intacto | Restricción funcional independiente de Flutter. |

### Success Criteria

| Enunciado de la spec | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Justificación |
|---|---|---|---|
| SC-001: los seis escenarios cumplen los valores y mensajes esperados. | QUÉ | Intacto | Criterio de aceptación independiente de tecnología. |
| SC-002: todos los resultados válidos definidos se muestran con exactamente dos decimales. | QUÉ | Intacto | Resultado verificable. |
| SC-003: CA-003 y CA-004 muestran los mensajes exactos y ningún resultado. | QUÉ | Intacto | Resultado verificable. |
| SC-004: CA-001 a CA-006 producen los mismos resultados sin conexión. | QUÉ | Intacto | Criterio funcional. |
| SC-005: el usuario puede ingresar y corregir datos, elegir modo, calcular y consultar resultado o error sin salir de la pantalla. | QUÉ | Intacto | Describe la experiencia requerida, no su implementación. |

### Assumptions

| Enunciado de la spec | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Justificación |
|---|---|---|---|
| La cuenta se divide por igual y la propina se agrega al monto ingresado. | QUÉ | Intacto | Regla de negocio. |
| Montos y porcentajes válidos son finitos no negativos y personas es un entero positivo. | QUÉ | Intacto | Restricción de entrada. |
| Se usa punto como separador decimal y no se prescribe otro formato de entrada. | QUÉ | Intacto | Regla del formato esperado. |
| En Exacto se usa redondeo convencional al centavo y se conserva precisión hasta aplicar el modo. | QUÉ | Intacto | Regla de cálculo. |
| La suma de pagos mostrados puede diferir del total y no se ajustan otras personas. | QUÉ | Intacto | Regla funcional. |
| No se fijan valores iniciales obligatorios para las entradas o el selector. | QUÉ | Intacto | Decisión de comportamiento, no de tecnología. |
| El alcance no incluye guardar cuentas y no depende de servicios externos. | QUÉ | Intacto | Define el alcance funcional. |
| Solo se fijan textos exactos para monto inválido y personas menor o igual que cero; otros errores se muestran sin resultado. | QUÉ | Intacto | Regla de comportamiento. |

### Resumen de la especificación

- Enunciados analizados: **42**
- QUÉ: **42**
- CÓMO: **0**
- MIXTO: **0**

Cálculo:

```text
% CÓMO = 0 / 42 × 100 = 0%