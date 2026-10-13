package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest.ApiExceptionHandler.ResourceNotFoundException;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Component
@Profile("local")
public class InMemoryHostVencimientosAdapter implements HostVencimientosPort {
    private static final Map<String, Object> SAMPLE = Map.of(
            "anio", "2024",
            "numero", "123456",
            "ramo", "001",
            "anioPoliza", "2020",
            "numeroPoliza", "987654",
            "subpoliza", "0001",
            "certificado", "000001",
            "nif", "12345678Z",
            "situacion", "VIGENTE",
            "importeCapital", new BigDecimal("12500.00"));

    @Override
    @HostAudit
    public HostResponse execute(Operacion operacion, Map<String, Object> camposXml) {
        return switch (operacion) {
            case VT01 -> {
                if ("C1".equals(camposXml.get("OPERACION-E"))
                        && (!"2024".equals(camposXml.get("ANIO-E"))
                        || !"123456".equals(camposXml.get("KEXPEDIENTE-E")))) {
                    throw new ResourceNotFoundException("No existe el expediente solicitado");
                }
                yield new HostResponse(SAMPLE);
            }
            case VT04 -> new HostResponse(Map.of(
                    "content", List.of(SAMPLE),
                    "page", camposXml.getOrDefault("page", 0),
                    "size", camposXml.getOrDefault("size", 20),
                    "totalElements", 1));
            case VT03, VT05 -> new HostResponse(Map.of(
                    "content", List.of(Map.of("modalidad", "001", "cartera", "VIDA")),
                    "page", camposXml.getOrDefault("page", 0),
                    "size", camposXml.getOrDefault("size", 20),
                    "totalElements", 1));
            case VT11 -> new HostResponse(Map.of(
                    "nombre", "Persona de ejemplo",
                    "apellidos", "Vencimientos",
                    "nif", camposXml.getOrDefault("nif", "12345678Z"),
                    "codigoPostal", "28001"));
            case VT19 -> new HostResponse(Map.of(
                    "ramo", camposXml.getOrDefault("ramo", "001"),
                    "anioPoliza", camposXml.getOrDefault("ANIOPOL-E", "2020"),
                    "numeroPoliza", camposXml.getOrDefault("POLIZA-E", "987654"),
                    "situacion", "VIGENTE"));
            default -> new HostResponse(Map.of(
                    "estado", "ACEPTADO",
                    "operacion", operacion.name(),
                    "campos", camposXml));
        };
    }
}
