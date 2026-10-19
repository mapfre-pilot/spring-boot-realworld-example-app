package com.mapfre.pgm.bff.infrastructure.config;

import java.util.Map;
import org.springframework.boot.context.properties.ConfigurationProperties;

/** API Gateway interno: único punto de salida hacia API Canal y APIs de plataforma (ARCH-FIS-COM-001). */
@ConfigurationProperties(prefix = "pgm.gateway")
public record GatewayProperties(String baseUrl, String tenant, int connectTimeoutMs, int readTimeoutMs,
                                Map<String, String> rutas) {

    public String urlDe(String ruta) {
        String path = rutas.get(ruta);
        if (path == null) {
            throw new IllegalStateException("Ruta de gateway no configurada: " + ruta);
        }
        return baseUrl + path;
    }
}
