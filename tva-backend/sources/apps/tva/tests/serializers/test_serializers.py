from apps.tva.serializers import InicioRequestSerializer, SesionEstadoSerializer


def test_inicio_serializer_valido():
    s = InicioRequestSerializer(data={"documentoCliente": "X", "canal": "GV"})
    assert s.is_valid(), s.errors


def test_inicio_serializer_canal_invalido():
    s = InicioRequestSerializer(data={"documentoCliente": "X", "canal": "XX"})
    assert not s.is_valid()


def test_estado_serializer_requiere_dict():
    assert SesionEstadoSerializer(data={"estado": {"a": 1}}).is_valid()
    assert not SesionEstadoSerializer(data={"estado": [1, 2]}).is_valid()
