# Respuestas — Deber 5: MCP Detective

Materia: Programación Asistida de Aplicaciones.

En este trabajo se utilizó Codex como agente para investigar los casos mediante las herramientas del servidor `mcp-detective`. Durante la investigación, los eventos se obtuvieron exclusivamente por MCP, sin leer directamente `casos.json`.

## 1. Funciones del LLM, Codex, el cliente y el servidor MCP

El LLM interpreta las instrucciones del usuario, selecciona las herramientas que necesita y propone sus argumentos. Después analiza los resultados y redacta una explicación. El modelo debe distinguir entre lo que muestran los registros y las conclusiones que estos permiten.

Codex actúa como host o harness, es decir, como el entorno que coordina el trabajo del modelo. Administra las herramientas, los permisos y las llamadas, y entrega sus resultados al LLM. El cliente MCP es el componente del host que mantiene la conexión con el servidor, descubre sus herramientas, envía las solicitudes y recibe las respuestas. Estos roles corresponden a la [arquitectura de MCP](https://modelcontextprotocol.io/docs/learn/architecture).

El servidor MCP es el programa Python que implementa `listar_casos`, `consultar_eventos` y `registrar_alerta`. Allí se consultan los datos, se validan los argumentos y se registran las alertas.

El código Python lo ejecuta realmente el intérprete del entorno virtual, en el proceso del servidor. En esta conexión por `stdio`, Codex inicia ese proceso y el cliente intercambia mensajes por la entrada y salida estándar. El LLM solicita acciones; el intérprete Python ejecuta las funciones del servidor. La [documentación del SDK](https://py.sdk.modelcontextprotocol.io/run/) describe esta forma de ejecución.

## 2. Por qué INC-003 es sospechoso

Los eventos consultados muestran cuatro intentos fallidos entre las 03:00 y las 03:03, seguidos de un acceso exitoso a las 03:04. Todos corresponden a la cuenta `admin` y a la IP `192.0.2.50`.

La secuencia resulta sospechosa porque hubo varios fallos antes de conseguir acceso a una cuenta administrativa. Por eso se registró una alerta de nivel `alto`, para dar prioridad a la revisión de la legitimidad del acceso.

Sin embargo, los registros no identifican a la persona que realizó los intentos ni demuestran que careciera de autorización. También podrían corresponder a una persona autorizada que ingresó mal sus credenciales. El acceso exitoso confirma una autenticación, pero no demuestra una intrusión.

## 3. Rechazo de INC-999 y de los parámetros inválidos

El servidor rechaza `INC-999` porque ese identificador no existe. La consulta MCP devolvió el mensaje `No existe el caso 'INC-999'.` La lógica interna genera un `ValueError` y la herramienta lo convierte en un `ToolError` para comunicarlo por MCP. El cliente recibe el error y el modelo lo explica sin inventar eventos.

El servidor también valida los argumentos de las alertas: el caso debe existir, el nivel debe ser exactamente `bajo`, `medio` o `alto`, y el motivo debe contener texto. Por ejemplo, rechaza el nivel `critico` y un motivo formado solo por espacios. Además, impide registrar una segunda alerta para el mismo caso mientras la primera permanece en la memoria del proceso.

Estas validaciones deben hacerse en el servidor porque el modelo puede equivocarse al generar los argumentos. Otro cliente también podría enviar solicitudes incorrectas directamente. Las instrucciones al LLM ayudan a orientar su comportamiento, pero el servidor debe aplicar las reglas de manera consistente antes de aceptar una operación.

## 4. Instalación, Inspector, conexión y pruebas

**SDK de MCP.** El SDK de MCP para Python quedó instalado en el entorno virtual `C:\Users\Gabriel\.venvs\mcp-detective`; la versión verificada fue `2.3.0`. La instalación con las utilidades de línea de comandos se puede reproducir con el siguiente comando de PowerShell, usando ese entorno ya creado, según la [documentación de instalación](https://github.com/modelcontextprotocol/python-sdk/blob/main/docs/get-started/installation.md):

```powershell
& "$env:USERPROFILE\.venvs\mcp-detective\Scripts\python.exe" -m pip install "mcp[cli]"
```

**MCP Inspector.** Se utilizó como cliente de prueba para descubrir las tres herramientas y comprobar sus respuestas y errores sin intervención del LLM. Una forma de reproducir la conexión por `stdio`, desde la raíz de `participacion7`, es la siguiente, de acuerdo con la [documentación de Inspector](https://modelcontextprotocol.io/docs/tools/inspector):

```powershell
$pythonMcp = "$env:USERPROFILE\.venvs\mcp-detective\Scripts\python.exe"
$serverMcp = (Resolve-Path ".\mcp-detective\server.py").Path
npx.cmd -y @modelcontextprotocol/inspector $pythonMcp $serverMcp
```

**Conexión a Codex.** El servidor se registró como `mcp-detective` en `C:\Users\Gabriel\.codex\config.toml`. El campo `command` apunta al Python del entorno virtual y `args` contiene la ruta absoluta de `participacion7\mcp-detective\server.py`. Esta configuración permite iniciar el servidor local por `stdio`, como explica la [documentación oficial de Codex](https://developers.openai.com/codex/mcp). La conexión se comprobó mediante las llamadas reales a las herramientas durante la investigación.

**Pruebas con pytest.** Desde la raíz del proyecto se ejecutó:

```powershell
& "$env:USERPROFILE\.venvs\mcp-detective\Scripts\python.exe" -m pytest mcp-detective -q
```

La evidencia `evidencias/pytest.png` muestra el resultado `9 passed in 1.07s`. Se comprobaron el listado de casos, el error por caso inexistente, los eventos de INC-002, una alerta válida de INC-003, tres variantes de alerta duplicada, un nivel no permitido y un motivo con solo espacios. Son siete funciones de prueba, pero la prueba de duplicados tiene tres variantes, por lo que pytest ejecuta nueve casos en total.
