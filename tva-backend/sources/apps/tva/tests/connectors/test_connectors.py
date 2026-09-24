import pytest

from apps.tva.services.connectors.apilife import ApiLifeError, MockApiLifeClient
from apps.tva.services.connectors.misv import MockMisvClient
from apps.tva.services.connectors.perfil_usuario import MockPerfilUsuarioClient
from apps.tva.services.connectors.ric import MockRicClient


def test_mock_apilife_endpoints():
    c = MockApiLifeClient()
    assert c.annuity_simulation({})["results"]
    assert c.get_proposal({})["contractingProposal"]
    assert c.sbc_maximo({})["importeMaximo"] == 240000.0
    assert c.client_search("X")["clientId"]


def test_mock_apilife_endpoint_desconocido():
    with pytest.raises(ApiLifeError):
        MockApiLifeClient().call("no_existe", {})


def test_mock_ric():
    assert MockRicClient().buscar_cliente("X")["encontrado"] is True


def test_mock_misv():
    assert MockMisvClient().perfilar({})["perfilClientesOK"] is True


def test_mock_perfil_usuario():
    assert MockPerfilUsuarioClient().obtener_perfil("u")["conPerfil"] is True
