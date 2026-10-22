package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
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
                Arguments.of("SAL-1", Ramo.SALUD, "Salud", "health-api", "health-api-detalle", "SAL-1",
                        Map.of("contractData", Map.of("policyId", "SAL-1"))),
                Arguments.of("HOG-1", Ramo.HOGAR, "Hogar", "home-api", "home-api-detalle", "HOG-1",
                        Map.of("policyId", "HOG-1")),
                Arguments.of("AUT-1", Ramo.AUTOS, "Autos", "motor-api", "motor-api-detalle", "AUT-1",
                        Map.of("policyGeneralInformation", Map.of("referenceNumber", "AUT-1"))),
                Arguments.of("VID-1", Ramo.VIDA, "Vida", "life-api", "life-api-detalle", "VID-1",
                        Map.of("contractData", Map.of("policyId", "VID-1"))),
                Arguments.of("CON-1", Ramo.HOGAR, "Consumo protegido", "home-api", "home-api-detalle", "CON-1",
                        Map.of("policyId", "CON-1")),
                Arguments.of("HIP-1", Ramo.HOGAR, "Hipoteca segura", "home-api", "home-api-detalle", "HIP-1",
                        Map.of("policyId", "HIP-1")));
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

    private static Poliza poliza(String numero, Ramo ramo, String producto) {
        return new Poliza(numero, "C-1001", ramo, producto, Poliza.EstadoPoliza.EN_VIGOR,
                LocalDate.of(2025, 1, 1), LocalDate.of(2026, 1, 1), new BigDecimal("100"),
                "Anual", "Riesgo sintético", List.of(), null, null, "001");
    }
}
