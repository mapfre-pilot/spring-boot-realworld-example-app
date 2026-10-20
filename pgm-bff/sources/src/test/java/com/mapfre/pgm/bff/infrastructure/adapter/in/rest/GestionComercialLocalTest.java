package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.greaterThan;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Pestaña «Gestión comercial» de la ficha (ronda de pruebas Appian 2026-10-20, áreas C y D): vencimientos PGO,
 * actividad comercial iMediador, gestiones SGC 3.0, SGO y borradores, con la degradación por perfil literal de PGM.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class GestionComercialLocalTest {

    @Autowired MockMvc mvc;
    @Autowired ObjectMapper mapper;

    @Test
    void vencimientosConFiltrosContadoresYDetalle() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(2))
                .andExpect(jsonPath("$.items[0].clase").value("COMPLETO"))
                .andExpect(jsonPath("$.items[0].entidadCompetencia").value("Allianz"));
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades").param("producto", "AUTOS").param("clase", "COMPLETO"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades").param("desde", "2026-11-01").param("hasta", "2026-11-30"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1))
                .andExpect(jsonPath("$.items[0].id").value("O-1"));
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades").param("contratado", "false").param("tipo", "CROSSELLING"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades/resumen")).andExpect(status().isOk())
                .andExpect(jsonPath("$.todos").value(2)).andExpect(jsonPath("$.completos").value(1))
                .andExpect(jsonPath("$.incompletos").value(1));
        mvc.perform(get("/api/v1/oportunidades/O-1")).andExpect(status().isOk())
                .andExpect(jsonPath("$.oportunidad.id").value("O-1"))
                .andExpect(jsonPath("$.datosProducto.Producto").value("AUTOS"));
        mvc.perform(get("/api/v1/oportunidades/NO-EXISTE")).andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void altaDeVencimientoYObservacionesConNuuma() throws Exception {
        String alta = """
                {"ramo":"HOGAR","tipo":"VENCIMIENTO","fecha":"2027-01-10","entidadCompetencia":"AXA","prima":310.5,"comentarios":"Vence en enero"}
                """;
        String body = mvc.perform(post("/api/v1/clientes/C-1001/oportunidades").contentType("application/json").content(alta))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.clase").value("INCOMPLETO"))
                .andExpect(jsonPath("$.usuario").value("NU000001"))
                .andExpect(jsonPath("$.clienteId").value("C-1001"))
                .andReturn().getResponse().getContentAsString();
        String id = mapper.readTree(body).path("id").asText();
        mvc.perform(get("/api/v1/clientes/C-1001/oportunidades")).andExpect(jsonPath("$.total").value(3));

        JsonNode obs = mapper.readTree(mvc.perform(post("/api/v1/oportunidades/" + id + "/observaciones")
                        .contentType("application/json").content("{\"texto\":\"Llamar la semana que viene\"}"))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.usuario").value("NU000001"))
                .andReturn().getResponse().getContentAsString());
        mvc.perform(get("/api/v1/oportunidades/" + id)).andExpect(jsonPath("$.observaciones.length()").value(1));
        mvc.perform(delete("/api/v1/oportunidades/" + id + "/observaciones/" + obs.path("id").asText()))
                .andExpect(status().isNoContent());
        mvc.perform(get("/api/v1/oportunidades/" + id)).andExpect(jsonPath("$.observaciones.length()").value(0));
        mvc.perform(post("/api/v1/oportunidades/" + id + "/observaciones").contentType("application/json").content("{\"texto\":\"\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void sinNuumaDevuelveLosTextosLiteralesDePgm() throws Exception {
        mvc.perform(post("/api/v1/clientes/C-1001/oportunidades").contentType("application/json")
                        .content("{\"ramo\":\"AUTOS\",\"fecha\":\"2027-01-10\"}")
                        .header("X-PGM-Usuario", "gestor.sin.nuuma").header("X-PGM-Perfiles", "PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.detail").value(containsString("Esta acción aún no está disponible en PGM para tu usuario (sin Nuuma)")))
                .andExpect(jsonPath("$.detail").value(containsString("Contacta con el administrador de la aplicación")));
        mvc.perform(get("/api/v1/clientes/C-1001/actividad-comercial")
                        .header("X-PGM-Usuario", "gestor.sin.nuuma").header("X-PGM-Perfiles", "PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/gestiones/G-1")
                        .header("X-PGM-Usuario", "gestor.sin.nuuma").header("X-PGM-Perfiles", "PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/clientes/C-1001/gestiones")
                        .header("X-PGM-Usuario", "gestor.sin.nuuma").header("X-PGM-Perfiles", "PGM_ASESOR_COMERCIAL"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.detail").value("No tienes permiso para ver las gestiones"));
    }

    @Test
    void actividadComercialConFiltrosAltaYCatalogos() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/actividad-comercial")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(2))
                .andExpect(jsonPath("$.items[0].gestionAlcanzada").value("Contactado"));
        mvc.perform(get("/api/v1/clientes/C-1001/actividad-comercial").param("producto", "Vida").param("desde", "2026-10-05"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1))
                .andExpect(jsonPath("$.items[0].tipoAccion").value("Venta cruzada"));
        mvc.perform(get("/api/v1/clientes/C-1001/actividad-comercial").param("gestionAlcanzada", "Contactado").param("tipoAccion", "Renovación").param("hasta", "2026-10-31"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(1));
        mvc.perform(post("/api/v1/clientes/C-1001/actividad-comercial").contentType("application/json")
                        .content("{\"nivelGestion\":\"Interesado\",\"comentario\":\"Quiere presupuesto Hogar\",\"sinRgpd\":true}"))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.usuario").value("NU000001"))
                .andExpect(jsonPath("$.tipoAccion").value("NGA"));
        mvc.perform(get("/api/v1/clientes/C-1001/actividad-comercial")).andExpect(jsonPath("$.total").value(3));
        mvc.perform(get("/api/v1/catalogos-comerciales/NIVELES_GESTION")).andExpect(status().isOk())
                .andExpect(jsonPath("$.tipo").value("NIVELES_GESTION")).andExpect(jsonPath("$.items.length()").value(greaterThan(3)));
        mvc.perform(get("/api/v1/catalogos-comerciales/ACCIONES")).andExpect(jsonPath("$.items[0].codigo").value("LLAMADA"));
        mvc.perform(get("/api/v1/catalogos-comerciales/COMPANIAS")).andExpect(jsonPath("$.items[0].nombre").value("Allianz"));
    }

    @Test
    void gestionesSgc30DetalleCierreReaperturaYObservaciones() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/gestiones")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(2))
                .andExpect(jsonPath("$.items[0].permisos[0]").value("VIEW"))
                .andExpect(jsonPath("$.items[0].probabilidadConversion").value(75));
        mvc.perform(get("/api/v1/gestiones/G-2")).andExpect(status().isOk())
                .andExpect(jsonPath("$.gestion.estado").value("ABIERTA"))
                .andExpect(jsonPath("$.potencialidad").value("Media"))
                .andExpect(jsonPath("$.gestionesAlcanzadas.length()").value(greaterThan(0)));
        mvc.perform(post("/api/v1/gestiones/G-2/cierre").contentType("application/json").content("{\"resultado\":\"NEGATIVA\"}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.estado").value("CERRADA_NEGATIVA"));
        mvc.perform(get("/api/v1/clientes/C-1001/gestiones"))
                .andExpect(jsonPath("$.items[?(@.id=='G-2')].estado").value("CERRADA_NEGATIVA"));
        mvc.perform(post("/api/v1/gestiones/G-2/reapertura")).andExpect(status().isOk())
                .andExpect(jsonPath("$.estado").value("ABIERTA"));
        mvc.perform(post("/api/v1/gestiones/G-2/cierre").contentType("application/json").content("{\"resultado\":\"OTRA\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/gestiones/G-2/observaciones").contentType("application/json").content("{\"texto\":\"Cliente avisado\"}"))
                .andExpect(status().isCreated());
        mvc.perform(get("/api/v1/gestiones/G-2")).andExpect(jsonPath("$.observaciones.length()").value(1));
        mvc.perform(get("/api/v1/gestiones/NO")).andExpect(status().isNotFound());
        mvc.perform(post("/api/v1/gestiones/NO/cierre").contentType("application/json").content("{\"resultado\":\"POSITIVA\"}"))
                .andExpect(status().isNotFound());
    }

    @Test
    void sgoDetalleDocumentosYBorradoresDeTarificacion() throws Exception {
        String sgoId = mapper.readTree(mvc.perform(get("/api/v1/clientes/C-1001/solicitudes-sgo")).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString()).path("items").get(0).path("id").asText();
        mvc.perform(get("/api/v1/solicitudes-sgo/" + sgoId)).andExpect(status().isOk())
                .andExpect(jsonPath("$.solicitud.id").value(sgoId)).andExpect(jsonPath("$.documentos.length()").value(1));
        mvc.perform(get("/api/v1/solicitudes-sgo/" + sgoId + "/documentos")).andExpect(jsonPath("$.total").value(1));
        mvc.perform(get("/api/v1/solicitudes-sgo/NO")).andExpect(status().isNotFound());

        int antes = mapper.readTree(mvc.perform(get("/api/v1/tarificacion/salud/borradores")).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString()).path("total").asInt();
        String id = mapper.readTree(mvc.perform(post("/api/v1/tarificacion/salud/borradores").contentType("application/json")
                        .content("{\"clienteId\":\"C-1001\",\"producto\":\"Salud Elección Plus\",\"codigoPostal\":\"28001\",\"edades\":[40,8],\"copago\":false}"))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString()).path("id").asText();
        mvc.perform(get("/api/v1/tarificacion/salud/borradores")).andExpect(jsonPath("$.total").value(antes + 1))
                .andExpect(jsonPath("$.items[?(@.id=='" + id + "')].asegurados").value(2));
        mvc.perform(delete("/api/v1/tarificacion/salud/borradores/" + id)).andExpect(status().isNoContent());
        mvc.perform(delete("/api/v1/tarificacion/salud/borradores/" + id)).andExpect(status().isNotFound());
        mvc.perform(get("/api/v1/tarificacion/salud/borradores")).andExpect(jsonPath("$.total").value(antes));
    }
}
