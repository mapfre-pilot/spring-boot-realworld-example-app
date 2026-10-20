package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.ConfiguracionUseCase;
import com.mapfre.pgm.bff.application.port.in.ContextoUsuarioUseCase;
import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.out.ConfiguracionPort;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.Configuracion;
import com.mapfre.pgm.bff.domain.model.Configuracion.*;
import com.mapfre.pgm.bff.infrastructure.config.GatewayProperties;
import java.net.URI;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

/** Pestaña «Configuración»: solo PGM_ADMINISTRADOR; secretos enmascarados en la API y cifrados en el almacén. */
@Service
public class ConfiguracionService implements ConfiguracionUseCase {

    static final String MSG_SOLO_ADMIN = "La configuración solo está disponible para administradores de PGM (PGM_ADMINISTRADOR)";
    private static final Set<String> AMBITOS_FIJOS = Set.of("appian", "entraid");

    private final ConfiguracionPort almacen;
    private final ContextoUsuarioUseCase contexto;
    private final AuditoriaUseCase auditoria;
    private final GatewayProperties gateway;
    private final FeatureFlags flags;
    private final Environment env;
    private final String entraTenant;
    private final String entraClientId;
    private final String entraScope;
    private final String entraIssuer;
    private final String entraAudience;
    private final String appianUrl;

    public ConfiguracionService(ConfiguracionPort almacen, ContextoUsuarioUseCase contexto, AuditoriaUseCase auditoria,
                                GatewayProperties gateway, FeatureFlags flags, Environment env,
                                @Value("${ENTRAID_TENANT_ID:93ad25dd-8cdc-4066-9727-31a8a3024f80}") String entraTenant,
                                @Value("${pgm.entraid.audience:c4d0e5f0-4a24-4b89-a577-bd2c809f972a}") String entraAudience,
                                @Value("${ENTRAID_SCOPE:api://c4d0e5f0-4a24-4b89-a577-bd2c809f972a/pgm.acceso}") String entraScope,
                                @Value("${pgm.entraid.issuer:}") String entraIssuer,
                                @Value("${PGM_APPIAN_URL:https://mapfrespain-test.appiancloud.com}") String appianUrl) {
        this.almacen = almacen;
        this.contexto = contexto;
        this.auditoria = auditoria;
        this.gateway = gateway;
        this.flags = flags;
        this.env = env;
        this.entraTenant = entraTenant;
        this.entraClientId = entraAudience;
        this.entraScope = entraScope;
        this.entraIssuer = entraIssuer;
        this.entraAudience = entraAudience;
        this.appianUrl = appianUrl;
    }

    private void exigirAdmin(String usuario, List<String> perfiles) {
        var c = contexto.contexto(usuario, null, perfiles == null ? List.of() : perfiles);
        if (!Boolean.TRUE.equals(c.visibilidades().get(Visibilidades.CONFIGURACION))) {
            throw new AccesoNoAutorizadoException(MSG_SOLO_ADMIN);
        }
    }

    @Override
    public Configuracion obtener(String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        return conSecretosEnmascarados(almacen.leer().orElseGet(this::porDefecto));
    }

    @Override
    public Configuracion guardar(Configuracion nueva, String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        validar(nueva);
        Configuracion actual = almacen.leer().orElseGet(this::porDefecto);
        Configuracion fusion = new Configuracion(nueva.entorno() != null ? nueva.entorno() : actual.entorno(),
                nueva.gateway() != null ? nueva.gateway() : actual.gateway(),
                nueva.servicios() != null ? nueva.servicios() : actual.servicios(),
                nueva.appian() != null ? nueva.appian() : actual.appian(),
                nueva.entraId() != null ? nueva.entraId() : actual.entraId(),
                nueva.flags() != null ? nueva.flags() : actual.flags(),
                nueva.constantes() != null ? nueva.constantes() : actual.constantes(),
                nueva.usuariosPrueba() != null ? nueva.usuariosPrueba() : actual.usuariosPrueba(),
                nueva.origenDatos() != null ? nueva.origenDatos() : actual.origenDatos(),
                Instant.now(), usuario);
        almacen.escribir(fusion);
        auditoria.registrarAcceso(usuario, "CONFIGURACION_GUARDAR", null, "configuracion");
        return conSecretosEnmascarados(fusion);
    }

    @Override
    public Configuracion guardarSecreto(String ambito, String nombre, String valor, String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        if (valor == null || valor.isBlank()) throw new IllegalArgumentException("El valor del secreto no puede estar vacío");
        comprobarAmbito(ambito);
        almacen.guardarSecreto(ambito, nombre, valor);
        auditoria.registrarAcceso(usuario, "CONFIGURACION_SECRETO", null, ambito + "/" + nombre);
        return obtener(usuario, perfiles);
    }

    @Override
    public Configuracion borrarSecreto(String ambito, String nombre, String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        comprobarAmbito(ambito);
        almacen.borrarSecreto(ambito, nombre);
        auditoria.registrarAcceso(usuario, "CONFIGURACION_SECRETO_BORRAR", null, ambito + "/" + nombre);
        return obtener(usuario, perfiles);
    }

    @Override
    public ResultadoPrueba probarServicio(String clave, String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        Configuracion cfg = almacen.leer().orElseGet(this::porDefecto);
        Servicio s = cfg.servicios().stream().filter(x -> x.clave().equals(clave)).findFirst()
                .orElseThrow(() -> new RecursoNoEncontradoException("servicio", clave));
        String ruta = cfg.gateway().rutas().getOrDefault(s.rutaGateway(), "");
        String url = cfg.gateway().baseUrl().replaceAll("/$", "") + ruta + "/health";
        if (env.matchesProfiles("local")) {
            return new ResultadoPrueba(clave, true, 200, 0, url,
                    "Perfil local: sin red MAPFRE, el BFF usa datos sintéticos; la prueba real se hace con perfil simulador/corporativo");
        }
        long t0 = System.nanoTime();
        try {
            var factory = new SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(Duration.ofMillis(cfg.gateway().connectTimeoutMs()));
            factory.setReadTimeout(Duration.ofMillis(cfg.gateway().readTimeoutMs()));
            var resp = RestClient.builder().requestFactory(factory).build().get().uri(URI.create(url)).retrieve()
                    .toBodilessEntity();
            long ms = (System.nanoTime() - t0) / 1_000_000;
            return new ResultadoPrueba(clave, resp.getStatusCode().is2xxSuccessful(), resp.getStatusCode().value(), ms, url,
                    "Respuesta " + resp.getStatusCode().value());
        } catch (Exception e) {
            long ms = (System.nanoTime() - t0) / 1_000_000;
            return new ResultadoPrueba(clave, false, null, ms, url, "Sin conexión: " + e.getClass().getSimpleName() + " " + e.getMessage());
        }
    }

    @Override
    public Configuracion restaurarPorDefecto(String usuario, List<String> perfiles) {
        exigirAdmin(usuario, perfiles);
        Configuracion def = porDefecto();
        almacen.escribir(def);
        auditoria.registrarAcceso(usuario, "CONFIGURACION_RESTAURAR", null, "configuracion");
        return conSecretosEnmascarados(def);
    }

    private void comprobarAmbito(String ambito) {
        if (AMBITOS_FIJOS.contains(ambito)) return;
        Configuracion cfg = almacen.leer().orElseGet(this::porDefecto);
        if (cfg.servicios().stream().noneMatch(s -> s.clave().equals(ambito))) {
            throw new RecursoNoEncontradoException("servicio", ambito);
        }
    }

    private static void validar(Configuracion c) {
        if (c.gateway() != null) {
            if (c.gateway().baseUrl() == null || !c.gateway().baseUrl().matches("^https?://[^\\s]+$")) {
                throw new IllegalArgumentException("URL base del API Gateway no válida (debe empezar por http:// o https://)");
            }
            if (c.gateway().connectTimeoutMs() <= 0 || c.gateway().readTimeoutMs() <= 0) {
                throw new IllegalArgumentException("Los timeouts del Gateway deben ser mayores que 0 ms");
            }
            if (c.gateway().rutas() != null && c.gateway().rutas().values().stream().anyMatch(r -> r == null || !r.startsWith("/"))) {
                throw new IllegalArgumentException("Las rutas del Gateway deben empezar por /");
            }
        }
        if (c.entraId() != null && c.entraId().habilitado()) {
            if (c.entraId().tenantId() == null || !c.entraId().tenantId().matches("^[0-9a-fA-F-]{36}$")
                    || c.entraId().clientId() == null || !c.entraId().clientId().matches("^[0-9a-fA-F-]{36}$")) {
                throw new IllegalArgumentException("Tenant ID y Client ID de Entra ID deben ser GUID");
            }
        }
        if (c.origenDatos() != null) {
            OrigenDatos o = c.origenDatos();
            if (o.global() != null && !Set.of(OrigenDatos.API_CANAL, OrigenDatos.LEGACY).contains(o.global())) {
                throw new IllegalArgumentException("Origen de datos global no válido: debe ser API_CANAL o LEGACY");
            }
            if (o.porCapacidad() != null) {
                for (var e : o.porCapacidad().entrySet()) {
                    if (!OrigenDatos.CAPACIDADES.contains(e.getKey())) {
                        throw new IllegalArgumentException("Capacidad desconocida en origen de datos: " + e.getKey());
                    }
                    if (e.getValue() != null && !Set.of(OrigenDatos.API_CANAL, OrigenDatos.LEGACY, OrigenDatos.HEREDAR).contains(e.getValue())) {
                        throw new IllegalArgumentException("Origen no válido para " + e.getKey() + ": API_CANAL, LEGACY o HEREDAR");
                    }
                }
            }
            if (o.entornoServicios() != null && !Set.of("DEV", "PRE", "PRO").contains(o.entornoServicios())) {
                throw new IllegalArgumentException("Entorno de servicios no válido: DEV, PRE o PRO");
            }
        }
        if (c.appian() != null && c.appian().habilitado() && (c.appian().urlBase() == null || !c.appian().urlBase().startsWith("https://"))) {
            throw new IllegalArgumentException("La URL de Appian debe empezar por https://");
        }
    }

    /** Enmascara: muestra solo si está informado y los 4 últimos caracteres. */
    private Configuracion conSecretosEnmascarados(Configuracion c) {
        List<Servicio> servicios = new ArrayList<>();
        for (Servicio s : c.servicios()) {
            Map<String, String> sec = almacen.secretos(s.clave());
            servicios.add(new Servicio(s.clave(), s.nombre(), s.descripcion(), s.rutaGateway(), s.origen(), s.autenticacion(),
                    s.urlPorEntorno(), s.cabeceras(), s.credenciales().stream().map(cr -> enmascarar(cr, sec)).toList(), s.habilitado()));
        }
        Appian a = c.appian();
        Appian appian = a == null ? null : new Appian(a.urlBase(), a.sitePgm(), a.siteSgo(), a.usuarioServicio(), a.webApis(),
                enmascarar(a.apiKey(), almacen.secretos("appian")), a.habilitado());
        EntraId e = c.entraId();
        EntraId entra = e == null ? null : new EntraId(e.habilitado(), e.tenantId(), e.clientId(), e.scope(), e.issuer(), e.audience(),
                e.redirectUris(), enmascarar(e.clientSecretBff(), almacen.secretos("entraid")));
        return new Configuracion(c.entorno(), c.gateway(), servicios, appian, entra, c.flags(), c.constantes(), c.usuariosPrueba(),
                c.origenDatos() == null ? origenPorDefecto() : c.origenDatos(), c.ultimaModificacion(), c.modificadoPor());
    }

    private Secreto enmascarar(Secreto s, Map<String, String> valores) {
        if (s == null) return null;
        String v = valores.get(s.nombre());
        boolean informado = v != null && !v.isBlank();
        String mask = informado ? "••••••" + (v.length() > 4 ? v.substring(v.length() - 4) : "") : null;
        return new Secreto(s.nombre(), s.descripcion(), informado, mask, informado ? almacen.origenSecretos() : null);
    }

    private static Secreto sec(String nombre, String desc) {
        return new Secreto(nombre, desc, false, null, null);
    }

    private static Map<String, String> urls(String pre, String pro) {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("DEV", ""); m.put("PRE", pre); m.put("PRO", pro);
        return m;
    }

    @Override
    public Configuracion.Publica publica() {
        Configuracion c = almacen.leer().orElseGet(this::porDefecto);
        EntraId e = c.entraId();
        return new Configuracion.Publica(c.entorno(), e != null && e.habilitado(), e == null ? null : e.tenantId(),
                e == null ? null : e.clientId(), e == null ? null : e.scope(), e == null ? null : e.issuer(),
                c.origenDatos() == null ? origenPorDefecto() : c.origenDatos());
    }

    /** Perfil «pruebas» (sin API Gateway ni API Canal disponibles): legacy de PGM con URL directa de PRE; resto: API Canal vía Gateway. */
    OrigenDatos origenPorDefecto() {
        boolean pruebas = env.matchesProfiles("pruebas");
        Map<String, String> porCapacidad = new LinkedHashMap<>();
        OrigenDatos.CAPACIDADES.forEach(cap -> porCapacidad.put(cap, OrigenDatos.HEREDAR));
        return new OrigenDatos(env.getProperty("PGM_ORIGEN_DATOS", pruebas ? OrigenDatos.LEGACY : OrigenDatos.API_CANAL),
                porCapacidad, pruebas, env.getProperty("PGM_ENTORNO_SERVICIOS", "PRE"));
    }

    /** Catálogo por defecto: las 18 rutas del Gateway con la autenticación observada en los connected systems de PGM (área E). */
    Configuracion porDefecto() {
        List<Servicio> s = new ArrayList<>();
        s.add(new Servicio("api-canal-clientes", "API Canal — Clientes", "api-product-clients: búsqueda, ficha, contactMethods, totalClient, digitizedDocument", "api-canal-clientes", "API_CANAL", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("", ""), Map.of("X-Tenant", "MAPFRE_ES"), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("api-canal-polizas", "API Canal — Pólizas", "msapi-policy: detalle, documentos, detalle por ramo", "api-canal-polizas", "API_CANAL", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("", ""), Map.of(), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("api-canal-recibos", "API Canal — Recibos", "msapi-receipts", "api-canal-recibos", "API_CANAL", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("", ""), Map.of(), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("api-canal-siniestros", "API Canal — Siniestros", "msapi-accident: /accidents", "api-canal-siniestros", "API_CANAL", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("", ""), Map.of(), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("api-canal-ventas", "API Canal — Ventas (Salud)", "msapi-commercialization-health: /1.0/health/quote|resume|sign, verify, issuance", "api-canal-ventas", "API_CANAL", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("", ""), Map.of(), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("pgo", "PGO / Digital Health", "/apipgo: oportunidades, resumen, detalle, alta, observaciones, documentos", "pgo", "LEGACY", TipoAutenticacion.API_KEY, urls("https://apipgo.pre.mapfre.net", ""), Map.of("USER-ID", "{nuuma}"), List.of(sec("apiKey", "x-api-key de PGO")), true));
        s.add(new Servicio("sgc30", "SGC 3.0", "sgc3-bk-business-tasks: gestiones, cierre, reapertura, observaciones, perfil", "sgc30", "LEGACY", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("https://sgc3.pre.mapfre.net", ""), Map.of("NUUMA", "{nuuma}"), List.of(sec("clientId", "Client ID"), sec("clientSecret", "Client secret")), true));
        s.add(new Servicio("imediador", "iMediador EDGE", "/api/1.0: perfil, estructura comercial, actividad comercial, catálogos", "imediador", "LEGACY", TipoAutenticacion.API_KEY, urls("https://imediador.pre.mapfre.net", ""), Map.of("origen", "FC"), List.of(sec("apiKey", "API key iMediador")), true));
        s.add(new Servicio("bdec", "BDEC (ESTRUAGE)", "Estructura comercial", "bdec", "LEGACY", TipoAutenticacion.BASIC, urls("", ""), Map.of(), List.of(sec("usuario", "Usuario"), sec("password", "Contraseña")), true));
        s.add(new Servicio("clients-edge", "Clients EDGE (webservices.pre)", "CS «PGM Clients EDGE»: MRCConsultaBack (ficha, búsqueda, contactos), MRCBack (pólizas), negocioclientes (prestaciones, presupuestos, reclamaciones), consentimientos, GESYC consultarRecibo", "clients-edge", "LEGACY", TipoAutenticacion.BASIC, urls("https://webservices.pre.mapfre.net:26004", ""), Map.of(), List.of(sec("usuario", "Usuario Basic"), sec("password", "Contraseña Basic")), true));
        s.add(new Servicio("sgo", "SGO (Sistema de Gestión Operativa)", "ConsultarSolicitudes, ConsultarDocumentos (SOAP → fachada REST en el Gateway)", "sgo", "LEGACY", TipoAutenticacion.BASIC, urls("", ""), Map.of(), List.of(sec("usuario", "Usuario de servicio"), sec("password", "Contraseña")), true));
        s.add(new Servicio("click2call", "Click2Call (Broadsoft)", "/com.broadsoft.xsi-actions/v2.0/user/{nuuma}/calls/callmenow", "click2call", "LEGACY", TipoAutenticacion.BASIC, urls("", ""), Map.of(), List.of(sec("usuario", "Usuario XSI"), sec("password", "Contraseña XSI")), flags.clickToCall()));
        s.add(new Servicio("aci", "ACI — Área de Cliente", "crearClienteACI (alta en el Área de Cliente)", "aci", "LEGACY", TipoAutenticacion.API_KEY, urls("", ""), Map.of(), List.of(sec("apiKey", "API key")), true));
        s.add(new Servicio("firma", "Consentimientos / firma RGPD", "CMP_PM_FIRMA_RGPD_COMPLETO: biométrica, email, SMS, impresión", "firma", "LEGACY", TipoAutenticacion.API_KEY, urls("", ""), Map.of(), List.of(sec("apiKey", "API key")), true));
        s.add(new Servicio("dpve", "DPVE — Plan de pagos", "susceptibilidad y simulación de plan de pagos", "dpve", "LEGACY", TipoAutenticacion.API_KEY, urls("", ""), Map.of(), List.of(sec("apiKey", "API key")), true));
        s.add(new Servicio("wlcatalog", "WLCatalog (ESB)", "ARQ_CATALOG_SMEDWeb/sca/wICatalog: catálogo de acciones por cia+ramo (SOAP → REST)", "wlcatalog", "LEGACY", TipoAutenticacion.BASIC, urls("https://esb.pre.mapfre.net:26005", ""), Map.of(), List.of(sec("usuario", "Usuario ESB"), sec("password", "Contraseña ESB")), true));
        s.add(new Servicio("gesyc", "GESYC (recibos)", "consultarRecibo, gesycore imprimirRecibo (SOAP → REST)", "gesyc", "LEGACY", TipoAutenticacion.BASIC, urls("", ""), Map.of("NUUMA", "{nuuma}"), List.of(sec("usuario", "Usuario APPUPGM"), sec("password", "Contraseña APPUPGM")), true));
        s.add(new Servicio("mets", "METS (prestaciones)", "expedientes de siniestros", "mets", "LEGACY", TipoAutenticacion.API_KEY, urls("", ""), Map.of(), List.of(sec("apiKey", "API key")), true));
        // Legacy que usa PGM en Appian para las capacidades que API Canal cubriría (origen de datos = LEGACY)
        s.add(new Servicio("clients-edge-recibos", "Clients EDGE Recibos (Denodo)", "CS «PGM Clients EDGE Recibos»: /server/vfdc/client/views/receiptsDetail | products | productsDetail", "clients-edge-recibos", "LEGACY", TipoAutenticacion.BASIC, urls("http://denodo-prep.es.mapfre.net:26014", ""), Map.of(), List.of(sec("usuario", "Usuario Denodo"), sec("password", "Contraseña Denodo")), true));
        s.add(new Servicio("client-api", "Client API (apisb clients/1.0)", "CS «PGM Client API»: /client/{id}/receipts; scopes esp:clients/basicInfo:read, extendedInfo, address, contactMethod", "client-api", "LEGACY", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("https://apisb.mapfre.net:25003/esp/srv/api/clients/1.0", ""), Map.of("tokenUrl", "https://apisb.mapfre.net:25003/auth/oauth/v2/token", "scope", "esp:clients/basicInfo:read esp:clients/extendedInfo esp:clients/address esp:clients/contactMethod"), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("health-api", "Health API 1.0 (apisb)", "CS «PGM Health API»: /individual/simulation (tarificación), /individual/policy/{id}, /settings/commercialProducts", "health-api", "LEGACY", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("https://apisb.mapfre.com/esp/srv/api/health/1.0", ""), Map.of("tokenUrl", "https://apisb.mapfre.net:25003/auth/oauth/v2/token", "scope", "esp:health/commercialization:simulation esp:health/commercialization:policy"), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("home-api", "Home API 2.0 (apisb)", "CS «PGM Integraciones»: /esp/srv/api/home/2.0/policy/{n}/detail (Hogar, Consumo Protegido, Hipoteca Segura)", "home-api", "LEGACY", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("https://apisb.mapfre.net:25003", ""), Map.of("tokenUrl", "https://apisb.mapfre.net:25003/auth/oauth/v2/token"), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("motor-api", "Motor API 1.0 (apisb)", "CS «PGM Motor API»: /policy/{ref}/detail (Autos)", "motor-api", "LEGACY", TipoAutenticacion.OAUTH_CLIENT_CREDENTIALS, urls("https://apisb.mapfre.net:25003/srv/api/1.0/motor", ""), Map.of("tokenUrl", "https://apisb.mapfre.net:25003/auth/oauth/v2/token"), List.of(sec("clientId", "Client ID OAuth"), sec("clientSecret", "Client secret OAuth")), true));
        s.add(new Servicio("life-api", "Life Risk API 1.0", "CS «PGM Life Risk API»: /apisbcpolizas_int-web/api/life/1.0/individual/policy/{id}, unitLink, duplicado", "life-api", "LEGACY", TipoAutenticacion.BASIC, urls("https://webservices.pre.mapfre.net:26004", ""), Map.of(), List.of(sec("usuario", "Usuario"), sec("password", "Contraseña")), true));

        Map<String, Boolean> f = new LinkedHashMap<>();
        f.put("tarificacionSalud", flags.tarificacionSalud()); f.put("gestionComercial", flags.gestionComercial());
        f.put("cuadroMando", flags.cuadroMando()); f.put("clickToCall", flags.clickToCall());
        f.put("visualizacionRecibos", flags.visualizacionRecibos()); f.put("detallePrestaciones", flags.detallePrestaciones());
        f.put("mostrarExclusivoCorredor", false); f.put("mostrarDpve", false);

        Map<String, String> constantes = new LinkedHashMap<>();
        constantes.put("PGM_URL_APPS", env.getProperty("PGM_URL_APPS", "https://apps.pre.mapfre.net"));
        constantes.put("PGM_URL_NSE", env.getProperty("PGM_URL_NSE", "https://nse.pre.mapfre.net"));
        constantes.put("PGM_URL_GESALUD", env.getProperty("PGM_URL_GESALUD", "https://gesalud.pre.mapfre.net"));
        constantes.put("PGM_URL_GESVIDA", env.getProperty("PGM_URL_GESVIDA", "https://gesvida.pre.mapfre.net"));
        constantes.put("PGM_ENDPOINT_WPORTALINTERNO", "https://wportalinterno.pre.mapfre.net");
        constantes.put("PGM_ENDPOINT_ATENAUS", "https://watenaus.pre.mapfre.net/atenaus/indexatenaus.asp");
        constantes.put("PGM_URL_SGC20", "https://sgc20.mapfre.net/");
        constantes.put("PGM_URL_SVA", "https://sva.mapfre.net/");
        constantes.put("PGM_URL_CLUBMAPFRE", "https://webclub20.mapfre.net/");

        List<UsuarioPrueba> usuarios = env.matchesProfiles("local", "simulador", "pruebas") ? List.of(
                new UsuarioPrueba("usuario.local", List.of("PGM_USUARIO", "PGM_ASESOR_COMERCIAL", "PGM_VISUALIZAR_CDM", "PGM_ADMINISTRADOR"), "NU000001", "ASESOR", "Usuario por defecto del perfil local (con NUUMA y perfil SGC 3.0)"),
                new UsuarioPrueba("gestor.sin.nuuma", List.of("PGM_USUARIO"), null, null, "Sin NUUMA: ve los bloqueos literales de PGM"),
                new UsuarioPrueba("director.oficina", List.of("PGM_USUARIO", "PGM_ASESOR_COMERCIAL", "PGM_VISUALIZAR_CDM"), "NU000002", "DIRECTOR", "Director de oficina (Cuadro de Mando)")) : List.of();

        String entorno = env.matchesProfiles("local") ? "LOCAL" : env.matchesProfiles("simulador") ? "SIMULADOR"
                : env.matchesProfiles("pruebas") ? "PRUEBAS" : env.getProperty("PGM_ENTORNO", "DEV");
        Map<String, String> webApis = new LinkedHashMap<>();
        webApis.put("PGM_respuesta_search_webApi", "/suite/webapi/pgm/search");
        webApis.put("PGM_ficha_cliente_webApi", "/suite/webapi/pgm/cliente");
        webApis.put("SGO_inicioExterno", "/suite/sites/sgo");
        return new Configuracion(entorno,
                new Gateway(gateway.baseUrl(), gateway.tenant(), gateway.companyId(), gateway.connectTimeoutMs(), gateway.readTimeoutMs(), new LinkedHashMap<>(gateway.rutas())),
                s,
                new Appian(appianUrl, "/suite/sites/pgm-mapfre", "/suite/sites/sgo", "svc.pgm", webApis, sec("apiKey", "API key de las Web APIs de Appian (coexistencia PGM Appian ↔ nueva app)"), false),
                new EntraId(!env.matchesProfiles("local", "simulador", "pruebas"), entraTenant, entraClientId, entraScope,
                        entraIssuer.isBlank() ? "https://login.microsoftonline.com/" + entraTenant + "/v2.0" : entraIssuer, entraAudience,
                        List.of("http://localhost:4200", "https://pgm-dev.mapfre.net", "https://pgm-pre.mapfre.net", "https://pgm.mapfre.net"),
                        sec("clientSecret", "Client secret del BFF (solo si el BFF llama a Graph/APIs en nombre propio)")),
                f, constantes, usuarios, origenPorDefecto(), null, null);
    }
}
