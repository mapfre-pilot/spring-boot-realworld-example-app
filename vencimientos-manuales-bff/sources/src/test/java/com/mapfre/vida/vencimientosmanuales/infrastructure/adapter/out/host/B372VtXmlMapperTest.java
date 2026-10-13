package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Coaseguradora;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Expediente;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt12Response;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

class B372VtXmlMapperTest {
    private final B372VtXmlMapper mapper = new B372VtXmlMapper();

    @Test
    void expedienteCompletoConSeisCoaseguradorasHaceRoundTripXml() {
        Expediente expediente = new Expediente("2024", "123456", "001", "2020", "987654",
                "0001", "000001", "12345678Z", "VIGENTE", new BigDecimal("12500.25"),
                new BigDecimal("250.50"), new BigDecimal("100.00"), new BigDecimal("3.75"),
                LocalDate.of(2024, 1, 15), List.of(
                new Coaseguradora("COA001", new BigDecimal("25"), new BigDecimal("3125.06"), new BigDecimal("3000")),
                new Coaseguradora("COA002", new BigDecimal("20"), new BigDecimal("2500.05"), new BigDecimal("2400")),
                new Coaseguradora("COA003", new BigDecimal("15"), new BigDecimal("1875.04"), new BigDecimal("1800")),
                new Coaseguradora("COA004", new BigDecimal("15"), new BigDecimal("1875.04"), new BigDecimal("1800")),
                new Coaseguradora("COA005", new BigDecimal("15"), new BigDecimal("1875.04"), new BigDecimal("1800")),
                new Coaseguradora("COA006", new BigDecimal("10"), new BigDecimal("1250.02"), new BigDecimal("1200"))));

        Map<String, Object> xml = mapper.toExpedienteXmlFields(expediente);

        assertEquals("20240115", xml.get("FECEFECTO-E"));
        assertEquals(6, xml.get("COASEGUROS-OCCURS-E"));
        assertEquals(6, ((List<?>) xml.get("COASEGUROS-E")).size());
        assertEquals("000001", xml.get("KCERTIFICADO-E"));
        assertEquals(expediente, mapper.fromExpedienteXmlFields(xml));
    }

    @Test
    void mapeaLaRespuestaDelServicioDeCoaseguro() {
        Vt12Response response = mapper.fromVt12XmlFields(Map.of(
                "CRETORNO-S", "00",
                "GERROR-S", "",
                "CUADRO-COASEGURO-S", List.of(
                        Map.of("CODCOA-S", "COA001", "PORCOA-S", new BigDecimal("60")),
                        Map.of("CODCOA-S", "COA002", "PORCOA-S", new BigDecimal("40")))));

        assertEquals(2, response.coaseguradoras().size());
        assertEquals(new BigDecimal("60"), response.coaseguradoras().get(0).porcentaje());
    }
}
