package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.ConfiguracionPort;
import com.mapfre.pgm.bff.domain.model.Configuracion;
import com.mapfre.pgm.bff.domain.model.Configuracion.OrigenDatos;
import com.mapfre.pgm.bff.domain.model.Configuracion.Servicio;
import com.mapfre.pgm.bff.domain.model.Configuracion.TipoAutenticacion;
import com.mapfre.pgm.bff.infrastructure.config.GatewayProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Profile;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;

import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Resuelve, para cada ruta lógica, la URL base y las cabeceras de autenticación a partir de la pestaña «Configuración».
 * Por defecto todo sale por el API Gateway ({@code gateway.baseUrl + ruta}, ARCH-FIS-COM-001). Solo si la configuración activa
 * «llamada directa (pruebas)» y el servicio tiene URL para el entorno elegido, se llama al servicio legacy en directo con las
 * credenciales guardadas (API key, Basic u OAuth client credentials): es el modo para probar la SPA sin Gateway, nunca para PRO.
 */
@Component
@Profile("!local")
public class DestinoServicioResolver {

    private static final Logger log = LoggerFactory.getLogger(DestinoServicioResolver.class);
    private static final long CACHE_MS = 5_000;

    private final ConfiguracionPort almacen;
    private final GatewayProperties props;
    private final RestClient.Builder builder;
    private final Map<String, Token> tokens = new ConcurrentHashMap<>();
    private volatile Optional<Configuracion> cache = Optional.empty();
    private volatile long cacheHasta;
    private volatile long cacheVersion = -1;

    public DestinoServicioResolver(ConfiguracionPort almacen, GatewayProperties props, RestClient.Builder builder) {
        this.almacen = almacen;
        this.props = props;
        this.builder = builder;
    }

    /** URL base de la ruta lógica (sin path), ya resuelta entre Gateway y llamada directa. */
    public String urlBase(String ruta) {
        Optional<Configuracion> cfg = configuracion();
        Optional<Servicio> servicio = servicio(cfg, ruta);
        if (cfg.isPresent() && servicio.isPresent() && llamadaDirecta(cfg.get())) {
            String entorno = cfg.get().origenDatos().entornoServicios() == null ? "PRE" : cfg.get().origenDatos().entornoServicios();
            String directa = servicio.get().urlPorEntorno() == null ? null : servicio.get().urlPorEntorno().get(entorno);
            if (directa != null && !directa.isBlank()) {
                return directa.endsWith("/") ? directa.substring(0, directa.length() - 1) : directa;
            }
        }
        String base = cfg.map(Configuracion::gateway).map(Configuracion.Gateway::baseUrl).filter(b -> !b.isBlank()).orElse(props.baseUrl());
        String path = cfg.map(Configuracion::gateway).map(Configuracion.Gateway::rutas).map(r -> r.get(ruta)).orElseGet(() -> props.rutas().get(ruta));
        if (path == null) {
            throw new IllegalStateException("Ruta de gateway no configurada: " + ruta);
        }
        return base + path;
    }

    /** Cabeceras de autenticación y fijas del servicio (vacío si el servicio no está configurado o no tiene credenciales). */
    public Map<String, String> cabeceras(String ruta) {
        Optional<Configuracion> cfg = configuracion();
        Optional<Servicio> servicio = servicio(cfg, ruta);
        Map<String, String> h = new LinkedHashMap<>();
        if (servicio.isEmpty()) {
            return h;
        }
        Servicio s = servicio.get();
        if (s.cabeceras() != null) {
            s.cabeceras().forEach((k, v) -> {
                if (!k.equals("tokenUrl") && !k.equals("scope") && !k.equals("apiKeyHeader") && v != null && !v.contains("{")) {
                    h.put(k, v);
                }
            });
        }
        Map<String, String> sec = almacen.secretos(s.clave());
        TipoAutenticacion tipo = s.autenticacion() == null ? TipoAutenticacion.NINGUNA : s.autenticacion();
        switch (tipo) {
            case API_KEY -> Optional.ofNullable(sec.get("apiKey")).ifPresent(k ->
                    h.put(s.cabeceras() != null && s.cabeceras().containsKey("apiKeyHeader") ? s.cabeceras().get("apiKeyHeader") : "x-api-key", k));
            case BASIC -> {
                String u = sec.get("usuario");
                String p = sec.get("password");
                if (u != null && p != null) {
                    h.put("Authorization", "Basic " + Base64.getEncoder().encodeToString((u + ":" + p).getBytes(StandardCharsets.UTF_8)));
                }
            }
            case OAUTH_CLIENT_CREDENTIALS -> {
                String tokenUrl = s.cabeceras() == null ? null : s.cabeceras().get("tokenUrl");
                if (tokenUrl != null && sec.get("clientId") != null && sec.get("clientSecret") != null && cfg.isPresent() && llamadaDirecta(cfg.get())) {
                    h.put("Authorization", "Bearer " + token(s.clave(), tokenUrl, sec.get("clientId"), sec.get("clientSecret"),
                            s.cabeceras().get("scope")));
                }
            }
            default -> { }
        }
        return h;
    }

    public boolean esLlamadaDirecta(String ruta) {
        Optional<Configuracion> cfg = configuracion();
        return cfg.isPresent() && llamadaDirecta(cfg.get()) && servicio(cfg, ruta)
                .map(s -> s.urlPorEntorno() != null && s.urlPorEntorno().getOrDefault(cfg.get().origenDatos().entornoServicios(), "").length() > 0)
                .orElse(false);
    }

    public Optional<OrigenDatos> origenDatos() {
        return configuracion().map(Configuracion::origenDatos);
    }

    private static boolean llamadaDirecta(Configuracion c) {
        return c.origenDatos() != null && c.origenDatos().llamadaDirectaPruebas();
    }

    private static Optional<Servicio> servicio(Optional<Configuracion> cfg, String ruta) {
        return cfg.flatMap(c -> c.servicios() == null ? Optional.empty()
                : c.servicios().stream().filter(s -> ruta.equals(s.rutaGateway()) || ruta.equals(s.clave())).findFirst());
    }

    private Optional<Configuracion> configuracion() {
        long ahora = System.currentTimeMillis();
        long version = almacen.version();
        if (ahora > cacheHasta || version != cacheVersion) {
            try {
                cache = almacen.leer();
            } catch (RuntimeException e) {
                log.warn("No se pudo leer la configuración administrable; se usa la de arranque: {}", e.getMessage());
                cache = Optional.empty();
            }
            cacheHasta = ahora + CACHE_MS;
            cacheVersion = version;
        }
        return cache;
    }

    /** Client credentials (RFC 6749 §4.4) con caché por servicio hasta 30 s antes de expirar. */
    private String token(String clave, String tokenUrl, String clientId, String clientSecret, String scope) {
        Token t = tokens.get(clave);
        if (t != null && t.expira().isAfter(Instant.now().plusSeconds(30))) {
            return t.valor();
        }
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "client_credentials");
        if (scope != null && !scope.isBlank()) {
            form.add("scope", scope);
        }
        String basic = Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes(StandardCharsets.UTF_8));
        @SuppressWarnings("unchecked")
        Map<String, Object> resp = builder.build().post().uri(tokenUrl)
                .header("Authorization", "Basic " + basic)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form).retrieve().body(Map.class);
        if (resp == null || resp.get("access_token") == null) {
            throw new IllegalStateException("El servidor OAuth de " + clave + " no devolvió access_token");
        }
        long expiresIn = resp.get("expires_in") instanceof Number n ? n.longValue() : 300;
        Token nuevo = new Token(resp.get("access_token").toString(), Instant.now().plusSeconds(expiresIn));
        tokens.put(clave, nuevo);
        return nuevo.valor();
    }

    private record Token(String valor, Instant expira) {}
}
