"""Pruebas del servidor MCP con las alertas aisladas entre pruebas."""

from collections.abc import Iterator

import pytest
from mcp.server.mcpserver.exceptions import ToolError

import server


@pytest.fixture(autouse=True)
def reiniciar_alertas() -> Iterator[None]:
    """Vacía las alertas antes y después de cada prueba, incluso si falla."""
    server._alertas.clear()
    yield
    server._alertas.clear()


def test_listar_casos_devuelve_exactamente_los_tres_casos() -> None:
    assert server.listar_casos() == [
        {"caso_id": "INC-001", "sistema": "portal_acceso", "cantidad_eventos": 2},
        {"caso_id": "INC-002", "sistema": "portal_acceso", "cantidad_eventos": 6},
        {"caso_id": "INC-003", "sistema": "panel_administracion", "cantidad_eventos": 5},
    ]


def test_consultar_caso_inexistente_conserva_el_error_de_la_logica() -> None:
    """La lógica lanza ValueError y la herramienta expone su mensaje con ToolError."""
    mensaje = "No existe el caso 'INC-999'."
    with pytest.raises(ValueError, match="No existe el caso 'INC-999'") as error_logica:
        server.obtener_caso("INC-999")

    with pytest.raises(ToolError) as error_mcp:
        server.consultar_eventos("INC-999")

    assert isinstance(error_mcp.value.__cause__, ValueError)
    assert str(error_logica.value) == mensaje
    assert str(error_mcp.value) == mensaje
    assert str(error_mcp.value.__cause__) == mensaje


def test_consultar_inc_002_devuelve_seis_login_failed() -> None:
    eventos = server.consultar_eventos("INC-002")

    assert len(eventos) == 6
    assert all(evento["evento"] == "LOGIN_FAILED" for evento in eventos)


def test_registrar_alerta_valida_para_inc_003() -> None:
    esperada = {
        "caso_id": "INC-003",
        "nivel": "alto",
        "motivo": "Revisar los accesos del administrador.",
        "estado": "registrada",
    }

    resultado = server.registrar_alerta(
        "INC-003", "alto", "Revisar los accesos del administrador."
    )

    assert resultado == esperada
    assert server._alertas == [esperada]


@pytest.mark.parametrize(
    ("nivel", "motivo"),
    [
        ("medio", "Motivo inicial"),
        ("bajo", "Motivo diferente"),
        ("alto", "Motivo diferente"),
    ],
    ids=["cambia_nivel", "cambia_motivo", "cambian_ambos"],
)
def test_rechaza_segunda_alerta_del_mismo_caso(nivel: str, motivo: str) -> None:
    original = server.guardar_alerta("INC-003", "bajo", "Motivo inicial")

    with pytest.raises(
        ValueError, match="Ya existe una alerta registrada para el caso 'INC-003'"
    ):
        server.guardar_alerta("INC-003", nivel, motivo)

    assert server._alertas == [original]


def test_rechaza_nivel_critico() -> None:
    with pytest.raises(ValueError, match="El nivel debe ser exclusivamente"):
        server.guardar_alerta("INC-003", "critico", "Motivo válido")

    assert server._alertas == []


def test_rechaza_motivo_con_solo_espacios() -> None:
    with pytest.raises(ValueError, match="El motivo debe ser un texto"):
        server.guardar_alerta("INC-003", "alto", "   ")

    assert server._alertas == []
