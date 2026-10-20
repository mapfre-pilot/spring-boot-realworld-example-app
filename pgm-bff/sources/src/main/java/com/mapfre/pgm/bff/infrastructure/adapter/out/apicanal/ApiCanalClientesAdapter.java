package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/** PROD-APICANAL-CLIENTES por API Gateway. El mapeo campo a campo se cierra con el contrato publicado en el Marketplace. */
@Component
@Profile("!local")
public class ApiCanalClientesAdapter implements ClientesPort {

    static final String RUTA = "api-canal-clientes";
    private final GatewayClient gw;

    public ApiCanalClientesAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    @Retry(name = "apicanal-lectura")
    public List<ClienteResumen> buscar(CriteriosBusqueda c) {
        return gw.<List<ClienteResumen>>get(RUTA, "/client/search", new ParameterizedTypeReference<>() {},
                spec -> spec.uri(gw.url(RUTA, "/client/search"), b -> b
                        .queryParamIfPresent("name", Optional.ofNullable(c.texto()))
                        .queryParamIfPresent("document", Optional.ofNullable(c.documento()))
                        .queryParamIfPresent("phone", Optional.ofNullable(c.telefono()))
                        .queryParamIfPresent("email", Optional.ofNullable(c.email()))
                        .queryParamIfPresent("policyNumber", Optional.ofNullable(c.poliza()))
                        .queryParamIfPresent("healthCardNumber", Optional.ofNullable(c.tarjetaSanitaria()))
                        .queryParamIfPresent("city", Optional.ofNullable(c.localidad()))
                        .queryParam("limit", c.limite()).build()))
                .orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    @Retry(name = "apicanal-lectura")
    public Optional<Cliente> ficha(String clienteId) {
        return gw.get(RUTA, "/clients/individuals/{id}", new ParameterizedTypeReference<Cliente>() {},
                spec -> spec.uri(gw.url(RUTA, "/clients/individuals/{id}"), clienteId));
    }
}
