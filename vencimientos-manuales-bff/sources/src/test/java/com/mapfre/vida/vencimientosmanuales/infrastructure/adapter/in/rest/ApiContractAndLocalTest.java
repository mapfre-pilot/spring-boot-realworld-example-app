package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.ClassPathResource;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;
import org.yaml.snakeyaml.Yaml;

import java.io.InputStream;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("local")
class ApiContractAndLocalTest {
    @Autowired MockMvc mvc;
    @Autowired @Qualifier("requestMappingHandlerMapping") RequestMappingHandlerMapping mappings;

    @Test
    void todasLasRutasDelOpenApiTienenControlador() throws Exception {
        try (InputStream in = new ClassPathResource("openapi/vencimientos-manuales-bff.yaml").getInputStream()) {
            Map<?, ?> document = new Yaml().load(in);
            Map<?, ?> paths = (Map<?, ?>) document.get("paths");
            for (var pathEntry : paths.entrySet()) {
                String path = "/api/v1" + pathEntry.getKey();
                Map<?, ?> operations = (Map<?, ?>) pathEntry.getValue();
                for (Object method : operations.keySet()) {
                    String methodName = String.valueOf(method).toLowerCase();
                    if (!java.util.List.of("get", "post", "put", "patch", "delete", "head", "options", "trace")
                            .contains(methodName)) continue;
                    RequestMethod requestMethod = RequestMethod.valueOf(methodName.toUpperCase());
                    boolean exists = mappings.getHandlerMethods().keySet().stream().anyMatch(mapping ->
                            mapping.getPatternValues().contains(path)
                                    && mapping.getMethodsCondition().getMethods().contains(requestMethod));
                    assertTrue(exists, () -> requestMethod + " " + path + " no está implementado");
                }
            }
        }
    }

    @Test
    void localExponeHealthYEndpointsDeNegocio() throws Exception {
        mvc.perform(get("/monitoring/health")).andExpect(status().isOk());
        mvc.perform(get("/monitoring/prometheus")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/expedientes").param("anio", "2024").param("numero", "123456"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.content[0].numero").value("123456"));
        mvc.perform(get("/api/v1/personas").param("nif", "12345678Z"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.nombre").value("Persona de ejemplo"));
    }

    @Test
    void validaBusquedaYCoaseguro() throws Exception {
        mvc.perform(get("/api/v1/expedientes")).andExpect(status().isBadRequest())
                .andExpect(content().contentTypeCompatibleWith("application/problem+json"));
        mvc.perform(put("/api/v1/expedientes/2024/123456/coaseguro")
                .contentType("application/json")
                .content("{\"coaseguradoras\":[{\"codigo\":\"001\",\"porcentaje\":90}]}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void schemasPrincipalesCoincidenConLosDtosDeLaApi() throws Exception {
        try (InputStream in = new ClassPathResource("openapi/vencimientos-manuales-bff.yaml").getInputStream()) {
            Map<?, ?> document = new Yaml().load(in);
            Map<?, ?> components = (Map<?, ?>) document.get("components");
            Map<?, ?> schemas = (Map<?, ?>) components.get("schemas");
            assertSchemaProperties(schemas, "Expediente", "anio", "numero", "ramo", "anioPoliza",
                    "numeroPoliza", "subpoliza", "certificado", "nif", "situacion", "importeCapital",
                    "beneficios", "anticipo", "interesesPendientes", "fechaEfecto", "coaseguradoras");
            assertSchemaProperties(schemas, "BusquedaExpedientes", "anio", "numero", "ramo", "anioPoliza",
                    "numeroPoliza", "subpoliza", "certificado", "nif", "page", "size");
            assertSchemaProperties(schemas, "Coaseguro", "coaseguradoras");
            assertSchemaProperties(schemas, "Liquidacion", "capital", "prima", "complementario",
                    "liquidoCapital", "importesCoasegurados");
        }
    }

    @Test
    void controladoresExpedienteYVariablesRespondenYValidan() throws Exception {
        mvc.perform(get("/api/v1/expedientes/2024/123456"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.numero").value("123456"));
        mvc.perform(post("/api/v1/expedientes").header("Idempotency-Key", "alta-1")
                        .contentType("application/json").content("""
                                {"anio":"2024","numero":"123456","importeCapital":100.25,
                                 "coaseguradoras":[
                                   {"codigo":"A","porcentaje":25},{"codigo":"B","porcentaje":20},
                                   {"codigo":"C","porcentaje":15},{"codigo":"D","porcentaje":15},
                                   {"codigo":"E","porcentaje":15},{"codigo":"F","porcentaje":10}]}
                                """))
                .andExpect(status().isCreated()).andExpect(jsonPath("$.anio").value("2024"))
                .andExpect(jsonPath("$.coaseguradoras.length()").value(6));
        mvc.perform(post("/api/v1/expedientes").header("Idempotency-Key", "alta-invalid-1")
                        .contentType("application/json").content("{\"anio\":\"24\",\"numero\":\"123456\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(put("/api/v1/expedientes/2024/123456")
                        .contentType("application/json").content("""
                                {"anio":"2024","numero":"123456","fechaEfecto":"2024-01-15"}
                                """))
                .andExpect(status().isOk());
        mvc.perform(post("/api/v1/expedientes/2024/123456/anulacion")
                        .header("Idempotency-Key", "anulacion-1"))
                .andExpect(status().isOk());
        mvc.perform(get("/api/v1/expedientes/2024/123456/variables"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.variables").isArray());
        mvc.perform(put("/api/v1/expedientes/2024/123456/variables").contentType("application/json")
                        .content("{\"variables\":[{\"codigo\":\"TIPO\",\"valor\":\"01\"}]}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.variables[0].codigo").value("TIPO"));
        mvc.perform(put("/api/v1/expedientes/2024/123456/variables").contentType("application/json")
                        .content("{\"variables\":[{\"codigo\":\"\",\"valor\":\"01\"}]}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void controladoresCoaseguroFiscalidadPersonasYCarterasRespondenYValidan() throws Exception {
        mvc.perform(get("/api/v1/expedientes/2024/123456/coaseguro"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.coaseguradoras.length()").value(6));
        mvc.perform(put("/api/v1/expedientes/2024/123456/coaseguro").contentType("application/json")
                        .content("""
                                {"coaseguradoras":[
                                  {"codigo":"A","porcentaje":25},{"codigo":"B","porcentaje":20},
                                  {"codigo":"C","porcentaje":15},{"codigo":"D","porcentaje":15},
                                  {"codigo":"E","porcentaje":15},{"codigo":"F","porcentaje":10}
                                ]}
                                """))
                .andExpect(status().isOk()).andExpect(jsonPath("$.coaseguradoras.length()").value(6));
        mvc.perform(put("/api/v1/expedientes/2024/123456/coaseguro").contentType("application/json")
                        .content("{\"coaseguradoras\":[{\"codigo\":\"A\",\"porcentaje\":90}]}"))
                .andExpect(status().isBadRequest());
        mvc.perform(get("/api/v1/expedientes/2024/123456/fiscalidad")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/personas").param("nif", "12345678Z")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/personas").param("nif", "x")).andExpect(status().isBadRequest());
        mvc.perform(get("/api/v1/polizas/001/2020/987654/cartera")).andExpect(status().isOk());
        mvc.perform(get("/api/v1/carteras")).andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray());
        mvc.perform(get("/api/v1/carteras/listado").param("page", "0").param("size", "20"))
                .andExpect(status().isOk());
        mvc.perform(get("/api/v1/carteras/listado").param("size", "0"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void controladoresEmisionBdgiCargaYCalculoRespondenYValidan() throws Exception {
        mvc.perform(post("/api/v1/finiquitos/emisiones").header("Idempotency-Key", "finiquito-1")
                        .contentType("application/json").content("""
                                {"anio":"2024","expedienteDesde":"000001","expedienteHasta":"000010"}
                                """))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/informes").header("Idempotency-Key", "informe-1")
                        .contentType("application/json").content("{}"))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/peticiones-bdgi").header("Idempotency-Key", "bdgi-1")
                        .contentType("application/json").content("""
                                {"anioEjercicio":2024,"mesEjercicio":1,
                                 "fechaInicial":"2024-01-01","fechaFinal":"2024-01-31"}
                                """))
                .andExpect(status().isAccepted()).andExpect(jsonPath("$.solicitudId").value("bdgi-local"));
        mvc.perform(post("/api/v1/cargas-fichero").header("Idempotency-Key", "carga-1")
                        .contentType("application/json").content("{\"tipoEmision\":\"01\"}"))
                .andExpect(status().isAccepted());
        mvc.perform(post("/api/v1/cargas-fichero").header("Idempotency-Key", "carga-2")
                        .contentType("application/json").content("{\"tipoEmision\":\"\"}"))
                .andExpect(status().isBadRequest());
        mvc.perform(post("/api/v1/calculos/liquidacion").contentType("application/json").content("""
                        {"capital":{"importe":100,"rtoIntegro":100,"porcentajeRetencion":10},
                         "importeCapital":100,"coaseguradoras":[
                           {"codigo":"A","porcentaje":50},{"codigo":"B","porcentaje":50}]}
                        """))
                .andExpect(status().isOk()).andExpect(jsonPath("$.importesCoasegurados.length()").value(2));
        mvc.perform(post("/api/v1/calculos/liquidacion").contentType("application/json").content("""
                        {"importeCapital":100,"coaseguradoras":[{"codigo":"A","porcentaje":90}]}
                        """))
                .andExpect(status().isBadRequest());
    }

    private void assertSchemaProperties(Map<?, ?> schemas, String schemaName, String... properties) {
        Map<?, ?> schema = (Map<?, ?>) schemas.get(schemaName);
        Map<?, ?> actual = (Map<?, ?>) schema.get("properties");
        assertEquals(new HashSet<>(List.of(properties)), actual.keySet(),
                () -> schemaName + " no coincide con las propiedades del DTO");
    }

    @Test
    void postRequiereClaveDeIdempotencia() throws Exception {
        mvc.perform(post("/api/v1/cargas-fichero").contentType("application/json")
                .content("{\"tipoEmision\":\"01\"}"))
                .andExpect(status().isBadRequest());
    }
}
