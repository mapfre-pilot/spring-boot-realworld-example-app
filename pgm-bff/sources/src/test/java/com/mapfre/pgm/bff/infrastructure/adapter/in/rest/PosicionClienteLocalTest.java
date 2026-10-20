package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/** Posición del cliente (ronda de pruebas Appian 2026-10-20, área B): acciones de póliza, documentación, detalle por ramo, estados anteriores, recibo y prestación. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class PosicionClienteLocalTest {

    private static final String H_PERFILES = "X-PGM-Perfiles";
    private static final String H_USUARIO = "X-Usuario-Local";

    @Autowired MockMvc mvc;

    @Test
    void accionesDePolizaPorRamoYFiltroNuuma() throws Exception {
        // Autos: 9 cards en Appian; con NUUMA (usuario.local) se ven las 9, sin NUUMA se oculta SGO
        mvc.perform(get("/api/v1/polizas/AUT-000100/acciones")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(9))
                .andExpect(jsonPath("$.items[0].nombre").value("Aviso Renovación"))
                .andExpect(jsonPath("$.items[0].url", containsString("numPoliza=AUT-000100")));
        mvc.perform(get("/api/v1/polizas/AUT-000100/acciones").header(H_USUARIO, "gestor.sin.nuuma"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(8));
        mvc.perform(get("/api/v1/polizas/VID-000103/acciones")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(3))
                .andExpect(jsonPath("$.items[0].nombre").value("Consulta individual"));
        mvc.perform(get("/api/v1/polizas/NO-EXISTE/acciones")).andExpect(status().isNotFound());
    }

    @Test
    void documentacionYDetallePorRamo() throws Exception {
        mvc.perform(get("/api/v1/polizas/VID-000103/documentos")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(3));
        mvc.perform(get("/api/v1/polizas/VID-000103/detalle-ramo")).andExpect(status().isOk())
                .andExpect(jsonPath("$.garantias.length()").value(2))
                .andExpect(jsonPath("$.beneficiarios[0].parentesco").value("Cónyuge"));
        mvc.perform(get("/api/v1/polizas/VID-000103/ficha")).andExpect(status().isOk());
    }

    @Test
    void fichaAutosHogarRestringidaPorGrupo() throws Exception {
        // Sin PGM_USUARIOSGRUPOTRABAJO / PGM_GR_DETALLEHOGAR → 403 literal; con el grupo → 200
        mvc.perform(get("/api/v1/polizas/AUT-000100/ficha").header(H_PERFILES, "PGM_USUARIO"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.detail", containsString("no está disponible para tu usuario")));
        mvc.perform(get("/api/v1/polizas/HOG-000101/detalle-ramo").header(H_PERFILES, "PGM_USUARIO"))
                .andExpect(status().isForbidden());
        mvc.perform(get("/api/v1/polizas/HOG-000101/detalle-ramo").header(H_PERFILES, "PGM_USUARIO,PGM_GR_DETALLEHOGAR"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.bloques.Vivienda.Tipo").value("Piso"));
        mvc.perform(get("/api/v1/polizas/AUT-000100/ficha").header(H_PERFILES, "PGM_USUARIO,PGM_USUARIOSGRUPOTRABAJO"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.numero").value("AUT-000100"));
    }

    @Test
    void estadosAnteriores() throws Exception {
        mvc.perform(get("/api/v1/clientes/C-1001/estados-anteriores")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(1))
                .andExpect(jsonPath("$.items[0].polizaNumero").value("VID-000103"))
                .andExpect(jsonPath("$.items[0].motivoBaja", containsString("Anulación")));
        mvc.perform(get("/api/v1/clientes/C-1003/estados-anteriores")).andExpect(status().isOk())
                .andExpect(jsonPath("$.items[0].estado").value("SUSPENDIDA"));
    }

    @Test
    void menuDetalleYDuplicadoDeRecibo() throws Exception {
        mvc.perform(get("/api/v1/recibos/R-7001/acciones")).andExpect(status().isOk())
                .andExpect(jsonPath("$.total").value(3))
                .andExpect(jsonPath("$.items[0].nombre").value("Consulta Recibos"))
                .andExpect(jsonPath("$.items[1].nombre").value("Visualizar duplicado"));
        mvc.perform(get("/api/v1/recibos/R-7001/acciones").header(H_USUARIO, "gestor.sin.nuuma"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.total").value(2));
        mvc.perform(get("/api/v1/recibos/R-7001/detalle")).andExpect(status().isOk())
                .andExpect(jsonPath("$.metodoPagoLiteral").value("Domiciliación bancaria"))
                .andExpect(jsonPath("$.gestiones[0]").value("Devolución bancaria"));
        mvc.perform(post("/api/v1/recibos/R-7001/duplicado")).andExpect(status().isOk())
                .andExpect(jsonPath("$.nombreFichero").value("duplicado-R-7001.pdf"));
        mvc.perform(post("/api/v1/recibos/R-7001/duplicado").header(H_USUARIO, "gestor.sin.nuuma"))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.detail", containsString("NUUMA")));
        mvc.perform(get("/api/v1/recibos/NO/detalle")).andExpect(status().isNotFound());
    }

    @Test
    void detallePrestacion() throws Exception {
        mvc.perform(get("/api/v1/prestaciones/S-9001")).andExpect(status().isOk())
                .andExpect(jsonPath("$.codigoRamo").value("101"))
                .andExpect(jsonPath("$.hitos.length()").value(4));
        mvc.perform(get("/api/v1/prestaciones/S-0000")).andExpect(status().isNotFound());
    }
}
