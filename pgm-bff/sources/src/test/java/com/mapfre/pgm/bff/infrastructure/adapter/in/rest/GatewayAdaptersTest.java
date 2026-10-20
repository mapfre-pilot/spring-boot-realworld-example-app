package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static com.github.tomakehurst.wiremock.client.WireMock.equalTo;
import static com.github.tomakehurst.wiremock.client.WireMock.matching;
import static com.github.tomakehurst.wiremock.client.WireMock.postRequestedFor;
import static com.github.tomakehurst.wiremock.client.WireMock.urlPathEqualTo;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.options;
import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.tomakehurst.wiremock.WireMockServer;
import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureObservability
@ActiveProfiles("simulador")
@TestMethodOrder(OrderAnnotation.class)
class GatewayAdaptersTest {

    private static final WireMockServer GATEWAY = new WireMockServer(
            options().dynamicPort().usingFilesUnderDirectory("src/test/resources/gateway-sim"));

    static {
        GATEWAY.start();
    }

    @DynamicPropertySource
    static void gatewayProperties(DynamicPropertyRegistry registry) {
        registry.add("pgm.gateway.base-url", GATEWAY::baseUrl);
        registry.add("pgm.gateway.read-timeout-ms", () -> 250);
    }

    @AfterAll
    static void stopGateway() {
        GATEWAY.stop();
    }

    @Autowired TestRestTemplate rest;
    @Autowired ObjectMapper mapper;
    @Autowired CircuitBreakerRegistry circuitBreakers;

    @Test
    @Order(1)
    void exponeLosDatosSinteticosDeTodosLosAdaptadoresDeLectura() {
        JsonNode busqueda = get("/api/v1/clientes/search?q=martin");
        assertThat(busqueda.path("total").asInt()).isEqualTo(5);
        assertThat(busqueda.path("items").get(0).path("id").asText()).isEqualTo("C-1001");

        assertThat(get("/api/v1/clientes/C-1001/ficha").path("nombre").asText()).isEqualTo("Laura");
        assertThat(get("/api/v1/clientes/C-1001/productos").path("total").asInt()).isEqualTo(4);
        assertThat(get("/api/v1/clientes/C-1001/recibos").path("total").asInt()).isEqualTo(4);
        assertThat(get("/api/v1/clientes/C-1001/prestaciones").path("total").asInt()).isEqualTo(3);
        assertThat(get("/api/v1/clientes/C-1001/presupuestos").path("total").asInt()).isEqualTo(1);
        assertThat(get("/api/v1/clientes/C-1001/oportunidades").path("total").asInt()).isEqualTo(2);
        assertThat(get("/api/v1/clientes/C-1001/gestiones").path("total").asInt()).isEqualTo(2);
        assertThat(get("/api/v1/clientes/C-1001/solicitudes-sgo").path("total").asInt()).isEqualTo(1);
        assertThat(get("/api/v1/polizas/AUT-000100").path("numero").asText()).isEqualTo("AUT-000100");
        assertThat(get("/api/v1/polizas/AUT-000100/recibos").path("total").asInt()).isEqualTo(1);
        assertThat(get("/api/v1/recibos/R-7001").path("estado").asText()).isEqualTo("DEVUELTO");
        assertThat(get("/api/v1/cuadro-mando/kpis").path("total").asInt()).isPositive();
    }

    @Test
    @Order(2)
    void aplicaIdempotenciaAOperacionesPostYPropagaCabecerasAlGateway() {
        String traceparent = "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01";
        String tarificacion = """
                {"clienteId":"C-1001","producto":"Salud Elección Plus","codigoPostal":"28001","edades":[41,38,9],"copago":true}
                """;
        ResponseEntity<String> primera = post("/api/v1/tarificacion/salud", tarificacion, "tarificacion-1", traceparent);
        ResponseEntity<String> repetida = post("/api/v1/tarificacion/salud", tarificacion, "tarificacion-1", null);
        assertThat(primera.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(repetida.getBody()).isEqualTo(primera.getBody());
        assertThat(repetida.getHeaders().getFirst("Idempotent-Replayed")).isEqualTo("true");
        assertThat(post("/api/v1/tarificacion/salud", tarificacion.replace("Plus", "Básica"),
                "tarificacion-1", null).getStatusCode()).isEqualTo(HttpStatus.CONFLICT);

        String llamada = "{\"clienteId\":\"C-1001\",\"telefono\":\"600000001\"}";
        ResponseEntity<String> llamadaPrimera = post("/api/v1/comunicaciones/llamadas", llamada, "llamada-1", null);
        ResponseEntity<String> llamadaRepetida = post("/api/v1/comunicaciones/llamadas", llamada, "llamada-1", null);
        assertThat(llamadaRepetida.getBody()).isEqualTo(llamadaPrimera.getBody());
        assertThat(llamadaRepetida.getHeaders().getFirst("Idempotent-Replayed")).isEqualTo("true");

        String borrador = "{\"clienteId\":\"C-1001\",\"producto\":\"Salud Elección Plus\",\"codigoPostal\":\"28001\",\"edades\":[41,38,9],\"copago\":true}";
        ResponseEntity<String> borradorPrimero = post("/api/v1/tarificacion/salud/borradores", borrador, "borrador-1", null);
        ResponseEntity<String> borradorRepetido = post("/api/v1/tarificacion/salud/borradores", borrador, "borrador-1", null);
        assertThat(borradorPrimero.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(borradorRepetido.getBody()).isEqualTo(borradorPrimero.getBody());
        assertThat(borradorRepetido.getHeaders().getFirst("Location"))
                .isEqualTo(borradorPrimero.getHeaders().getFirst("Location"));
        assertThat(borradorRepetido.getHeaders().getFirst("Idempotent-Replayed")).isEqualTo("true");

        String auditoria = "{\"accion\":\"LANZADERA\",\"clienteId\":\"C-1001\",\"pantalla\":\"utilidades\"}";
        ResponseEntity<String> auditoriaPrimera = post("/api/v1/auditoria", auditoria, "auditoria-1", null);
        ResponseEntity<String> auditoriaRepetida = post("/api/v1/auditoria", auditoria, "auditoria-1", null);
        assertThat(auditoriaPrimera.getStatusCode()).isEqualTo(HttpStatus.ACCEPTED);
        assertThat(auditoriaRepetida.getStatusCode()).isEqualTo(HttpStatus.ACCEPTED);
        assertThat(auditoriaRepetida.getHeaders().getFirst("Idempotent-Replayed")).isEqualTo("true");
        assertThat(post("/api/v1/auditoria", auditoria.replace("LANZADERA", "OTRA"), "auditoria-1", null)
                .getStatusCode()).isEqualTo(HttpStatus.CONFLICT);

        GATEWAY.verify(1, postRequestedFor(urlPathEqualTo("/api-canal/ventas/v1/tarificaciones/salud"))
                .withHeader("X-Tenant", equalTo("mapfre-es"))
                .withHeader("Idempotency-Key", equalTo("tarificacion-1"))
                .withHeader("traceparent", matching("00-[0-9a-f]{32}-[0-9a-f]{16}-01")));
        GATEWAY.verify(1, postRequestedFor(urlPathEqualTo("/plataformas/comunicaciones/v1/llamadas"))
                .withHeader("Idempotency-Key", equalTo("llamada-1")));
    }

    @Test
    @Order(3)
    void normalizaFallosDelGatewayIncluidosTimeoutY404() {
        ResponseEntity<String> error = getResponse("/api/v1/clientes/C-500/ficha");
        assertThat(error.getStatusCode()).isEqualTo(HttpStatus.BAD_GATEWAY);
        assertThat(MediaType.APPLICATION_PROBLEM_JSON.isCompatibleWith(error.getHeaders().getContentType())).isTrue();
        assertThat(read(error.getBody()).path("type").asText()).isEqualTo("https://pgm.mapfre.es/problems/sistema-externo");

        assertThat(getResponse("/api/v1/clientes/C-SLOW/ficha").getStatusCode()).isEqualTo(HttpStatus.BAD_GATEWAY);
        assertThat(getResponse("/api/v1/clientes/C-404/ficha").getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }

    @Test
    @Order(4)
    void abreElCircuitBreakerTrasSuperarElUmbralDeFallos() {
        CircuitBreaker circuitBreaker = circuitBreakers.circuitBreaker("apicanal");
        for (int i = 0; i < 15 && circuitBreaker.getState() != CircuitBreaker.State.OPEN; i++) {
            HttpStatus status = HttpStatus.valueOf(getResponse("/api/v1/clientes/C-500/ficha").getStatusCode().value());
            assertThat(status).isIn(HttpStatus.BAD_GATEWAY, HttpStatus.SERVICE_UNAVAILABLE);
        }
        assertThat(circuitBreaker.getState()).isEqualTo(CircuitBreaker.State.OPEN);
        ResponseEntity<String> rechazada = getResponse("/api/v1/clientes/C-500/ficha");
        assertThat(rechazada.getStatusCode()).isEqualTo(HttpStatus.SERVICE_UNAVAILABLE);
        assertThat(read(rechazada.getBody()).path("type").asText())
                .isEqualTo("https://pgm.mapfre.es/problems/sistema-externo");
    }

    private JsonNode get(String path) {
        ResponseEntity<String> response = getResponse(path);
        assertThat(response.getStatusCode()).as(path).isEqualTo(HttpStatus.OK);
        return read(response.getBody());
    }

    private ResponseEntity<String> getResponse(String path) {
        return rest.exchange(path, HttpMethod.GET, new HttpEntity<>(headers()), String.class);
    }

    private ResponseEntity<String> post(String path, String body, String key, String traceparent) {
        HttpHeaders headers = headers();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("Idempotency-Key", key);
        if (traceparent != null) {
            headers.set("traceparent", traceparent);
        }
        return rest.exchange(path, HttpMethod.POST, new HttpEntity<>(body, headers), String.class);
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Usuario-Local", "usuario.local");
        headers.set("X-PGM-Perfiles", "PGM_USUARIO,PGM_ASESOR_COMERCIAL,PGM_VISUALIZAR_CDM");
        return headers;
    }

    private JsonNode read(String json) {
        try {
            return mapper.readTree(json);
        } catch (Exception e) {
            throw new AssertionError("Respuesta JSON inválida", e);
        }
    }
}
