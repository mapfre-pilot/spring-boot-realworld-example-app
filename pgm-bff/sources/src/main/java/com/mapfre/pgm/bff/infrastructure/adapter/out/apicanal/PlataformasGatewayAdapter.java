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

/** Servicios legacy que ya usa PGM (PGO /apipgo, SGC 3.0, iMediador EDGE, SGO, Click2Call) publicados en el API Gateway — nunca en directo. */
@Component
@Profile("!local")
public class PlataformasGatewayAdapter implements OportunidadesPort, GestionComercialPort, UsuariosComercialesPort,
        SgoPort, ComunicacionesPort {

    private final GatewayClient gw;

    public PlataformasGatewayAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<Oportunidad> porClienteOportunidades(String clienteId) {
        List<Oportunidad> r = gw.post("pgo", "/apipgo/client/opportunities", Map.of("clienteId", clienteId),
                new ParameterizedTypeReference<List<Oportunidad>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<GestionComercial> gestionesPorCliente(String clienteId) {
        List<GestionComercial> r = gw.post("sgc30", "/sgc3-bk-business-tasks/api/1.0/external/business-tasks",
                Map.of("clienteId", clienteId), new ParameterizedTypeReference<List<GestionComercial>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<EstructuraComercial> estructuraDe(String usuario) {
        return gw.get("imediador", "/api/1.0/usuario/{u}/perfil", new ParameterizedTypeReference<EstructuraComercial>() {},
                s -> s.uri(gw.url("imediador", "/api/1.0/usuario/{u}/perfil"), usuario));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<String> perfilSgc30De(String usuario) {
        return gw.<Map<String, String>>get("sgc30", "/sgc3-bk-users/api/1.0/user/profile", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("sgc30", "/sgc3-bk-users/api/1.0/user/profile?preferredUsername={u}"), usuario)).map(m -> m.get("perfil"));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<SolicitudSgo> solicitudesPorCliente(String clienteId) {
        List<SolicitudSgo> r = gw.post("sgo", "/ConsultarSolicitudes", Map.of("clienteId", clienteId),
                new ParameterizedTypeReference<List<SolicitudSgo>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public String iniciarLlamada(String clienteId, String telefono, String usuario) {
        Map<String, String> r = gw.post("click2call", "/com.broadsoft.xsi-actions/v2.0/user/" + usuario + "/calls/callmenow?address=" + telefono,
                Map.of("clienteId", clienteId), Map.class);
        return r == null ? null : r.get("id");
    }
}
