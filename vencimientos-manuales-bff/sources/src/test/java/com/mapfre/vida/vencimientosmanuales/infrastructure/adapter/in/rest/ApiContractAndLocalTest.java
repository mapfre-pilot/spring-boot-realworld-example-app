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
    void postRequiereClaveDeIdempotencia() throws Exception {
        mvc.perform(post("/api/v1/cargas-fichero").contentType("application/json")
                .content("{\"tipoEmision\":\"01\"}"))
                .andExpect(status().isBadRequest());
    }
}
