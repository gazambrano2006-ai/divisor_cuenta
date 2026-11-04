"""Servidor MCP para consultar eventos y registrar alertas en memoria."""

import json
from copy import deepcopy
from pathlib import Path

from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError


def cargar_casos() -> dict[str, dict]:
    """Lee los casos del JSON ubicado junto a este archivo."""
    ruta = Path(__file__).resolve().with_name("casos.json")
    with ruta.open(encoding="utf-8") as archivo:
        return json.load(archivo)


_casos = cargar_casos()
_alertas: list[dict[str, str]] = []
mcp = MCPServer("mcp-detective")


def obtener_caso(caso_id: str) -> dict:
    """Obtiene un caso o lanza ValueError si el identificador no existe."""
    if caso_id not in _casos:
        raise ValueError(f"No existe el caso '{caso_id}'.")
    return _casos[caso_id]


def validar_alerta(caso_id: str, nivel: str, motivo: str) -> None:
    """Valida la existencia del caso, el nivel exacto y un motivo con texto."""
    obtener_caso(caso_id)
    if nivel not in ("bajo", "medio", "alto"):
        raise ValueError("El nivel debe ser exclusivamente 'bajo', 'medio' o 'alto'.")
    if not isinstance(motivo, str) or not motivo.strip():
        raise ValueError("El motivo debe ser un texto que no esté vacío ni solo tenga espacios.")


def guardar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Guarda una alerta por caso en memoria o lanza ValueError si no es válida."""
    validar_alerta(caso_id, nivel, motivo)
    alerta = {
        "caso_id": caso_id,
        "nivel": nivel,
        "motivo": motivo,
        "estado": "registrada",
    }
    if any(guardada["caso_id"] == caso_id for guardada in _alertas):
        raise ValueError(f"Ya existe una alerta registrada para el caso '{caso_id}'.")
    _alertas.append(alerta)
    return alerta.copy()


@mcp.tool()
def listar_casos() -> list[dict]:
    """Devuelve caso_id, sistema y cantidad_eventos de cada caso, sin conclusiones."""
    return [
        {
            "caso_id": caso_id,
            "sistema": caso["sistema"],
            "cantidad_eventos": len(caso["eventos"]),
        }
        for caso_id, caso in _casos.items()
    ]


@mcp.tool()
def consultar_eventos(caso_id: str) -> list[dict]:
    """Devuelve los eventos exactos del caso o informa con ToolError si no existe."""
    try:
        return deepcopy(obtener_caso(caso_id)["eventos"])
    except ValueError as error:
        raise ToolError(str(error)) from error


@mcp.tool()
def registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Registra una alerta por caso; informa errores de validación con ToolError."""
    try:
        return guardar_alerta(caso_id, nivel, motivo)
    except ValueError as error:
        raise ToolError(str(error)) from error


if __name__ == "__main__":
    mcp.run(transport="stdio")
