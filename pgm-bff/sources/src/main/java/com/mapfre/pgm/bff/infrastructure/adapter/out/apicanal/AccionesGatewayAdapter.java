package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.AccionesClientePort;
import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

/**
 * Acciones de cabecera por el API Gateway (ARCH-FIS-COM-001). API Canal Clientes (PROD-APICANAL-CLIENTES-001:
 * contactMethods, totalClient, digitizedDocument) para lo cubierto; para el resto, los servicios que ya usa PGM en
 * Appian: Clients EDGE/Client API (avisos, interacciones, reclamaciones, documentos CDD), consentimientos (firma RGPD),
 * ACI y DPVE. Paths tomados de los objetos de integración de PGM; los cuerpos de respuesta son los sintéticos del
 * simulador hasta que PCC/dueños publiquen el contrato detallado.
 */
@Component
@Profile("!local")
public class AccionesGatewayAdapter implements AccionesClientePort {

    private static final String CLIENTES = "api-canal-clientes";
    private static final String EDGE = "clients-edge";
    private static final String ACI = "aci";
    private static final String FIRMA = "firma";
    private static final String DPVE = "dpve";

    private final GatewayClient gw;

    public AccionesGatewayAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<MasDatos> masDatos(String clienteId) {
        return gw.get(CLIENTES, "/clients/{id}/contactMethods", new ParameterizedTypeReference<MasDatos>() {},
                s -> s.uri(gw.url(CLIENTES, "/clients/{id}/contactMethods"), clienteId));
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public MasDatos actualizarContacto(String clienteId, ContactoActualizado contacto, String usuario) {
        return gw.put(CLIENTES, "/clients/" + clienteId + "/contactMethods", contacto, new ParameterizedTypeReference<MasDatos>() {});
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Comunicaciones comunicaciones(String clienteId, String periodo) {
        return gw.get(EDGE, "/negocioclientes/api/1.0/clientes/{id}/comunicaciones?periodo={p}",
                new ParameterizedTypeReference<Comunicaciones>() {},
                s -> s.uri(gw.url(EDGE, "/negocioclientes/api/1.0/clientes/{id}/comunicaciones?periodo={p}"), clienteId, periodo))
                .orElse(new Comunicaciones(List.of(), List.of(), List.of(), periodo));
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<DocumentoCliente> documentos(String clienteId, String tipo) {
        String path = "/negocioclientes/api/1.0/clientes/{id}/documentos" + (tipo == null ? "" : "?tipo=" + tipo);
        return gw.get(EDGE, path, new ParameterizedTypeReference<List<DocumentoCliente>>() {},
                s -> s.uri(gw.url(EDGE, path), clienteId)).orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public ResultadoAccion solicitarDigitalizacionDni(String clienteId, String canal, String usuario) {
        return gw.post(CLIENTES, "/clients/" + clienteId + "/digitizedDocument", Map.of("canal", canal, "usuario", usuario), ResultadoAccion.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public FirmaRgpd metodosFirmaRgpd(String clienteId) {
        return gw.get(FIRMA, "/consentimientos/api/1.0/clientes/{id}/rgpd/metodos", new ParameterizedTypeReference<FirmaRgpd>() {},
                s -> s.uri(gw.url(FIRMA, "/consentimientos/api/1.0/clientes/{id}/rgpd/metodos"), clienteId))
                .orElse(new FirmaRgpd(List.of(), "DESCONOCIDO"));
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public ResultadoAccion firmarRgpd(String clienteId, String metodo, String usuario) {
        return gw.post(FIRMA, "/consentimientos/api/1.0/clientes/" + clienteId + "/rgpd/firma",
                Map.of("metodo", metodo, "usuario", usuario), ResultadoAccion.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public ResultadoAccion altaAci(String clienteId, String usuario) {
        return gw.post(ACI, "/aci/api/1.0/clientes/" + clienteId + "/alta", Map.of("usuario", usuario), ResultadoAccion.class);
    }

    @Override
    @CircuitBreaker(name = "apicanal") @Retry(name = "apicanal-lectura")
    public Optional<ClienteTotal> clienteTotal(String clienteId) {
        return gw.get(CLIENTES, "/clients/{id}/totalClient", new ParameterizedTypeReference<ClienteTotal>() {},
                s -> s.uri(gw.url(CLIENTES, "/clients/{id}/totalClient"), clienteId));
    }

    @Override
    @CircuitBreaker(name = "apicanal")
    public ClienteTotal anadirEmpresaVinculada(String clienteId, EmpresaVinculada empresa, String usuario) {
        return gw.post(CLIENTES, "/clients/" + clienteId + "/totalClient/companies", empresa, ClienteTotal.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public PlanPagos planPagos(String clienteId) {
        return gw.get(DPVE, "/dpve/api/1.0/clientes/{id}/susceptible", new ParameterizedTypeReference<PlanPagos>() {},
                s -> s.uri(gw.url(DPVE, "/dpve/api/1.0/clientes/{id}/susceptible"), clienteId))
                .orElse(new PlanPagos(false, false, false, "Servicio DPVE no disponible"));
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public SimulacionPlanPagos simularPlanPagos(String clienteId, String tipo, String usuario) {
        return gw.post(DPVE, "/dpve/api/1.0/clientes/" + clienteId + "/simulacion", Map.of("tipo", tipo, "usuario", usuario), SimulacionPlanPagos.class);
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    public ResultadoAccion inducir(String clienteId, String canal, String usuario) {
        return gw.post(EDGE, "/negocioclientes/api/1.0/clientes/" + clienteId + "/inducciones", Map.of("canal", canal, "usuario", usuario), ResultadoAccion.class);
    }
}
