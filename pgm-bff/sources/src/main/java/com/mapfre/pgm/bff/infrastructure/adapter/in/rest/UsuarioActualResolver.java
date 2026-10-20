package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.infrastructure.config.LocalProperties;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import org.springframework.core.MethodParameter;
import org.springframework.core.env.Environment;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

/**
 * Resuelve {@link UsuarioActual}: en perfiles seguros desde el JWT (claims preferred_username/name/groups o roles);
 * en perfiles local/simulador desde cabeceras mock con valores por defecto.
 */
@Component
public class UsuarioActualResolver implements HandlerMethodArgumentResolver {

    private final Environment env;
    private final Optional<LocalProperties> localProps;
    private final String groupsClaim;

    public UsuarioActualResolver(Environment env, Optional<LocalProperties> localProps) {
        this.env = env;
        this.localProps = localProps;
        this.groupsClaim = env.getProperty("security.entraid.groups-claim", "groups");
    }

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return UsuarioActual.class.equals(parameter.getParameterType());
    }

    @Override
    public Object resolveArgument(MethodParameter parameter, ModelAndViewContainer mav, NativeWebRequest request,
                                  WebDataBinderFactory binderFactory) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth instanceof JwtAuthenticationToken jwtAuth) {
            Jwt jwt = jwtAuth.getToken();
            String id = Optional.ofNullable(jwt.getClaimAsString("preferred_username")).orElse(jwt.getSubject());
            String nombre = Optional.ofNullable(jwt.getClaimAsString("name")).orElse(id);
            List<String> grupos = Optional.ofNullable(jwt.getClaimAsStringList(groupsClaim))
                    .orElseGet(() -> Optional.ofNullable(jwt.getClaimAsStringList("roles")).orElse(List.of()));
            return new UsuarioActual(id, nombre, grupos);
        }
        if (!env.matchesProfiles("local", "simulador")) {
            throw new IllegalStateException("Petición sin JWT fuera del perfil local o simulador");
        }
        LocalProperties lp = localProps.orElse(new LocalProperties("usuario.local", List.of("PGM_USUARIO")));
        String id = Optional.ofNullable(request.getHeader("X-Usuario-Local"))
                .filter(s -> !s.isBlank())
                .or(() -> Optional.ofNullable(request.getHeader("X-PGM-Usuario")).filter(s -> !s.isBlank()))
                .orElse(lp.usuarioPorDefecto());
        List<String> perfiles = Optional.ofNullable(request.getHeader("X-PGM-Perfiles")).filter(s -> !s.isBlank())
                .map(s -> Arrays.stream(s.split(",")).map(String::trim).toList())
                .orElse(lp.perfilesPorDefecto());
        return new UsuarioActual(id, id, perfiles);
    }
}
