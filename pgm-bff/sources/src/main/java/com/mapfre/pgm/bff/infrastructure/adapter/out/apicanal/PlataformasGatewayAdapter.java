package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.ComunicacionesPort;
import com.mapfre.pgm.bff.application.port.out.GestionComercialPort;
import com.mapfre.pgm.bff.application.port.out.OportunidadesPort;
import com.mapfre.pgm.bff.application.port.out.SgoPort;
import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.domain.model.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/**
 * Servicios legacy que ya usa PGM (PGO /apipgo, SGC 3.0 business-tasks, iMediador EDGE, SGO, Click2Call) publicados en
 * el API Gateway — nunca en directo (ARCH-FIS-COM-001). Métodos y rutas tomados de los objetos de integración de PGM
 * (docs/pgm/pruebas/D y E); los esquemas de cuerpo son los sintéticos del simulador hasta recibir el contrato de cada dueño.
 */
@Component
@Profile("!local")
public class PlataformasGatewayAdapter implements OportunidadesPort, GestionComercialPort, UsuariosComercialesPort,
        SgoPort, ComunicacionesPort {

    private static final String PGO = "pgo";
    private static final String SGC = "sgc30";
    private static final String IMEDIADOR = "imediador";
    private static final String SGO = "sgo";
    private static final String BUSINESS_TASKS = "/sgc3-bk-business-tasks/api/1.0/external/business-tasks";

    private final GatewayClient gw;

    public PlataformasGatewayAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    // ---------- PGO (PGM_DigitalHealth_*) ----------

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<Oportunidad> porClienteOportunidades(String clienteId) {
        List<Oportunidad> r = gw.post(PGO, "/apipgo/client/opportunities", Map.of("clienteId", clienteId),
                new ParameterizedTypeReference<List<Oportunidad>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public ResumenOportunidades resumen(String clienteId) {
        ResumenOportunidades r = gw.post(PGO, "/apipgo/client/opportunities/summary", Map.of("clienteId", clienteId),
                ResumenOportunidades.class);
        return r == null ? new ResumenOportunidades(0, 0, 0, 0) : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<OportunidadDetalle> detalle(String oportunidadId) {
        return gw.get(PGO, "/apipgo/opportunity/{id}", new ParameterizedTypeReference<OportunidadDetalle>() {},
                s -> s.uri(gw.url(PGO, "/apipgo/opportunity/{id}"), oportunidadId));
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public Oportunidad crear(AltaOportunidad alta, String nuuma) {
        return gw.post(PGO, "/apipgo/opportunity/incomplete", Map.of("vencimiento", alta, "nuuma", nuuma), Oportunidad.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public Observacion anadirObservacion(String oportunidadId, String texto, String nuuma) {
        return gw.post(PGO, "/apipgo/opportunity/" + oportunidadId + "/observation",
                Map.of("texto", texto, "nuuma", nuuma), Observacion.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public void eliminarObservacion(String oportunidadId, String observacionId, String nuuma) {
        gw.delete(PGO, "/apipgo/opportunity/" + oportunidadId + "/observation/" + observacionId, Map.of("USER-ID", nuuma));
    }

    // ---------- SGC 3.0 (PGM_SGC30_*) ----------

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<GestionComercial> gestionesPorCliente(String clienteId) {
        List<GestionComercial> r = gw.post(SGC, BUSINESS_TASKS, Map.of("clienteId", clienteId),
                new ParameterizedTypeReference<List<GestionComercial>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<GestionDetalle> detalleGestion(String gestionId, String nuuma) {
        return gw.get(SGC, BUSINESS_TASKS + "/{id}", new ParameterizedTypeReference<GestionDetalle>() {},
                s -> s.uri(gw.url(SGC, BUSINESS_TASKS + "/{id}?preferredUsername={u}"), gestionId, nuuma));
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public GestionComercial cerrarGestion(String gestionId, String resultado, String nuuma) {
        return gw.put(SGC, BUSINESS_TASKS + "/close", Map.of("idTask", gestionId, "estado", resultado, "preferredUsername", nuuma),
                new ParameterizedTypeReference<GestionComercial>() {});
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public GestionComercial reabrirGestion(String gestionId, String nuuma) {
        return gw.put(SGC, BUSINESS_TASKS + "/reopen", Map.of("idTask", gestionId, "preferredUsername", nuuma),
                new ParameterizedTypeReference<GestionComercial>() {});
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public Observacion anadirObservacionGestion(String gestionId, String texto, String nuuma) {
        return gw.post(SGC, BUSINESS_TASKS + "/" + gestionId + "/observations",
                Map.of("texto", texto, "preferredUsername", nuuma), Observacion.class);
    }

    // ---------- iMediador EDGE (PGM_iMediadorEDGE_*) ----------

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<ActividadComercial> actividadComercial(String clienteId, String nuuma) {
        return gw.get(IMEDIADOR, "/api/1.0/contacto/actividadComercial", new ParameterizedTypeReference<List<ActividadComercial>>() {},
                s -> s.uri(gw.url(IMEDIADOR, "/api/1.0/contacto/actividadComercial?documento={d}&nuuma={n}&origen=FC"), clienteId, nuuma))
                .orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public ActividadComercial crearActividad(AltaActividad alta, String nuuma) {
        return gw.post(IMEDIADOR, "/api/1.0/contacto/insertarActividad", Map.of("actividad", alta, "nuuma", nuuma, "origen", "FC"),
                ActividadComercial.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public CatalogoComercial catalogo(CatalogoComercial.Tipo tipo, String estructura) {
        String path = switch (tipo) {
            case ACCIONES -> "/api/1.0/catalogo/acciones?estructuraComercial=" + (estructura == null ? "" : estructura);
            case NIVELES_GESTION -> "/api/1.0/catalogo/nivelesGestion?origen=FC";
            case COMPANIAS -> "/apipgo/competitor-company?type=";
        };
        String ruta = tipo == CatalogoComercial.Tipo.COMPANIAS ? PGO : IMEDIADOR;
        List<CatalogoComercial.Item> items = gw.get(ruta, path, new ParameterizedTypeReference<List<CatalogoComercial.Item>>() {},
                s -> s.uri(gw.url(ruta, path))).orElse(List.of());
        return new CatalogoComercial(tipo, items);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<EstructuraComercial> estructuraDe(String usuario) {
        return gw.get(IMEDIADOR, "/api/1.0/usuario/{u}/perfil", new ParameterizedTypeReference<EstructuraComercial>() {},
                s -> s.uri(gw.url(IMEDIADOR, "/api/1.0/usuario/{u}/perfil"), usuario));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<String> perfilSgc30De(String usuario) {
        return gw.<Map<String, String>>get(SGC, "/sgc3-bk-users/api/1.0/user/profile", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url(SGC, "/sgc3-bk-users/api/1.0/user/profile?preferredUsername={u}"), usuario)).map(m -> m.get("perfil"));
    }

    // ---------- SGO (fachada REST del Gateway sobre ConsultarSolicitudes / ConsultarDocumentos) ----------

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<SolicitudSgo> solicitudesPorCliente(String clienteId) {
        List<SolicitudSgo> r = gw.post(SGO, "/ConsultarSolicitudes", Map.of("clienteId", clienteId),
                new ParameterizedTypeReference<List<SolicitudSgo>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<SolicitudSgoDetalle> detalleSolicitud(String solicitudId) {
        return gw.get(SGO, "/ConsultarSolicitud/{id}", new ParameterizedTypeReference<SolicitudSgoDetalle>() {},
                s -> s.uri(gw.url(SGO, "/ConsultarSolicitud/{id}"), solicitudId));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<DocumentoAdjunto> documentosSolicitud(String solicitudId) {
        return gw.get(SGO, "/ConsultarDocumentos/{id}", new ParameterizedTypeReference<List<DocumentoAdjunto>>() {},
                s -> s.uri(gw.url(SGO, "/ConsultarDocumentos/{id}"), solicitudId)).orElse(List.of());
    }

    // ---------- Click2Call (PGM_ConectaOrange) ----------

    @Override
    @CircuitBreaker(name = "plataforma")
    public String iniciarLlamada(String clienteId, String telefono, String usuario) {
        Map<String, String> r = gw.post("click2call", "/com.broadsoft.xsi-actions/v2.0/user/" + usuario + "/calls/callmenow?address=" + telefono,
                Map.of("clienteId", clienteId), Map.class);
        return r == null ? null : r.get("id");
    }
}
