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
        OrigenDatos origenDatos,
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

    /**
     * Origen de los datos por capacidad: {@code API_CANAL} (specs PROD-APICANAL-*) o {@code LEGACY} (los mismos servicios que
     * consume PGM en Appian). {@code porCapacidad} vacío o {@code HEREDAR} → se aplica {@code global}.
     * {@code llamadaDirectaPruebas}: solo para pruebas locales sin API Gateway; en DEV/PRE/PRO todo sale por el Gateway (ARCH-FIS-COM-001).
     */
    public record OrigenDatos(String global, Map<String, String> porCapacidad, boolean llamadaDirectaPruebas, String entornoServicios) {
        public static final String API_CANAL = "API_CANAL";
        public static final String LEGACY = "LEGACY";
        public static final String HEREDAR = "HEREDAR";
        public static final List<String> CAPACIDADES = List.of("clientes", "polizas", "recibos", "siniestros", "ventas");
        public String origenDe(String capacidad) {
            String o = porCapacidad == null ? null : porCapacidad.get(capacidad);
            return o == null || o.isBlank() || HEREDAR.equals(o) ? (global == null ? API_CANAL : global) : o;
        }
        public boolean esLegacy(String capacidad) {
            return LEGACY.equals(origenDe(capacidad));
        }
    }
    /** Parte no sensible de la configuración que la SPA necesita antes de autenticarse (login Entra ID dinámico). */
    public record Publica(String entorno, boolean entraIdHabilitado, String tenantId, String clientId, String scope, String issuer,
                          OrigenDatos origenDatos) {}
    public record UsuarioPrueba(String usuario, List<String> perfiles, String nuuma, String perfilSgc30, String descripcion) {}

    public record ResultadoPrueba(String servicio, boolean ok, Integer httpStatus, long latenciaMs, String url, String mensaje) {}

    public record ValorSecreto(String valor) {}
}
