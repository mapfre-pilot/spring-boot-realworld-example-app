package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.Presupuesto;
import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.ApiCanalPolizasRecibosAdapter;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.GatewayClient;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Ventas por los servicios legacy de PGM en Appian: tarificación Salud {@code POST /individual/simulation}
 * (PGM_HealthAPI_Tarificacion, CS «PGM Health API» apisb health/1.0). Presupuestos ya van por negocioclientes (común).
 */
@Component
@Profile("!local")
public class LegacyVentasAdapter implements VentasPort {
    static final String PATH_SIMULACION = "/individual/simulation";
    private final GatewayClient gw;
    private final ApiCanalPolizasRecibosAdapter comun;

    public LegacyVentasAdapter(GatewayClient gw, ApiCanalPolizasRecibosAdapter comun) {
        this.gw = gw;
        this.comun = comun;
    }

    @Override
    public List<Presupuesto> presupuestosPorCliente(String clienteId) {
        return comun.presupuestosPorCliente(clienteId);
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud s) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("commercialProductId", s.producto());
        body.put("postalCode", s.codigoPostal());
        body.put("copayment", s.copago());
        body.put("insured", s.edades().stream().map(e -> Map.of("age", e)).toList());
        if (s.clienteId() != null) {
            body.put("clientId", s.clienteId());
        }
        Object resp = gw.post("health-api", PATH_SIMULACION, body, new ParameterizedTypeReference<Object>() {});
        JsonTolerante j = JsonTolerante.de(resp);
        JsonTolerante prima = j.objeto("premium", "prima", "price");
        var mensual = prima.decimal("monthly", "mensual", "monthlyPremium");
        var anual = prima.decimal("annual", "anual", "annualPremium");
        if (mensual == null) mensual = j.decimal("monthlyPremium", "primaMensual");
        if (anual == null) anual = j.decimal("annualPremium", "primaAnual", "totalPremium");
        if (anual == null && mensual != null) anual = mensual.multiply(java.math.BigDecimal.valueOf(12));
        if (mensual == null && anual != null) mensual = anual.divide(java.math.BigDecimal.valueOf(12), 2, java.math.RoundingMode.HALF_UP);
        String id = j.texto("simulationId", "quoteId", "id");
        List<String> coberturas = JsonTolerante.lista(j.raw("coverages", "coberturas"), "coverages").stream()
                .map(c -> new JsonTolerante(c).texto("description", "name", "descripcion")).filter(x -> x != null).toList();
        return new TarificacionSalud.Resultado(id == null ? UUID.randomUUID().toString() : id, s.producto(), mensual, anual, coberturas,
                j.texto("status", "estado") == null ? "SIMULADA" : j.texto("status", "estado"));
    }
}
