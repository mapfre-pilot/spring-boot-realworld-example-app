package com.mapfre.pgm.bff.domain.model;

import java.time.Instant;
import java.util.List;
import java.util.Map;

/**
 * Configuración administrable de PGM (pestaña «Configuración», solo PGM_ADMINISTRADOR). Los secretos nunca salen del BFF:
 * en la API solo viajan enmascarados ({@link Secreto}); se guardan cifrados en el almacén de configuración.
 */
public record Configuracion(
        String entorno,
        Gateway gateway,
        List<Servicio> servicios,
        Appian appian,
        EntraId entraId,
        Map<String, Boolean> flags,
        Map<String, String> constantes,
        List<UsuarioPrueba> usuariosPrueba,
        Instant ultimaModificacion,
        String modificadoPor) {

    public record Gateway(String baseUrl, String tenant, String companyId, int connectTimeoutMs, int readTimeoutMs,
                          Map<String, String> rutas) {}

    public enum TipoAutenticacion { NINGUNA, API_KEY, OAUTH_CLIENT_CREDENTIALS, BASIC, CABECERAS, COOKIE }

    /** Servicio consumido vía Gateway: API Canal o legacy que ya usa PGM en Appian. */
    public record Servicio(String clave, String nombre, String descripcion, String rutaGateway, String origen,
                           TipoAutenticacion autenticacion, Map<String, String> urlPorEntorno, Map<String, String> cabeceras,
                           List<Secreto> credenciales, boolean habilitado) {}

    /** Valor secreto: solo se expone si está informado y sus últimos caracteres. */
    public record Secreto(String nombre, String descripcion, boolean informado, String enmascarado, String origen) {}

    public record Appian(String urlBase, String sitePgm, String siteSgo, String usuarioServicio, Map<String, String> webApis,
                         Secreto apiKey, boolean habilitado) {}

    public record EntraId(boolean habilitado, String tenantId, String clientId, String scope, String issuer, String audience,
                          List<String> redirectUris, Secreto clientSecretBff) {}

    public record UsuarioPrueba(String usuario, List<String> perfiles, String nuuma, String perfilSgc30, String descripcion) {}

    public record ResultadoPrueba(String servicio, boolean ok, Integer httpStatus, long latenciaMs, String url, String mensaje) {}

    public record ValorSecreto(String valor) {}
}
