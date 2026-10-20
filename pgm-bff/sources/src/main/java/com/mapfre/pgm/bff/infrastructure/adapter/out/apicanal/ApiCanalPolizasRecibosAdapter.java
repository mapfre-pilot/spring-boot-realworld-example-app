package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.application.port.out.SiniestrosPort;
import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/** PROD-APICANAL-POLIZAS / RECIBOS / SINIESTROS / VENTAS por API Gateway. */
@Component
@Profile("!local")
public class ApiCanalPolizasRecibosAdapter implements PolizasPort, RecibosPort, SiniestrosPort, VentasPort {

    private final GatewayClient gw;

    public ApiCanalPolizasRecibosAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Poliza> porCliente(String clienteId) {
        return gw.<List<Poliza>>get("api-canal-clientes", "/clients/{id}/policies", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-clientes", "/clients/{id}/policies"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Poliza> detalle(String numeroPoliza) {
        return gw.get("api-canal-polizas", "/companies/{c}/policies/{n}", new ParameterizedTypeReference<Poliza>() {},
                s -> s.uri(gw.url("api-canal-polizas", "/companies/{c}/policies/{n}"), gw.companyId(), numeroPoliza));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Recibo> porClienteRecibos(String clienteId) {
        // Legacy GESYC (PGM_ServiciosRecibos_ConsultarDatosRecibo) vía Gateway: API Canal Recibos no publica consulta por cliente.
        List<Recibo> r = gw.post("clients-edge", "/gesycore_servicios_bbe-web/services/consultarRecibo",
                Map.of("clienteId", clienteId), new ParameterizedTypeReference<List<Recibo>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Recibo> detalleRecibo(String numeroRecibo) {
        return gw.get("api-canal-recibos", "/receipts/{n}", new ParameterizedTypeReference<Recibo>() {},
                s -> s.uri(gw.url("api-canal-recibos", "/receipts/{n}"), numeroRecibo));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Prestacion> porClientePrestaciones(String clienteId) {
        return gw.<List<Prestacion>>get("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/claims", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/claims"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Presupuesto> presupuestosPorCliente(String clienteId) {
        return gw.<List<Presupuesto>>get("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/projects", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/projects?internalUser=true"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud solicitud) {
        return gw.post("api-canal-ventas", "/1.0/health/quote", solicitud, TarificacionSalud.Resultado.class);
    }
}
