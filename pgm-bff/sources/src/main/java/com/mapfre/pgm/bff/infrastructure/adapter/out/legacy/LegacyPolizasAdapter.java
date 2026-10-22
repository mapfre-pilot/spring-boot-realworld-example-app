package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.DisponibilidadPorOrigen;
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
import java.util.Locale;

/**
 * Pólizas por los servicios legacy de PGM en Appian: carrusel {@code GET /MRCBack_be-web/api/1.0/client/{id}/policies}
 * (PGM_ClientsAPI_EDGE_PolizasClientePorIdCarrusel, CS Clients EDGE) y detalle por Denodo
 * {@code GET /server/vfdc/client/views/productsDetail} (PGM_ClientsAPI_EDGE_PolizasClientePorId, CS Clients EDGE Recibos).
 * El detalle por ramo usa las integraciones legacy llamadas desde PGM_FichaPoliza, siempre vía Gateway.
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
    public Optional<DetallePolizaRamo> detalleRamo(Poliza poliza) {
        String producto = poliza.producto() == null ? "" : poliza.producto().toUpperCase(Locale.ROOT);
        String route;
        String path;
        java.util.function.Function<org.springframework.web.client.RestClient.RequestHeadersUriSpec<?>,
                org.springframework.web.client.RestClient.RequestHeadersSpec<?>> uri;
        Poliza.TipoDetalle tipo = poliza.tipoDetalle() == null ? Poliza.TipoDetalle.GENERICA : poliza.tipoDetalle();
        // La referencia SAIL define estas integraciones, pero no incluye el selector de producto de Consumo/Hipoteca.
        if (producto.contains("CONSUMO PROTEGIDO")) {
            tipo = Poliza.TipoDetalle.CONSUMO_PROTEGIDO;
            route = "home-api";
            path = gw.rutaConfigurada("home-api-detalle");
            uri = s -> s.uri(gw.url(route, path), poliza.numero());
        } else if (producto.contains("HIPOTECA SEGURA")) {
            tipo = Poliza.TipoDetalle.HIPOTECA_SEGURA;
            route = "home-api";
            path = gw.rutaConfigurada("home-api-detalle");
            uri = s -> s.uri(gw.url(route, path), poliza.numero());
        } else if (poliza.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.SALUD) {
            tipo = Poliza.TipoDetalle.SALUD;
            route = "health-api";
            path = gw.rutaConfigurada("health-api-detalle");
            uri = s -> s.uri(gw.url(route, path), poliza.numero());
        } else if (poliza.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.HOGAR) {
            tipo = Poliza.TipoDetalle.HOGAR;
            route = "home-api";
            path = gw.rutaConfigurada("home-api-detalle");
            uri = s -> s.uri(gw.url(route, path), poliza.numero());
        } else if (poliza.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.AUTOS) {
            tipo = Poliza.TipoDetalle.AUTOS;
            route = "motor-api";
            path = gw.rutaConfigurada("motor-api-detalle");
            uri = s -> s.uri(gw.url(route, path) + "?companyId={companyId}", poliza.numero(), poliza.companyId());
        } else if ((poliza.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.VIDA
                || poliza.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.AHORRO)
                && poliza.numero().length() < 11) {
            tipo = Poliza.TipoDetalle.VIDA;
            route = "life-api";
            path = gw.rutaConfigurada("life-api-detalle");
            uri = s -> s.uri(gw.url(route, path), poliza.numero());
        } else {
            return Optional.empty();
        }
        String origen = route;
        String endpoint = path;
        var requestUri = uri;
        Poliza.TipoDetalle tipoFinal = tipo;
        return gw.<Map<String, Object>>get(origen, endpoint, new ParameterizedTypeReference<>() {}, requestUri)
                .filter(body -> !body.isEmpty())
                .map(body -> mapearDetalle(poliza, tipoFinal, body));
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
                j.texto("riskDescription", "riesgo", "risk", "licensePlate", "address"), List.of(), null,
                tipoDetalle(j.texto("branchCode", "codigoRamo", "ramo"),
                        j.texto("branchDescription", "branch", "descripcionRamo", "productLine"),
                        j.texto("productDescription", "product", "producto", "productName")),
                j.texto("companyId", "companyCode", "company"));
    }

    private static Poliza.TipoDetalle tipoDetalle(String codigo, String descripcion, String producto) {
        String valor = (codigo + " " + descripcion + " " + producto).toUpperCase(Locale.ROOT);
        if (valor.contains("AUTO") || valor.contains("MOTOR")) return Poliza.TipoDetalle.AUTOS;
        if (valor.contains("SALUD")) return Poliza.TipoDetalle.SALUD;
        if (valor.contains("VIDA")) return Poliza.TipoDetalle.VIDA;
        if (valor.contains("CONSUMO")) return Poliza.TipoDetalle.CONSUMO_PROTEGIDO;
        if (valor.contains("HIPOTECA")) return Poliza.TipoDetalle.HIPOTECA_SEGURA;
        if (valor.contains("HOGAR")) return Poliza.TipoDetalle.HOGAR;
        return Poliza.TipoDetalle.GENERICA;
    }

    private static DetallePolizaRamo mapearDetalle(Poliza poliza, Poliza.TipoDetalle tipo, Map<String, Object> body) {
        JsonTolerante respuesta = new JsonTolerante(body);
        String id = switch (tipo) {
            case AUTOS -> respuesta.objeto("policyGeneralInformation").texto("referenceNumber");
            case SALUD, VIDA -> respuesta.objeto("contractData").texto("policyId");
            default -> respuesta.texto("policyId");
        };
        Map<String, String> campos = new java.util.LinkedHashMap<>();
        body.forEach((clave, valor) -> {
            if (valor instanceof String || valor instanceof Number || valor instanceof Boolean) {
                campos.put(clave, String.valueOf(valor));
            }
        });
        return new DetallePolizaRamo(poliza.numero(), poliza.ramo(), tipo, id, false,
                id == null || id.isBlank() ? List.of("idPoliza") : List.of(),
                campos.isEmpty() ? Map.of() : Map.of("Datos de póliza", Map.copyOf(campos)),
                List.of(), List.of(),
                List.of(new DisponibilidadPorOrigen("detalle por ramo", "LEGACY", id != null && !id.isBlank(),
                        id == null || id.isBlank() ? "La respuesta legacy no contiene idPoliza." : "")));
    }
}
