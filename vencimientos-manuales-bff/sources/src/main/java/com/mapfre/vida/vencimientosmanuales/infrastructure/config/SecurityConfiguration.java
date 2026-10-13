package com.mapfre.vida.vencimientosmanuales.infrastructure.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.core.*;
import org.springframework.security.oauth2.jwt.*;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.*;

@Configuration
@EnableMethodSecurity
public class SecurityConfiguration {
    @Bean
    @Profile("local")
    SecurityFilterChain localSecurity(HttpSecurity http) throws Exception {
        return http.csrf(csrf -> csrf.disable())
                .cors(cors -> {})
                .authorizeHttpRequests(auth -> auth.anyRequest().permitAll())
                .build();
    }

    @Bean
    @Profile("!local")
    SecurityFilterChain secureSecurity(HttpSecurity http,
            @Value("${security.entraid.scope-consulta}") String scopeConsulta,
            @Value("${security.entraid.scope-gestion}") String scopeGestion,
            @Value("${security.entraid.role-consulta}") String roleConsulta,
            @Value("${security.entraid.role-gestion}") String roleGestion) throws Exception {
        return http.csrf(csrf -> csrf.disable())
                .cors(cors -> {})
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/monitoring/**", "/v3/api-docs", "/v3/api-docs.yaml").permitAll()
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/v1/**")
                            .hasAnyAuthority("SCOPE_" + scopeConsulta, "ROLE_" + roleConsulta,
                                    "SCOPE_" + scopeGestion, "ROLE_" + roleGestion)
                        .requestMatchers(HttpMethod.POST, "/api/v1/calculos/**")
                            .hasAnyAuthority("SCOPE_" + scopeConsulta, "ROLE_" + roleConsulta,
                                    "SCOPE_" + scopeGestion, "ROLE_" + roleGestion)
                        .requestMatchers("/api/v1/**")
                            .hasAnyAuthority("SCOPE_" + scopeGestion, "ROLE_" + roleGestion)
                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth -> oauth.jwt(jwt -> jwt.jwtAuthenticationConverter(jwtConverter())))
                .build();
    }

    @Bean
    @Profile("!local")
    JwtDecoder jwtDecoder(@Value("${security.entraid.jwk-set-uri}") String jwkSetUri,
                          @Value("${security.entraid.issuer}") String issuer,
                          @Value("${security.entraid.audience}") String audience) {
        if (issuer.endsWith("//") || audience.isBlank()) {
            throw new IllegalStateException("Configure ENTRAID_TENANT_ID y ENTRAID_AUDIENCE");
        }
        NimbusJwtDecoder decoder = NimbusJwtDecoder.withJwkSetUri(jwkSetUri).build();
        OAuth2TokenValidator<Jwt> issuerValidator = JwtValidators.createDefaultWithIssuer(issuer);
        OAuth2TokenValidator<Jwt> audienceValidator = jwt -> jwt.getAudience().contains(audience)
                ? OAuth2TokenValidatorResult.success()
                : OAuth2TokenValidatorResult.failure(new OAuth2Error("invalid_token", "audience inválida", null));
        decoder.setJwtValidator(new DelegatingOAuth2TokenValidator<>(issuerValidator, audienceValidator));
        return decoder;
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource(
            @Value("${app.cors.allowed-origins:http://localhost:4200}") String origins) {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(Arrays.stream(origins.split(",")).map(String::trim).toList());
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Idempotency-Key"));
        config.setExposedHeaders(List.of("Location"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    private Converter<Jwt, AbstractAuthenticationToken> jwtConverter() {
        JwtGrantedAuthoritiesConverter scopes = new JwtGrantedAuthoritiesConverter();
        return jwt -> {
            Collection<GrantedAuthority> authorities = new ArrayList<>(scopes.convert(jwt));
            Object roles = jwt.getClaims().get("roles");
            if (roles instanceof Collection<?> values) {
                values.stream().map(String::valueOf)
                        .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                        .forEach(authorities::add);
            }
            JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
            converter.setJwtGrantedAuthoritiesConverter(token -> authorities);
            return converter.convert(jwt);
        };
    }
}
