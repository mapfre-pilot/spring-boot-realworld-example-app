package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.*;
import com.mapfre.pgm.bff.domain.model.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/** APIs de plataforma (PGO, SGC 3.0, iMediador, SGO, comunicaciones) por API Gateway — nunca ESB/SOAP/Denodo directos. */
@Component
@Profile("!local")
public class PlataformasGatewayAdapter implements OportunidadesPort, GestionComercialPort, SgoPort, ComunicacionesPort {

    private final GatewayClient gw;

    public PlataformasGatewayAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<Oportunidad> porClienteOportunidades(String clienteId) {
        return gw.<List<Oportunidad>>get("pgo", "/oportunidades", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("pgo", "/oportunidades?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<GestionComercial> gestionesPorCliente(String clienteId) {
        return gw.<List<GestionComercial>>get("sgc30", "/gestiones", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("sgc30", "/gestiones?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<EstructuraComercial> estructuraDe(String usuario) {
        return gw.get("imediador", "/usuarios/{u}/estructura", new ParameterizedTypeReference<EstructuraComercial>() {},
                s -> s.uri(gw.url("imediador", "/usuarios/{u}/estructura"), usuario));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<String> perfilSgc30De(String usuario) {
        return gw.<Map<String, String>>get("sgc30", "/usuarios/{u}/perfil", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("sgc30", "/usuarios/{u}/perfil"), usuario)).map(m -> m.get("perfil"));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<SolicitudSgo> solicitudesPorCliente(String clienteId) {
        return gw.<List<SolicitudSgo>>get("sgo", "/solicitudes", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("sgo", "/solicitudes?clienteId={id}"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public String iniciarLlamada(String clienteId, String telefono, String usuario) {
        Map<String, String> r = gw.post("comunicaciones", "/llamadas",
                Map.of("clienteId", clienteId, "telefono", telefono, "usuario", usuario), Map.class);
        return r == null ? null : r.get("id");
    }
}
