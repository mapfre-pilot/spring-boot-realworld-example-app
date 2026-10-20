package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.greaterThan;
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
import org.springframework.test.web.servlet.MockMvc;

/** Menú ACCIONES y palancas de la cabecera (ronda de pruebas Appian 2026-10-20, área A). */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class AccionesClienteLocalTest {

    @Autowired MockMvc mvc;

    @Test
    void masDatosYContacto() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/mas-datos")).andExpect(status().isOk())
                .andExpect(jsonPath("$.tipoPersona").value("Física"))
                .andExpect(jsonPath("$.origenDatos").isMap());
        mvc.perform(put("/api/v1/clientes/C-1001/contacto").contentType(MediaType.APPLICATION_JSON)
                .content("{\"telefonos\":[{\"tipo\":\"MOVIL\",\"motivo\":\"PERSONAL\",\"prefijo\":\"+34\",\"numero\":\"600111222\"}],\"emails\":[\"nuevo@correo.es\"]}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.emails[0]").value("nuevo@correo.es"));
        mvc.perform(put("/api/v1/clientes/C-1001/contacto").contentType(MediaType.APPLICATION_JSON)
                .content("{\"emails\":[\"malo\"]}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail").value("Email no válido"));
        mvc.perform(put("/api/v1/clientes/C-1001/contacto").contentType(MediaType.APPLICATION_JSON)
                .content("{\"telefonos\":[{\"numero\":\"12\"}]}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail").value("Formato de número de teléfono inválido"));
        mvc.perform(get("/api/v1/clientes/NO-EXISTE/mas-datos")).andExpect(status().isNotFound());
    }

    @Test
    void centroComunicacionesPorPeriodo() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/comunicaciones")).andExpect(status().isOk())
                .andExpect(jsonPath("$.periodo").value("30D")).andExpect(jsonPath("$.interacciones.length()").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/comunicaciones").param("periodo", "3A")).andExpect(status().isOk())
                .andExpect(jsonPath("$.interacciones.length()").value(3)).andExpect(jsonPath("$.reclamaciones.length()").value(1));
        mvc.perform(get("/api/v1/clientes/C-1001/comunicaciones").param("periodo", "5A")).andExpect(status().isBadRequest());
    }

    @Test
    void documentosCdd() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/documentos")).andExpect(status().isOk()).andExpect(jsonPath("$.total").value(3));
        mvc.perform(get("/api/v1/clientes/C-1001/documentos").param("tipo", "RGPD")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(1)).andExpect(jsonPath("$.items[0].clausula").value("RGPD-2024"));
    }

    @Test
    void palancasDniRgpdAci() throws Exception {
        // C-1004 (potencial Robinson, solo móvil, sin RGPD/ACI/DNI) vs C-1001 (todo firmado)
        mvc.perform(post("/api/v1/clientes/C-1001/dni/solicitud")).andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/clientes/C-1004/dni/solicitud").contentType(MediaType.APPLICATION_JSON).content("{\"canal\":\"TABLETA\"}"))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.estado").value("SOLICITADA"))
                .andExpect(jsonPath("$.mensaje", containsString("TABLETA")));
        mvc.perform(get("/api/v1/clientes/C-1004/rgpd/metodos")).andExpect(status().isOk())
                .andExpect(jsonPath("$.metodos.length()").value(4))
                .andExpect(jsonPath("$.metodos[?(@.codigo=='SMS')].disponible").value(true))
                .andExpect(jsonPath("$.metodos[?(@.codigo=='EMAIL')].disponible").value(false));
        mvc.perform(post("/api/v1/clientes/C-1004/rgpd/firma").contentType(MediaType.APPLICATION_JSON).content("{\"metodo\":\"EMAIL\"}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail", containsString("no está disponible")));
        mvc.perform(post("/api/v1/clientes/C-1001/rgpd/firma").contentType(MediaType.APPLICATION_JSON).content("{\"metodo\":\"SMS\"}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.detail", containsString("ya tiene la cláusula RGPD firmada")));
        mvc.perform(post("/api/v1/clientes/C-1004/rgpd/firma").contentType(MediaType.APPLICATION_JSON).content("{\"metodo\":\"BIOMETRICA\"}"))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.estado").value("ENVIADA"));
        mvc.perform(post("/api/v1/clientes/C-1001/aci")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail", containsString("ya está dado de alta en ACI")));
        mvc.perform(post("/api/v1/clientes/C-1003/aci")).andExpect(status().isAccepted())
                .andExpect(jsonPath("$.referencia", containsString("ACI-")));
    }

    @Test
    void clienteTotalPlanPagosEInduccion() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/cliente-total")).andExpect(status().isOk()).andExpect(jsonPath("$.nif").exists());
        mvc.perform(post("/api/v1/clientes/C-1001/cliente-total/empresas").contentType(MediaType.APPLICATION_JSON)
                .content("{\"cif\":\"MALO\"}")).andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/clientes/C-1001/cliente-total/empresas").contentType(MediaType.APPLICATION_JSON)
                .content("{\"cif\":\"B12345674\",\"razonSocial\":\"Talleres Prueba SL\",\"cargo\":\"Administrador\"}"))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.empresas.length()", greaterThan(0)))
                .andExpect(jsonPath("$.empresas[0].estado").value("PENDIENTE_FIRMA"));
        mvc.perform(get("/api/v1/clientes/C-1004/plan-pagos")).andExpect(status().isOk())
                .andExpect(jsonPath("$.susceptible").value(false));
        mvc.perform(post("/api/v1/clientes/C-1004/plan-pagos/simulacion").contentType(MediaType.APPLICATION_JSON).content("{\"tipo\":\"INDIVIDUAL\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/clientes/C-1001/plan-pagos/simulacion").contentType(MediaType.APPLICATION_JSON).content("{\"tipo\":\"OTRO\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/clientes/C-1004/inducciones")).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.detail", containsString("robinson")));
        mvc.perform(post("/api/v1/clientes/C-1001/inducciones").contentType(MediaType.APPLICATION_JSON).content("{\"canal\":\"EMAIL\"}"))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.mensaje", containsString("EMAIL")));
    }
}
