package com.mapfre.vida.vencimientosmanuales.infrastructure.config;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.env.Environment;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(properties = {"ENTRAID_TENANT_ID=test-tenant", "ENTRAID_AUDIENCE=api://test"})
@AutoConfigureMockMvc
class SecurityAndCtgTest {
    @Autowired MockMvc mvc;
    @Autowired Environment environment;

    @Test
    void sinPerfilActivoArrancaConSeguridadPorDefecto() throws Exception {
        org.junit.jupiter.api.Assertions.assertEquals(0, environment.getActiveProfiles().length);
        mvc.perform(get("/api/v1/expedientes")).andExpect(status().isUnauthorized());
    }

    @Test
    void sinTokenResponde401YHealthEsPublico() throws Exception {
        mvc.perform(get("/api/v1/expedientes/2024/123456")).andExpect(status().isUnauthorized());
        mvc.perform(get("/monitoring/health")).andExpect(status().isOk());
    }

    @Test
    void ctgPendienteDevuelve503ConScopeDeConsulta() throws Exception {
        mvc.perform(get("/api/v1/expedientes/2024/123456")
                .with(jwt().authorities(() -> "SCOPE_vida.vencimientos.consulta")))
                .andExpect(status().isServiceUnavailable());
    }
}
