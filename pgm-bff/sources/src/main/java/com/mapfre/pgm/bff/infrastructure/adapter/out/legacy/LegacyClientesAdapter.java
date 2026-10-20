package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import com.mapfre.pgm.bff.domain.model.Direccion;
import com.mapfre.pgm.bff.domain.model.EstadoCliente;
import com.mapfre.pgm.bff.domain.model.Palancas;
import com.mapfre.pgm.bff.domain.model.Tipologia;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.GatewayClient;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.context.annotation.Profile;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Clientes por los servicios legacy que usa PGM en Appian (CS «PGM Clients EDGE»), vía Gateway:
 * búsqueda {@code POST /mrcconsultaback_int-web/api/1.0/clients/search} (PGM_ClientsEDGE_Search) y
 * ficha {@code GET /MRCConsultaBack_be-web/api/1.0/client/{id}} (PGM_ClientsAPI_EDGE_DatosClientePorId).
 * Contrato de respuesta pendiente de publicación (área E): lectura tolerante.
 */
@Component
@Profile("!local")
public class LegacyClientesAdapter implements ClientesPort {
    static final String RUTA = "clients-edge";
    static final String PATH_BUSCAR = "/mrcconsultaback_int-web/api/1.0/clients/search";
    static final String PATH_FICHA = "/MRCConsultaBack_be-web/api/1.0/client/{id}";
    private final GatewayClient gw;

    public LegacyClientesAdapter(GatewayClient gw) {
        this.gw = gw;
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    @Retry(name = "plataforma-lectura")
    public List<ClienteResumen> buscar(CriteriosBusqueda c) {
        Map<String, Object> body = new LinkedHashMap<>();
        poner(body, "documentNumber", c.documento());
        poner(body, "name", c.texto());
        poner(body, "firstSurname", c.primerApellido());
        poner(body, "secondSurname", c.segundoApellido());
        poner(body, "phone", c.telefono());
        poner(body, "email", c.email());
        poner(body, "policyNumber", c.poliza());
        poner(body, "healthCardNumber", c.tarjetaSanitaria());
        poner(body, "city", c.localidad());
        poner(body, "postalCode", c.codigoPostal());
        poner(body, "licensePlate", c.matricula());
        poner(body, "receiptNumber", c.recibo());
        poner(body, "claimNumber", c.expediente());
        poner(body, "projectNumber", c.presupuesto());
        body.put("maxResults", c.limite());
        Object resp = gw.post(RUTA, PATH_BUSCAR, body, new ParameterizedTypeReference<Object>() {});
        return JsonTolerante.lista(resp, "clients", "items", "result", "data").stream().map(LegacyClientesAdapter::resumen).limit(c.limite()).toList();
    }

    @Override
    @CircuitBreaker(name = "plataforma")
    @Retry(name = "plataforma-lectura")
    public Optional<Cliente> ficha(String clienteId) {
        return gw.<Map<String, Object>>get(RUTA, PATH_FICHA, new ParameterizedTypeReference<>() {},
                s -> s.uri(gw.url(RUTA, PATH_FICHA), clienteId)).map(m -> cliente(clienteId, m));
    }

    private static void poner(Map<String, Object> body, String k, String v) {
        if (v != null && !v.isBlank()) {
            body.put(k, v.trim());
        }
    }

    static ClienteResumen resumen(Map<String, Object> m) {
        JsonTolerante j = new JsonTolerante(m);
        JsonTolerante dir = j.objeto("address", "mainAddress", "direccion");
        return new ClienteResumen(j.texto("clientId", "id", "idCliente", "codigoCliente"),
                j.texto("name", "firstName", "nombre"),
                apellidos(j), j.texto("documentType", "tipoDocumento"), j.texto("documentNumber", "document", "documento", "nif"),
                tipologia(j), estado(j), j.texto("phone", "mobilePhone", "telefono"), j.texto("email", "mail"),
                dir.texto("city", "localidad", "poblacion"), Optional.ofNullable(j.entero("policiesInForce", "numPolizas", "activePolicies")).orElse(0),
                j.fecha("birthDate", "fechaNacimiento"), dir.texto("street", "via", "fullAddress", "direccion"), dir.texto("postalCode", "codigoPostal", "zipCode"),
                j.bool("robinson", "robinsonList"));
    }

    static Cliente cliente(String id, Map<String, Object> m) {
        JsonTolerante j = new JsonTolerante(m);
        JsonTolerante dir = j.objeto("address", "mainAddress", "direccion");
        JsonTolerante ind = j.objeto("indicators", "flags", "indicadores");
        return new Cliente(Optional.ofNullable(j.texto("clientId", "id", "idCliente")).orElse(id),
                j.texto("name", "firstName", "nombre"), apellidos(j), j.texto("documentType", "tipoDocumento"),
                j.texto("documentNumber", "document", "documento", "nif"), j.fecha("birthDate", "fechaNacimiento"),
                j.texto("nationality", "nacionalidad"), tipologia(j), estado(j), j.bool("vip") || ind.bool("vip"),
                j.bool("robinson") || ind.bool("robinson"), j.bool("exclusiveAgent", "exclusivoCorredor") || ind.bool("exclusiveAgent"),
                dir.vacio() ? null : new Direccion(dir.texto("street", "via", "fullAddress"), dir.texto("number", "numero"),
                        dir.texto("postalCode", "codigoPostal", "zipCode"), dir.texto("city", "localidad", "poblacion"), dir.texto("province", "provincia")),
                j.texto("phone", "mobilePhone", "telefono"), j.texto("email", "mail"),
                j.texto("managingOffice", "oficinaGestora", "officeCode"), j.texto("manager", "gestorAsignado", "assignedManager"),
                new Palancas(ind.bool("digitizedDocument", "dniDigitalizado"), ind.bool("gdprSigned", "rgpdFirmado", "rgpd"),
                        ind.bool("clientArea", "aci", "altaAci"), ind.bool("totalClient", "clienteTotal"),
                        ind.bool("paymentPlan", "planPagos"), ind.bool("family", "enFamilia"), ind.bool("dpv")),
                List.of(), List.of(), j.texto("bankingPosition", "posicionBancaria"), j.entero("integralityDiscount", "descuentoVinculacion"));
    }

    private static String apellidos(JsonTolerante j) {
        String completo = j.texto("surnames", "apellidos", "lastName");
        if (completo != null) {
            return completo;
        }
        String a1 = j.texto("firstSurname", "primerApellido");
        String a2 = j.texto("secondSurname", "segundoApellido");
        return ((a1 == null ? "" : a1) + " " + (a2 == null ? "" : a2)).trim();
    }

    private static Tipologia tipologia(JsonTolerante j) {
        String t = Optional.ofNullable(j.texto("clientType", "tipologia", "personType")).orElse("").toUpperCase();
        if (t.contains("EMPRESA") || t.contains("COMPANY") || t.contains("JURID") || t.equals("J")) return Tipologia.EMPRESA;
        if (t.contains("AUTONOMO") || t.contains("SELF")) return Tipologia.AUTONOMO;
        return Tipologia.PARTICULAR;
    }

    private static EstadoCliente estado(JsonTolerante j) {
        String e = Optional.ofNullable(j.texto("status", "estado", "clientStatus")).orElse("").toUpperCase();
        if (e.contains("POTENC") || e.contains("PROSPECT")) return EstadoCliente.POTENCIAL;
        if (e.contains("ANUL") || e.contains("BAJA") || e.contains("INACTIV") || e.contains("CANCEL")) return EstadoCliente.ANULADO;
        return EstadoCliente.EN_VIGOR;
    }
}
