package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.domain.exception.SistemaExternoException;
import com.mapfre.pgm.bff.domain.exception.ErrorClienteExternoException;
import com.mapfre.pgm.bff.infrastructure.config.GatewayProperties;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.IdempotenciaService;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
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
    private final IdempotenciaService idempotencia;
    private final DestinoServicioResolver destinos;

    public GatewayClient(RestClient gatewayRestClient, GatewayProperties props, IdempotenciaService idempotencia,
                         DestinoServicioResolver destinos) {
        this.client = gatewayRestClient;
        this.props = props;
        this.idempotencia = idempotencia;
        this.destinos = destinos;
    }

    public <T> Optional<T> get(String ruta, String path, ParameterizedTypeReference<T> tipo,
                               Function<RestClient.RequestHeadersUriSpec<?>, RestClient.RequestHeadersSpec<?>> uri) {
        try {
            return Optional.ofNullable(uri.apply(client.get()).headers(h -> destinos.cabeceras(ruta).forEach(h::set)).retrieve().body(tipo));
        } catch (HttpClientErrorException e) {
            if (e.getStatusCode() == HttpStatus.NOT_FOUND) {
                return Optional.empty();
            }
            throw new ErrorClienteExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public <T, B> T post(String ruta, String path, B body, Class<T> tipo) {
        return postInterno(ruta, path, body, spec -> spec.body(tipo));
    }

    private <T, B> T postInterno(String ruta, String path, B body,
                                 java.util.function.Function<RestClient.ResponseSpec, T> lector) {
        try {
            String idempotencyKey = idempotencia.claveActual();
            return lector.apply(client.post().uri(url(ruta, path))
                    .headers(headers -> {
                        if (idempotencyKey != null) {
                            headers.set("Idempotency-Key", idempotencyKey);
                        }
                        destinos.cabeceras(ruta).forEach(headers::set);
                    })
                    .body(body).retrieve());
        } catch (HttpClientErrorException e) {
            throw new ErrorClienteExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (HttpServerErrorException e) {
            throw new SistemaExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public <T, B> T put(String ruta, String path, B body, ParameterizedTypeReference<T> tipo) {
        try {
            return client.put().uri(url(ruta, path)).headers(h -> destinos.cabeceras(ruta).forEach(h::set)).body(body).retrieve().body(tipo);
        } catch (HttpClientErrorException e) {
            throw new ErrorClienteExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (HttpServerErrorException e) {
            throw new SistemaExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public void delete(String ruta, String path, Map<String, String> cabeceras) {
        try {
            client.delete().uri(url(ruta, path))
                    .headers(h -> { destinos.cabeceras(ruta).forEach(h::set); cabeceras.forEach(h::set); })
                    .retrieve().toBodilessEntity();
        } catch (HttpClientErrorException e) {
            throw new ErrorClienteExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (HttpServerErrorException e) {
            throw new SistemaExternoException(ruta, "Error " + e.getStatusCode().value() + " en " + path, e);
        } catch (RestClientException e) {
            throw new SistemaExternoException(ruta, "Fallo de comunicación en " + path, e);
        }
    }

    public String companyId() {
        return props.companyId() == null || props.companyId().isBlank() ? "1" : props.companyId();
    }

    public String rutaConfigurada(String clave) {
        String ruta = props.rutas().get(clave);
        if (ruta == null || ruta.isBlank()) {
            throw new IllegalStateException("Ruta de gateway no configurada: " + clave);
        }
        return ruta;
    }

    public <T, B> T post(String ruta, String path, B body, ParameterizedTypeReference<T> tipo) {
        return postInterno(ruta, path, body, spec -> spec.body(tipo));
    }

    /** URL completa: Gateway (por defecto) o URL directa del servicio si la configuración de pruebas lo permite. */
    public String url(String ruta, String path) {
        return destinos.urlBase(ruta) + path;
    }
}
