package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.application.port.out.SiniestrosPort;
import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/** PROD-APICANAL-POLIZAS / RECIBOS / SINIESTROS / VENTAS por API Gateway. */
@Component
@Profile("!local")
public class ApiCanalPolizasRecibosAdapter implements PolizasPort, RecibosPort, SiniestrosPort, VentasPort {

    private final GatewayClient gw;

    public ApiCanalPolizasRecibosAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Poliza> porCliente(String clienteId) {
        return gw.<List<Poliza>>get("api-canal-clientes", "/clients/{id}/policies", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-clientes", "/clients/{id}/policies"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Poliza> detalle(String numeroPoliza) {
        return gw.get("api-canal-polizas", "/companies/{c}/policies/{n}", new ParameterizedTypeReference<Poliza>() {},
                s -> s.uri(gw.url("api-canal-polizas", "/companies/{c}/policies/{n}"), gw.companyId(), numeroPoliza));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Recibo> porClienteRecibos(String clienteId) {
        // Legacy GESYC (PGM_ServiciosRecibos_ConsultarDatosRecibo) vía Gateway: API Canal Recibos no publica consulta por cliente.
        List<Recibo> r = gw.post("clients-edge", "/gesycore_servicios_bbe-web/services/consultarRecibo",
                Map.of("clienteId", clienteId), new ParameterizedTypeReference<List<Recibo>>() {});
        return r == null ? List.of() : r;
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<Recibo> detalleRecibo(String numeroRecibo) {
        return gw.get("api-canal-recibos", "/receipts/{n}", new ParameterizedTypeReference<Recibo>() {},
                s -> s.uri(gw.url("api-canal-recibos", "/receipts/{n}"), numeroRecibo));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Prestacion> porClientePrestaciones(String clienteId) {
        return gw.<List<Prestacion>>get("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/claims", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/claims"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<Presupuesto> presupuestosPorCliente(String clienteId) {
        return gw.<List<Presupuesto>>get("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/projects", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("clients-edge", "/api_negocioclientes_int-web/api/1.0/client/{id}/projects?internalUser=true"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud solicitud) {
        return gw.post("api-canal-ventas", "/1.0/health/quote", solicitud, TarificacionSalud.Resultado.class);
    }

    // ---------- Área B: catálogo WLCatalog, documentación, detalle por ramo, GESYC y METS vía Gateway ----------
    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<AccionPoliza> accionesPoliza(String numeroPoliza) {
        // PGM API WLCatalog (ESB SOAP) expuesto como fachada REST por el Gateway: catálogo por cia+ramo
        return gw.<List<AccionPoliza>>get("wlcatalog", "/catalog/policies/{n}/actions", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("wlcatalog", "/catalog/policies/{n}/actions"), numeroPoliza)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<DocumentoPoliza> documentosPoliza(String numeroPoliza) {
        // PROD-APICANAL-POLIZAS-001: documentación de la póliza
        return gw.<List<DocumentoPoliza>>get("api-canal-polizas", "/companies/{c}/policies/{n}/documents", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-polizas", "/companies/{c}/policies/{n}/documents"), gw.companyId(), numeroPoliza)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<DetallePolizaRamo> detalleRamo(Poliza poliza) {
        Poliza.TipoDetalle tipo = poliza.tipoDetalle() == null ? switch (poliza.ramo()) {
            case AUTOS -> Poliza.TipoDetalle.AUTOS;
            case SALUD -> Poliza.TipoDetalle.SALUD;
            case VIDA, AHORRO -> Poliza.TipoDetalle.VIDA;
            case HOGAR -> Poliza.TipoDetalle.HOGAR;
            default -> Poliza.TipoDetalle.GENERICA;
        } : poliza.tipoDetalle();
        return Optional.of(new DetallePolizaRamo(poliza.numero(), poliza.ramo(), tipo, null, false,
                List.of("detalle por ramo"), Map.of(), List.of(), List.of(),
                List.of(new DisponibilidadPorOrigen("detalle por ramo", "API_CANAL", false,
                        "API Canal no publica el detalle de póliza por ramo utilizado por PGM."))));
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public List<EstadoAnterior> estadosAnteriores(String clienteId) {
        return gw.<List<EstadoAnterior>>get("api-canal-clientes", "/clients/{id}/policies?status=HISTORICAL", new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url("api-canal-clientes", "/clients/{id}/policies?status=HISTORICAL"), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<ReciboDetalle> detalleCompleto(String numeroRecibo) {
        // GESYC consultarRecibo (SOAP) → fachada REST del Gateway
        return gw.get("gesyc", "/receipts/{n}", new ParameterizedTypeReference<ReciboDetalle>() {},
                s -> s.uri(gw.url("gesyc", "/receipts/{n}"), numeroRecibo)).map(d -> new ReciboDetalle(
                d.recibo(), d.producto(), d.riesgo(), d.metodoPagoLiteral(), d.pagador(), d.estructuraComercial(),
                d.cuota(), d.comisiones(), d.gestiones(), disponibilidadPagador()));
    }

    private static List<DisponibilidadPorOrigen> disponibilidadPagador() {
        return List.of("Datos Personales", "Contacto", "Correspondencia").stream()
                .flatMap(dato -> List.of(
                        new DisponibilidadPorOrigen(dato, "API_CANAL", false,
                                "API Canal no expone los datos del pagador requeridos por PGM."),
                        new DisponibilidadPorOrigen(dato, "LEGACY", false,
                                "El adaptador legacy no mapea los campos de pagador de esta pestaña.")).stream())
                .toList();
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public DuplicadoRecibo duplicado(String numeroRecibo, String nuuma) {
        // gesycore_servicios_bbe-web/services/imprimirRecibo → fachada REST del Gateway
        return gw.post("gesyc", "/receipts/" + numeroRecibo + "/duplicate", Map.of("nuuma", nuuma), DuplicadoRecibo.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<PrestacionDetalle> detallePrestacion(String numero) {
        // METS (expedientes de siniestros) vía Gateway; API Canal Siniestros GET /accidents/{id} cuando publique el detalle
        return gw.get("mets", "/claims/{n}", new ParameterizedTypeReference<PrestacionDetalle>() {},
                s -> s.uri(gw.url("mets", "/claims/{n}"), numero));
    }
}
