package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Ramo;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.ApiCanalPolizasRecibosAdapter;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.GatewayClient;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.web.client.RestClient;

class LegacyDetallePolizaRutaTest {
    private final GatewayClient gateway = mock(GatewayClient.class);
    private final ApiCanalPolizasRecibosAdapter comun = mock(ApiCanalPolizasRecibosAdapter.class);
    private final LegacyPolizasAdapter adapter = new LegacyPolizasAdapter(gateway, comun);

    static Stream<Arguments> integraciones() {
        return Stream.of(
                Arguments.of("SAL-000102", Ramo.SALUD, "Salud", "health-api", "health-api-detalle", "SAL-000102",
                        Map.of("contractData", Map.of("policyId", "SAL-000102"))),
                Arguments.of("HOG-000101", Ramo.HOGAR, "Hogar", "home-api", "home-api-detalle", "HOG-000101",
                        Map.of("policyId", "HOG-000101")),
                Arguments.of("AUT-000100", Ramo.AUTOS, "Autos Santander", "motor-api", "motor-api-detalle", "AUT-000100",
                        Map.of("policyGeneralInformation", Map.of("referenceNumber", "AUT-000100"))),
                Arguments.of("VID-000103", Ramo.RIESGO, "Vida Riesgo", "life-api", "life-api-detalle", "VID-000103",
                        Map.of("contractData", Map.of("policyId", "VID-000103"))));
    }

    @ParameterizedTest
    @MethodSource("integraciones")
    void mapeaDetallePorTipoYUsaLaRutaConfigurada(String numero, Ramo ramo, String producto, String ruta,
                                                  String claveRuta, String idEsperado, Map<String, Object> respuesta) {
        String path = "/" + claveRuta;
        when(gateway.rutaConfigurada(claveRuta)).thenReturn(path);
        doReturn(Optional.of(respuesta)).when(gateway).get(eq(ruta), eq(path),
                any(ParameterizedTypeReference.class), any());

        var detalle = adapter.detalleRamo(poliza(numero, ramo, producto)).orElseThrow();

        assertThat(detalle.idPoliza()).isEqualTo(idEsperado);
        assertThat(detalle.tipoDetalle()).isNotNull();
        assertThat(detalle.disponibilidadPorOrigen()).singleElement()
                .satisfies(disponibilidad -> assertThat(disponibilidad.origen()).isEqualTo("LEGACY"));
        verify(gateway).get(eq(ruta), eq(path), any(ParameterizedTypeReference.class), any());
    }

    @org.junit.jupiter.api.Test
    void noSolicitaDetalleParaLongitudOnceDoceNiRamoGenerico() {
        var once = poliza("RIE-0000011", Ramo.RIESGO, "Vida Riesgo");
        var twelve = poliza("RIE-00000011", Ramo.RIESGO, "Vida Riesgo");
        var generic = poliza("DEC-000201", Ramo.DECESOS, "Decesos");

        assertThat(Poliza.clasificarTipoDetalle(once.ramo(), once.numero())).isEqualTo(Poliza.TipoDetalle.VIDA);
        assertThat(adapter.detalleRamo(once)).isEmpty();
        assertThat(Poliza.clasificarTipoDetalle(twelve.ramo(), twelve.numero())).isEqualTo(Poliza.TipoDetalle.GENERICA);
        assertThat(adapter.detalleRamo(twelve)).isEmpty();
        assertThat(Poliza.clasificarTipoDetalle(generic.ramo(), generic.numero())).isEqualTo(Poliza.TipoDetalle.GENERICA);
        assertThat(adapter.detalleRamo(generic)).isEmpty();
        verifyNoInteractions(gateway);
    }

    private static Poliza poliza(String numero, Ramo ramo, String producto) {
        return new Poliza(numero, "C-1001", ramo, producto, Poliza.EstadoPoliza.EN_VIGOR,
                LocalDate.of(2025, 1, 1), LocalDate.of(2026, 1, 1), new BigDecimal("100"),
                "Anual", "Riesgo sintético", List.of(), null, null, "001");
    }
}
