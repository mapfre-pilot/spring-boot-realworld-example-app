package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.*;
import com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest.ApiExceptionHandler.ResourceNotFoundException;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Component
@Profile("local")
public class InMemoryHostVencimientosAdapter implements HostVencimientosPort {
    private static final List<Coaseguradora> COASEGURADORAS = List.of(
            new Coaseguradora("COA001", new BigDecimal("25"), null, null),
            new Coaseguradora("COA002", new BigDecimal("20"), null, null),
            new Coaseguradora("COA003", new BigDecimal("15"), null, null),
            new Coaseguradora("COA004", new BigDecimal("15"), null, null),
            new Coaseguradora("COA005", new BigDecimal("15"), null, null),
            new Coaseguradora("COA006", new BigDecimal("10"), null, null));
    private static final Expediente SAMPLE = new Expediente("2024", "123456", "001", "2020",
            "987654", "0001", "000001", "12345678Z", "VIGENTE",
            new BigDecimal("12500.00"), new BigDecimal("250.00"), new BigDecimal("100.00"),
            new BigDecimal("0.00"), LocalDate.of(2024, 1, 15), COASEGURADORAS);

    @Override
    @HostAudit
    public VtResponse execute(Operacion operacion, VtRequest request) {
        return switch (operacion) {
            case VT01 -> {
                Vt01Request value = (Vt01Request) request;
                if ("C1".equals(value.operacion()) && (!"2024".equals(value.anio())
                        || !"123456".equals(value.numero()))) {
                    throw new ResourceNotFoundException("No existe el expediente solicitado");
                }
                if ("A1".equals(value.operacion()) || "M1".equals(value.operacion())) {
                    yield new Vt01Response(new Expediente(value.anio(), value.numero(),
                            fallback(value.ramo(), SAMPLE.ramo()), fallback(value.anioPoliza(), SAMPLE.anioPoliza()),
                            fallback(value.numeroPoliza(), SAMPLE.numeroPoliza()),
                            fallback(value.subpoliza(), SAMPLE.subpoliza()),
                            fallback(value.certificado(), SAMPLE.certificado()),
                            fallback(value.nif(), SAMPLE.nif()), fallback(value.situacion(), "VIGENTE"),
                            fallback(value.importeCapital(), SAMPLE.importeCapital()),
                            fallback(value.beneficios(), SAMPLE.beneficios()),
                            fallback(value.anticipo(), SAMPLE.anticipo()),
                            fallback(value.interesesPendientes(), SAMPLE.interesesPendientes()),
                            value.fechaEfecto() == null ? SAMPLE.fechaEfecto() : value.fechaEfecto(),
                            value.coaseguradoras().isEmpty() ? COASEGURADORAS : value.coaseguradoras()),
                            "ACEPTADO", null);
                }
                yield new Vt01Response(SAMPLE, "ACEPTADO", null);
            }
            case VT02 -> new Vt02Response(((Vt02Request) request).variables(), "ACEPTADO", null);
            case VT03 -> new Vt03Response(List.of(sampleCartera()), "ACEPTADO", null);
            case VT04 -> {
                BusquedaExpedientes search = ((Vt04Request) request).busqueda();
                yield new Vt04Response(List.of(SAMPLE), search.page(), search.size(), 1, "ACEPTADO", null);
            }
            case VT05 -> {
                Vt05Request page = (Vt05Request) request;
                yield new Vt05Response(List.of(sampleCartera()), page.page(), page.size(), 1, "ACEPTADO", null);
            }
            case VT06 -> new Vt06Response("bdgi-local", "ACEPTADO", null);
            case VT07 -> new Vt07Response("carga-local", "ACEPTADO", null);
            case VT08 -> new Vt08Response(List.of(SAMPLE), "ACEPTADO", null);
            case VT09 -> new Vt09Response("ACEPTADO", null);
            case VT10 -> new Vt10Response("ACEPTADO", null);
            case VT11 -> {
                Vt11Request person = (Vt11Request) request;
                yield new Vt11Response(new Persona("Persona de ejemplo", "Vencimientos",
                        person.nif(), "Calle Ejemplo 1", "28001", "Madrid"), "ACEPTADO", null);
            }
            case VT12 -> new Vt12Response(COASEGURADORAS, "ACEPTADO", null);
            case VT19 -> new Vt19Response(new Cartera("001", "2020", "987654",
                    "0001", "VIDA", "VIGENTE"), "ACEPTADO", null);
        };
    }

    private Cartera sampleCartera() {
        return new Cartera("001", "2020", "987654", "0001", "VIDA", "VIGENTE");
    }

    private String fallback(String value, String defaultValue) {
        return value == null ? defaultValue : value;
    }

    private BigDecimal fallback(BigDecimal value, BigDecimal defaultValue) {
        return value == null ? defaultValue : value;
    }
}
