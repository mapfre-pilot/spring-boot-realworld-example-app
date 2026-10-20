package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

/** Pestaña «Configuración»: solo administradores, secretos enmascarados y cifrados, validaciones y prueba de conexión. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
@TestPropertySource(properties = "PGM_CONFIG_DIR=target/test-config")
class ConfiguracionLocalTest {

    @Autowired MockMvc mvc;

    @Test
    void soloAdministradores() throws Exception {
        mvc.perform(get("/api/v1/configuracion").header("X-PGM-Perfiles", "PGM_USUARIO,PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.detail", containsString("PGM_ADMINISTRADOR")));
        mvc.perform(get("/api/v1/configuracion")).andExpect(status().isOk())
                .andExpect(jsonPath("$.entorno").value("LOCAL"))
                .andExpect(jsonPath("$.gateway.rutas.pgo").value("/legacy/pgo"))
                .andExpect(jsonPath("$.servicios.length()").value(24))
                .andExpect(jsonPath("$.origenDatos.global").value("API_CANAL"))
                .andExpect(jsonPath("$.origenDatos.llamadaDirectaPruebas").value(false))
                .andExpect(jsonPath("$.origenDatos.porCapacidad.clientes").value("HEREDAR"))
                .andExpect(jsonPath("$.entraId.clientId").value("c4d0e5f0-4a24-4b89-a577-bd2c809f972a"))
                .andExpect(jsonPath("$.usuariosPrueba.length()").value(3));
    }

    @Test
    void secretosEnmascaradosYCifrados() throws Exception {
        mvc.perform(put("/api/v1/configuracion/secretos/pgo/apiKey").contentType(MediaType.APPLICATION_JSON)
                .content("{\"valor\":\"clave-secreta-ABCD\"}")).andExpect(status().isOk())
                .andExpect(jsonPath("$.servicios[?(@.clave=='pgo')].credenciales[0].informado").value(true))
                .andExpect(jsonPath("$.servicios[?(@.clave=='pgo')].credenciales[0].enmascarado").value("••••••ABCD"));
        mvc.perform(get("/api/v1/configuracion")).andExpect(status().isOk())
                .andExpect(jsonPath("$..enmascarado", org.hamcrest.Matchers.not(org.hamcrest.Matchers.hasItem("clave-secreta-ABCD"))));
        mvc.perform(put("/api/v1/configuracion/secretos/pgo/apiKey").contentType(MediaType.APPLICATION_JSON).content("{\"valor\":\"\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(put("/api/v1/configuracion/secretos/inexistente/apiKey").contentType(MediaType.APPLICATION_JSON).content("{\"valor\":\"x\"}"))
                .andExpect(status().isNotFound());
        mvc.perform(delete("/api/v1/configuracion/secretos/pgo/apiKey")).andExpect(status().isOk())
                .andExpect(jsonPath("$.servicios[?(@.clave=='pgo')].credenciales[0].informado").value(false));
    }

    @Test
    void guardarValidaYPersiste() throws Exception {
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content("{\"gateway\":{\"baseUrl\":\"ftp://mal\",\"connectTimeoutMs\":1,\"readTimeoutMs\":1,\"rutas\":{}}}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail", containsString("URL base del API Gateway")));
        mvc.perform(put("/api/v1/configuracion").contentType(MediaType.APPLICATION_JSON)
                .content("{\"gateway\":{\"baseUrl\":\"https://gw.pre.mapfre.net\",\"tenant\":\"MAPFRE_ES\",\"companyId\":\"81\",\"connectTimeoutMs\":3000,\"readTimeoutMs\":8000,\"rutas\":{\"pgo\":\"/legacy/pgo\"}},\"flags\":{\"clickToCall\":false}}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.gateway.baseUrl").value("https://gw.pre.mapfre.net"))
                .andExpect(jsonPath("$.flags.clickToCall").value(false)).andExpect(jsonPath("$.modificadoPor").value("usuario.local"));
        mvc.perform(get("/api/v1/configuracion")).andExpect(jsonPath("$.gateway.readTimeoutMs").value(8000));
        mvc.perform(post("/api/v1/configuracion/servicios/pgo/prueba")).andExpect(status().isOk())
                .andExpect(jsonPath("$.ok").value(true)).andExpect(jsonPath("$.mensaje", containsString("Perfil local")));
        mvc.perform(post("/api/v1/configuracion/servicios/no-existe/prueba")).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/configuracion/restaurar")).andExpect(status().isOk())
                .andExpect(jsonPath("$.gateway.readTimeoutMs").value(greaterThanOrEqualTo(1)))
                .andExpect(jsonPath("$.servicios.length()").value(24))
                .andExpect(jsonPath("$.origenDatos.global").value("API_CANAL"))
                .andExpect(jsonPath("$.origenDatos.llamadaDirectaPruebas").value(false))
                .andExpect(jsonPath("$.origenDatos.porCapacidad.clientes").value("HEREDAR"));
    }
}
