package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/** Criterios de aceptación ARQT-SBOOT-001 / BP-API-001 en perfil local: observabilidad, contrato, errores RFC 9457, journeys. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class ApiContractAndLocalTest {

    @Autowired MockMvc mvc;

    @Test
    void publicaContratoOpenApi() throws Exception {
        mvc.perform(get("/v3/api-docs.yaml")).andExpect(status().isOk())
                .andExpect(content().string(containsString("openapi: 3.0.3")))
                .andExpect(content().string(containsString("/clientes/search")));
    }

    @Test
    void contextoDevuelveVisibilidadesCalculadas() throws Exception {
        mvc.perform(get("/api/v1/contexto")).andExpect(status().isOk())
                .andExpect(jsonPath("$.usuario").value("usuario.local"))
                .andExpect(jsonPath("$.estructura.nuuma").value("NU000001"))
                .andExpect(jsonPath("$.visibilidades.gestionesSgc30").value(true))
                .andExpect(jsonPath("$.visibilidades.cuadroMando").value(true));
        mvc.perform(get("/api/v1/contexto").header("X-PGM-Usuario", "gestor.sin.nuuma").header("X-PGM-Perfiles", "PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.visibilidades.gestionComercial").value(true))
                .andExpect(jsonPath("$.visibilidades.gestionesSgc30").value(false))
                .andExpect(jsonPath("$.visibilidades.cuadroMando").value(false));
    }

    @Test
    void busquedaYFicha360() throws Exception {
        mvc.perform(get("/api/v1/clientes/search").param("q", "martin")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(2));
        mvc.perform(get("/api/v1/clientes/search").param("poliza", "EMP-000300")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].tipologia").value("EMPRESA"));
        mvc.perform(get("/api/v1/clientes/search")).andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_PROBLEM_JSON));
        mvc.perform(get("/api/v1/clientes/C-1001/ficha")).andExpect(status().isOk())
                .andExpect(jsonPath("$.palancas.enFamilia").value(true))
                .andExpect(jsonPath("$.alertas", hasSize(2)));
        mvc.perform(get("/api/v1/clientes/C-1004/ficha")).andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("POTENCIAL")).andExpect(jsonPath("$.robinson").value(true));
        mvc.perform(get("/api/v1/clientes/NO-EXISTE/ficha")).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.type").value("https://pgm.mapfre.es/problems/recurso-no-encontrado"));
    }

    @Test
    void pestanasDeLaFicha() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/productos")).andExpect(jsonPath("$.total").value(4));
        mvc.perform(get("/api/v1/clientes/C-1001/recibos")).andExpect(jsonPath("$.total").value(4));
        mvc.perform(get("/api/v1/clientes/C-1001/prestaciones")).andExpect(jsonPath("$.total").value(3));
        mvc.perform(get("/api/v1/clientes/C-1001/presupuestos")).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades")).andExpect(jsonPath("$.total").value(2));
        mvc.perform(get("/api/v1/clientes/C-1001/solicitudes-sgo")).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/gestiones")).andExpect(status().isOk()).andExpect(jsonPath("$.total").value(2));
        mvc.perform(get("/api/v1/clientes/C-1001/gestiones").header("X-PGM-Usuario", "gestor.sin.nuuma"))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/polizas/AUT-000100")).andExpect(jsonPath("$.ramo").value("AUTOS"));
        mvc.perform(get("/api/v1/polizas/AUT-000100/recibos")).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/recibos/R-7001")).andExpect(jsonPath("$.estado").value("DEVUELTO"));
    }

    @Test
    void lanzaderasFiltranPorRamoYNuuma() throws Exception {
        mvc.perform(get("/api/v1/lanzaderas").param("ramo", "SALUD")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[*].codigo", hasItems("GESALUD", "SGC30")))
                .andExpect(jsonPath("$.items[*].codigo", not(hasItem("NSE"))));
        mvc.perform(get("/api/v1/lanzaderas").header("X-PGM-Usuario", "gestor.sin.nuuma"))
                .andExpect(jsonPath("$.items[*].codigo", not(hasItem("SGC30"))));
    }

    @Test
    void tarificacionSaludBorradoresYValidacion() throws Exception {
        String body = "{\"clienteId\":\"C-1001\",\"producto\":\"Salud Elección Plus\",\"codigoPostal\":\"28001\",\"edades\":[41,38,9],\"copago\":true}";
        mvc.perform(post("/api/v1/tarificacion/salud").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isOk()).andExpect(jsonPath("$.primaMensual").isNumber()).andExpect(jsonPath("$.coberturas", not(empty())));
        mvc.perform(post("/api/v1/tarificacion/salud").contentType(MediaType.APPLICATION_JSON).content("{\"producto\":\"x\",\"codigoPostal\":\"2800\",\"edades\":[]}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.campos", hasItems("codigoPostal", "edades")));
        String location = mvc.perform(post("/api/v1/tarificacion/salud/borradores").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated()).andReturn().getResponse().getHeader("Location");
        mvc.perform(get(location)).andExpect(status().isOk()).andExpect(jsonPath("$.edades", hasSize(3)));
        mvc.perform(get(location).header("X-PGM-Usuario", "otro")).andExpect(status().isNotFound());
    }

    @Test
    void auditoriaYCuadroDeMando() throws Exception {
        mvc.perform(post("/api/v1/auditoria").contentType(MediaType.APPLICATION_JSON).content("{\"accion\":\"LANZADERA\",\"pantalla\":\"utilidades\"}"))
                .andExpect(status().isAccepted());
        mvc.perform(get("/api/v1/cuadro-mando/kpis")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[?(@.codigo=='lanzaderas')].valor", hasItem(greaterThanOrEqualTo(1.0))));
        mvc.perform(get("/api/v1/cuadro-mando/kpis").header("X-PGM-Perfiles", "PGM_USUARIO")).andExpect(status().isForbidden());
    }
}
