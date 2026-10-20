package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.domain.model.Recibo;
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
 * Recibos por los servicios legacy de PGM en Appian: lista {@code GET /client/{id}/receipts} (PGM_ClientsAPI_RecibosClientePorId,
 * CS «PGM Client API» apisb clients/1.0) y detalle por Denodo {@code GET /server/vfdc/client/views/receiptsDetail}
 * (PGM_ClientsAPI_EDGE_RecibosClientePorId). Consulta completa y duplicado GESYC van por el adaptador común (ya legacy).
 */
@Component
@Profile("!local")
public class LegacyRecibosAdapter implements RecibosPort {
    static final String PATH_LISTA = "/client/{id}/receipts";
    static final String PATH_DETALLE = "/server/vfdc/client/views/receiptsDetail";
    private final GatewayClient gw;
    private final ApiCanalPolizasRecibosAdapter comun;

    public LegacyRecibosAdapter(GatewayClient gw, ApiCanalPolizasRecibosAdapter comun) {
        this.gw = gw;
        this.comun = comun;
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public List<Recibo> porClienteRecibos(String clienteId) {
        return gw.<Object>get("client-api", PATH_LISTA, new ParameterizedTypeReference<>() {},
                        s -> s.uri(gw.url("client-api", PATH_LISTA), clienteId))
                .map(r -> JsonTolerante.lista(r, "receipts", "items", "recibos").stream().map(m -> recibo(clienteId, m)).toList())
                .orElse(List.of());
    }

    @Override
    @CircuitBreaker(name = "plataforma") @Retry(name = "plataforma-lectura")
    public Optional<Recibo> detalleRecibo(String numeroRecibo) {
        return gw.<Object>get("clients-edge-recibos", PATH_DETALLE, new ParameterizedTypeReference<>() {},
                        s -> s.uri(gw.url("clients-edge-recibos", PATH_DETALLE) + "?receiptNumber={n}", numeroRecibo))
                .flatMap(r -> JsonTolerante.lista(r, "elements", "items", "receipts").stream().findFirst().map(m -> recibo(null, m)));
    }

    @Override
    public Optional<ReciboDetalle> detalleCompleto(String numeroRecibo) {
        return comun.detalleCompleto(numeroRecibo);
    }

    @Override
    public DuplicadoRecibo duplicado(String numeroRecibo, String nuuma) {
        return comun.duplicado(numeroRecibo, nuuma);
    }

    static Recibo recibo(String clienteId, Map<String, Object> m) {
        JsonTolerante j = new JsonTolerante(m);
        String e = Optional.ofNullable(j.texto("status", "estado", "receiptStatus", "situacion")).orElse("").toUpperCase();
        Recibo.EstadoRecibo estado = e.contains("DEV") || e.contains("RETURN") || e.contains("IMPAG") ? Recibo.EstadoRecibo.DEVUELTO
                : e.contains("ANUL") || e.contains("CANCEL") ? Recibo.EstadoRecibo.ANULADO
                : e.contains("PEND") || e.contains("OUTSTANDING") ? Recibo.EstadoRecibo.PENDIENTE : Recibo.EstadoRecibo.COBRADO;
        return new Recibo(j.texto("receiptNumber", "numeroRecibo", "numero", "receiptId"),
                Optional.ofNullable(clienteId).orElse(j.texto("clientId", "idCliente")),
                j.texto("policyNumber", "numeroPoliza", "poliza"),
                Ramos.de(j.texto("branchCode", "codigoRamo"), j.texto("branchDescription", "branch", "ramo", "productDescription")),
                estado, j.decimal("amount", "importe", "totalAmount", "importeTotal"),
                j.fecha("issueDate", "fechaEmision", "emissionDate"), j.fecha("dueDate", "fechaVencimiento", "expirationDate"),
                j.texto("paymentMethod", "formaPago", "paymentType"), j.texto("maskedIban", "ibanEnmascarado", "iban"));
    }
}
