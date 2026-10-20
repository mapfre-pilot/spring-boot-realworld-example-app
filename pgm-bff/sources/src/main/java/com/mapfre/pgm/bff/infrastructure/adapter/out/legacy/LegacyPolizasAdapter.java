package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.ApiCanalPolizasRecibosAdapter;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.GatewayClient;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Pólizas por los servicios legacy de PGM en Appian: carrusel {@code GET /MRCBack_be-web/api/1.0/client/{id}/policies}
 * (PGM_ClientsAPI_EDGE_PolizasClientePorIdCarrusel, CS Clients EDGE) y detalle por Denodo
 * {@code GET /server/vfdc/client/views/productsDetail} (PGM_ClientsAPI_EDGE_PolizasClientePorId, CS Clients EDGE Recibos).
 * Catálogo WLCatalog, documentación y detalle por ramo siguen por el adaptador común (ya legacy/Gateway).
 */
@Component
@Profile("!local")
public class LegacyPolizasAdapter implements PolizasPort {
    static final String PATH_POLIZAS = "/MRCBack_be-web/api/1.0/client/{id}/policies";
    static final String PATH_DETALLE = "/server/vfdc/client/views/productsDetail";
    private final GatewayClient gw;
    private final ApiCanalPolizasRecibosAdapter comun;

    public LegacyPolizasAdapter(GatewayClient gw, ApiCanalPolizasRecibosAdapter comun) {
        this.gw = gw;
        this.comun = comun;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<Poliza> porCliente(String clienteId) {
        return gw.<Object>get("clients-edge", PATH_POLIZAS, new ParameterizedTypeReference<>() {},
                        s -> s.uri(gw.url("clients-edge", PATH_POLIZAS), clienteId))
                .map(r -> JsonTolerante.lista(r, "policies", "items", "polizas").stream().map(m -> poliza(clienteId, m)).toList())
                .orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<Poliza> detalle(String numeroPoliza) {
        return gw.<Object>get("clients-edge-recibos", PATH_DETALLE, new ParameterizedTypeReference<>() {},
                        s -> s.uri(gw.url("clients-edge-recibos", PATH_DETALLE) + "?policyNumber={n}", numeroPoliza))
                .flatMap(r -> JsonTolerante.lista(r, "elements", "items", "products").stream().findFirst().map(m -> poliza(null, m)));
    }

    @Override
    public List<AccionPoliza> accionesPoliza(String numeroPoliza) {
        return comun.accionesPoliza(numeroPoliza);
    }

    @Override
    public List<DocumentoPoliza> documentosPoliza(String numeroPoliza) {
        return comun.documentosPoliza(numeroPoliza);
    }

    @Override
    public Optional<DetallePolizaRamo> detalleRamo(String numeroPoliza) {
        return comun.detalleRamo(numeroPoliza);
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<EstadoAnterior> estadosAnteriores(String clienteId) {
        // El carrusel legacy incluye las pólizas no vigentes: se filtran aquí (en Appian lo hace PGM_CompletarInfoCliente).
        return porCliente(clienteId).stream().filter(p -> p.estado() != Poliza.EstadoPoliza.EN_VIGOR)
                .map(p -> new EstadoAnterior(p.numero(), p.ramo(), p.producto(), p.estado(), p.fechaEfecto(), p.fechaVencimiento(), null)).toList();
    }

    static Poliza poliza(String clienteId, Map<String, Object> m) {
        JsonTolerante j = new JsonTolerante(m);
        String estado = Optional.ofNullable(j.texto("status", "estado", "policyStatus", "situacion")).orElse("").toUpperCase();
        Poliza.EstadoPoliza e = estado.contains("ANUL") || estado.contains("CANCEL") || estado.contains("BAJA") ? Poliza.EstadoPoliza.ANULADA
                : estado.contains("SUSP") ? Poliza.EstadoPoliza.SUSPENDIDA : Poliza.EstadoPoliza.EN_VIGOR;
        return new Poliza(j.texto("policyNumber", "numeroPoliza", "numero", "policyId"),
                Optional.ofNullable(clienteId).orElse(j.texto("clientId", "idCliente")),
                Ramos.de(j.texto("branchCode", "codigoRamo", "ramo"), j.texto("branchDescription", "branch", "descripcionRamo", "productLine")),
                j.texto("productDescription", "product", "producto", "productName"), e,
                j.fecha("effectiveDate", "fechaEfecto", "startDate"), j.fecha("expirationDate", "fechaVencimiento", "endDate", "renewalDate"),
                j.decimal("annualPremium", "primaAnual", "premium", "primaTotal"), j.texto("paymentMethod", "formaPago", "paymentFrequency"),
                j.texto("riskDescription", "riesgo", "risk", "licensePlate", "address"), List.of(), null);
    }
}
