package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.github.tomakehurst.wiremock.WireMockServer;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import com.github.tomakehurst.wiremock.client.WireMock;
import static com.github.tomakehurst.wiremock.client.WireMock.equalTo;
import static com.github.tomakehurst.wiremock.client.WireMock.matchingJsonPath;
import static com.github.tomakehurst.wiremock.client.WireMock.okJson;
import static com.github.tomakehurst.wiremock.client.WireMock.postRequestedFor;
import static com.github.tomakehurst.wiremock.client.WireMock.urlEqualTo;
import static com.github.tomakehurst.wiremock.core.WireMockConfiguration.options;
import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Perfil «pruebas»: origen de datos LEGACY con llamada directa al servicio configurado en la pestaña Configuración
 * (aquí WireMock hace de Clients EDGE PRE). Comprueba el enrutado por capacidad, la URL directa y la autenticación Basic.
 */
@SpringBootTest
@AutoConfigureMockMvc
@AutoConfigureObservability
@ActiveProfiles("pruebas")
@TestPropertySource(properties = {"PGM_CONFIG_DIR=target/test-config-pruebas", "pgm.gateway.base-url=http://gateway.invalid:1"})
class OrigenLegacyPruebasTest {

    private static final WireMockServer LEGACY = new WireMockServer(options().dynamicPort());
    static { LEGACY.start(); }

    @AfterAll
    static void stop() { LEGACY.stop(); }

    /** Si una prueba activa Entra ID, el administrador queda fuera sin token: se limpia el almacén como documenta el README. */
    @org.junit.jupiter.api.AfterEach
    void limpiarAlmacen() throws Exception {
        java.nio.file.Files.deleteIfExists(java.nio.file.Path.of("target/test-config-pruebas/configuracion.json"));
    }

    @Autowired MockMvc mvc;

    @BeforeEach
    void configurar() throws Exception {
        LEGACY.resetAll();
        mvc.perform(post("/api/v1/configuracion/restaurar")).andExpect(status().isOk())
                .andExpect(jsonPath("$.entorno").value("PRUEBAS"))
                .andExpect(jsonPath("$.origenDatos.global").value("LEGACY"))
                .andExpect(jsonPath("$.origenDatos.llamadaDirectaPruebas").value(true))
                .andExpect(jsonPath("$.servicios[?(@.clave=='clients-edge')].autenticacion").value("BASIC"));
        String cfg = mvc.perform(get("/api/v1/configuracion")).andReturn().getResponse().getContentAsString();
        String conUrl = cfg.replace("\"PRE\":\"https://webservices.pre.mapfre.net:26004\"", "\"PRE\":\"" + LEGACY.baseUrl() + "\"");
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON).content(conUrl)).andExpect(status().isOk())
                .andExpect(jsonPath("$.servicios[?(@.clave=='clients-edge')].urlPorEntorno.PRE").value(LEGACY.baseUrl()));
        mvc.perform(put("/api/v1/configuracion/secretos/clients-edge/usuario").contentType(MediaType.APPLICATION_JSON).content("{\"valor\":\"APPUPGM\"}")).andExpect(status().isOk());
        mvc.perform(put("/api/v1/configuracion/secretos/clients-edge/password").contentType(MediaType.APPLICATION_JSON).content("{\"valor\":\"secreto\"}")).andExpect(status().isOk());
    }

    @Test
    void busquedaYFichaPorClientsEdgeConBasic() throws Exception {
        LEGACY.stubFor(WireMock.post(urlEqualTo("/mrcconsultaback_int-web/api/1.0/clients/search"))
                .withBasicAuth("APPUPGM", "secreto")
                .withRequestBody(matchingJsonPath("$.documentNumber", equalTo("15930307R")))
                .willReturn(okJson("{\"clients\":[{\"clientId\":\"38859674\",\"name\":\"ANA\",\"firstSurname\":\"PRUEBA\",\"secondSurname\":\"LEGACY\","
                        + "\"documentNumber\":\"15930307R\",\"documentType\":\"NIF\",\"status\":\"ACTIVO\",\"phone\":\"600000000\","
                        + "\"address\":{\"city\":\"MADRID\",\"postalCode\":\"28001\"},\"policiesInForce\":3}]}")));
        LEGACY.stubFor(WireMock.get(urlEqualTo("/MRCConsultaBack_be-web/api/1.0/client/38859674"))
                .withBasicAuth("APPUPGM", "secreto")
                .willReturn(okJson("{\"clientId\":\"38859674\",\"name\":\"ANA\",\"surnames\":\"PRUEBA LEGACY\",\"documentNumber\":\"15930307R\","
                        + "\"birthDate\":\"1980-05-01\",\"clientType\":\"PARTICULAR\",\"indicators\":{\"gdprSigned\":true,\"vip\":false},"
                        + "\"address\":{\"street\":\"CALLE MAYOR\",\"number\":\"1\",\"postalCode\":\"28001\",\"city\":\"MADRID\",\"province\":\"MADRID\"}}")));

        mvc.perform(get("/api/v1/clientes/search").param("documento", "15930307R")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].id").value("38859674"))
                .andExpect(jsonPath("$.items[0].apellidos").value("PRUEBA LEGACY"))
                .andExpect(jsonPath("$.items[0].localidad").value("MADRID"))
                .andExpect(jsonPath("$.items[0].numeroPolizasEnVigor").value(3));
        mvc.perform(get("/api/v1/clientes/38859674/ficha")).andExpect(status().isOk())
                .andExpect(jsonPath("$.documento").value("15930307R"))
                .andExpect(jsonPath("$.direccion.localidad").value("MADRID"))
                .andExpect(jsonPath("$.palancas.rgpdFirmado").value(true));
        LEGACY.verify(1, postRequestedFor(urlEqualTo("/mrcconsultaback_int-web/api/1.0/clients/search")));
    }

    @Test
    void conOrigenApiCanalNoLlamaAlLegacy() throws Exception {
        String cfg = mvc.perform(get("/api/v1/configuracion")).andReturn().getResponse().getContentAsString();
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content(cfg.replace("\"global\":\"LEGACY\"", "\"global\":\"API_CANAL\""))).andExpect(status().isOk())
                .andExpect(jsonPath("$.origenDatos.global").value("API_CANAL"));
        mvc.perform(get("/api/v1/clientes/search").param("documento", "15930307R")).andExpect(status().is5xxServerError());
        LEGACY.verify(0, postRequestedFor(urlEqualTo("/mrcconsultaback_int-web/api/1.0/clients/search")));
    }

    @Test
    void configuracionPublicaYValidaciones() throws Exception {
        mvc.perform(get("/api/v1/configuracion/publica")).andExpect(status().isOk())
                .andExpect(jsonPath("$.entraIdHabilitado").value(false))
                .andExpect(jsonPath("$.clientId").value("c4d0e5f0-4a24-4b89-a577-bd2c809f972a"))
                .andExpect(jsonPath("$.origenDatos.global").value("LEGACY"));
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content("{\"origenDatos\":{\"global\":\"ESB\",\"porCapacidad\":{},\"llamadaDirectaPruebas\":false,\"entornoServicios\":\"PRE\"}}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail", containsString("API_CANAL o LEGACY")));
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content("{\"origenDatos\":{\"global\":\"LEGACY\",\"porCapacidad\":{\"facturas\":\"LEGACY\"},\"llamadaDirectaPruebas\":false,\"entornoServicios\":\"PRE\"}}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail", containsString("Capacidad desconocida")));
    }

    @Test
    void entraIdActivadoExigeToken() throws Exception {
        String cfg = mvc.perform(get("/api/v1/configuracion")).andReturn().getResponse().getContentAsString();
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content(cfg.replace("\"entraId\":{\"habilitado\":false", "\"entraId\":{\"habilitado\":true"))).andExpect(status().isOk());
        mvc.perform(get("/api/v1/configuracion/publica")).andExpect(status().isOk()).andExpect(jsonPath("$.entraIdHabilitado").value(true));
        mvc.perform(get("/api/v1/clientes/search").param("documento", "15930307R")).andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.detail", containsString("Entra ID")));
        mvc.perform(get("/api/v1/clientes/search").param("documento", "15930307R").header("Authorization", "Bearer no-es-un-jwt"))
                .andExpect(status().isUnauthorized());
    }
}
