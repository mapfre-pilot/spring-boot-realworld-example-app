package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.application.port.out.SiniestrosPort;
import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
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
        return gw.<List<Poliza>>get("api-canal-polizas", "/polizas", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-polizas", "/polizas?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Poliza> detalle(String numeroPoliza) {
        return gw.get("api-canal-polizas", "/polizas/{n}", new ParameterizedTypeReference<Poliza>() {},
                s -> s.uri(gw.url("api-canal-polizas", "/polizas/{n}"), numeroPoliza));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Recibo> porClienteRecibos(String clienteId) {
        return gw.<List<Recibo>>get("api-canal-recibos", "/recibos", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-recibos", "/recibos?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Recibo> detalleRecibo(String numeroRecibo) {
        return gw.get("api-canal-recibos", "/recibos/{n}", new ParameterizedTypeReference<Recibo>() {},
                s -> s.uri(gw.url("api-canal-recibos", "/recibos/{n}"), numeroRecibo));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Prestacion> porClientePrestaciones(String clienteId) {
        return gw.<List<Prestacion>>get("api-canal-siniestros", "/prestaciones", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-siniestros", "/prestaciones?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Presupuesto> presupuestosPorCliente(String clienteId) {
        return gw.<List<Presupuesto>>get("api-canal-ventas", "/presupuestos", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-ventas", "/presupuestos?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud solicitud) {
        return gw.post("api-canal-ventas", "/tarificaciones/salud", solicitud, TarificacionSalud.Resultado.class);
    }
}
