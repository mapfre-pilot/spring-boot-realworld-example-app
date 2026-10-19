package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.domain.exception.SistemaExternoException;
import com.mapfre.pgm.bff.infrastructure.config.GatewayProperties;
import java.util.Optional;
import java.util.function.Function;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * Acceso común al API Gateway interno (ARCH-FIS-COM-001): s2s por tenant, timeouts del RestClient,
 * 404 → vacío, resto de errores → {@link SistemaExternoException}. Retries/circuit breaker se aplican en cada adaptador.
 */
@Component
@Profile("!local")
public class GatewayClient {

    private final RestClient client;
    private final GatewayProperties props;

    public GatewayClient(RestClient gatewayRestClient, GatewayProperties props) {
        this.client = gatewayRestClient;
        this.props = props;
    }

    public <T> Optional<T> get(String ruta, String path, ParameterizedTypeReference<T> tipo,
                               Function<RestClient.RequestHeadersUriSpec<?>, RestClient.RequestHeadersSpec<?>> uri) {
        try {
            return Optional.ofNullable(uri.apply(client.get()).retrieve().body(tipo));
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
                return Optional.empty();
            }
            throw new SistemaExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public <T, B> T post(String ruta, String path, B body, Class<T> tipo) {
        try {
            return client.post().uri(props.urlDe(ruta) + path).body(body).retrieve().body(tipo);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public String url(String ruta, String path) {
        return props.urlDe(ruta) + path;
    }
}
