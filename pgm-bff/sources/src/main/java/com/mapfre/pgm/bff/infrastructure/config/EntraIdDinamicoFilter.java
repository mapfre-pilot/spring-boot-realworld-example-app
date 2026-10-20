package com.mapfre.pgm.bff.infrastructure.config;

import com.mapfre.pgm.bff.application.port.in.ConfiguracionUseCase;
import com.mapfre.pgm.bff.domain.model.Configuracion;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2Error;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidatorResult;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Login Entra ID activable desde la pestaña «Configuración» en los perfiles local/simulador/pruebas: si {@code entraId.habilitado}
 * es true, toda petición a {@code /api/v1/**} (salvo la configuración pública y OPTIONS) debe llevar un JWT válido del tenant
 * configurado; si es false, se mantiene el usuario por cabeceras. En DEV/PRE/PRO el resource server es fijo (SecurityConfiguration).
 */
public class EntraIdDinamicoFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(EntraIdDinamicoFilter.class);
    private final ConfiguracionUseCase configuracion;
    private volatile NimbusJwtDecoder decoder;
    private volatile String decoderClave;

    public EntraIdDinamicoFilter(ConfiguracionUseCase configuracion) {
        this.configuracion = configuracion;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String p = request.getRequestURI();
        return !p.startsWith("/api/v1/") || p.startsWith("/api/v1/configuracion/publica") || "OPTIONS".equalsIgnoreCase(request.getMethod());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        Configuracion.Publica pub;
        try {
            pub = configuracion.publica();
        } catch (RuntimeException e) {
            log.warn("No se pudo leer la configuración de Entra ID: {}", e.getMessage());
            chain.doFilter(request, response);
            return;
        }
        if (!pub.entraIdHabilitado()) {
            chain.doFilter(request, response);
            return;
        }
        String auth = request.getHeader("Authorization");
        if (auth == null || !auth.startsWith("Bearer ")) {
            rechazar(response, "Se requiere un token de Entra ID (login activado en Configuración)");
            return;
        }
        try {
            Jwt jwt = decoder(pub).decode(auth.substring(7));
            SecurityContextHolder.getContext().setAuthentication(convertidor().convert(jwt));
            chain.doFilter(request, response);
        } catch (JwtException e) {
            rechazar(response, "Token de Entra ID no válido: " + e.getMessage());
        } finally {
            SecurityContextHolder.clearContext();
        }
    }

    private NimbusJwtDecoder decoder(Configuracion.Publica pub) {
        String issuer = pub.issuer() == null || pub.issuer().isBlank() ? "https://login.microsoftonline.com/" + pub.tenantId() + "/v2.0" : pub.issuer();
        String clave = issuer + "|" + pub.clientId();
        if (decoder == null || !clave.equals(decoderClave)) {
            String jwks = "https://login.microsoftonline.com/" + pub.tenantId() + "/discovery/v2.0/keys";
            NimbusJwtDecoder nuevo = NimbusJwtDecoder.withJwkSetUri(jwks).build();
            OAuth2TokenValidator<Jwt> audiencia = jwt -> jwt.getAudience().stream()
                    .anyMatch(a -> a.equals(pub.clientId()) || a.equals("api://" + pub.clientId()))
                    ? OAuth2TokenValidatorResult.success()
                    : OAuth2TokenValidatorResult.failure(new OAuth2Error("invalid_token", "audience inválida", null));
            nuevo.setJwtValidator(new DelegatingOAuth2TokenValidator<>(JwtValidators.createDefaultWithIssuer(issuer), audiencia));
            decoder = nuevo;
            decoderClave = clave;
        }
        return decoder;
    }

    private static JwtAuthenticationConverter convertidor() {
        JwtGrantedAuthoritiesConverter scopes = new JwtGrantedAuthoritiesConverter();
        scopes.setAuthoritiesClaimName("scp");
        scopes.setAuthorityPrefix("SCOPE_");
        JwtAuthenticationConverter c = new JwtAuthenticationConverter();
        c.setJwtGrantedAuthoritiesConverter(scopes);
        return c;
    }

    private static void rechazar(HttpServletResponse response, String detalle) throws IOException {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setHeader("WWW-Authenticate", "Bearer");
        response.setContentType(MediaType.APPLICATION_PROBLEM_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write("{\"type\":\"about:blank\",\"title\":\"Unauthorized\",\"status\":401,\"detail\":\""
                + detalle.replace("\"", "'") + "\"}");
    }
}
