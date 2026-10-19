package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Publica el contrato OpenAPI-first (fuente única: resources/openapi/pgm-bff.yaml). */
@RestController
public class OpenApiController {

    @GetMapping(value = {"/v3/api-docs.yaml", "/v3/api-docs"}, produces = "application/yaml")
    public String openapi() throws IOException {
        return new ClassPathResource("openapi/pgm-bff.yaml").getContentAsString(StandardCharsets.UTF_8);
    }

    @GetMapping(value = "/", produces = MediaType.TEXT_PLAIN_VALUE)
    public String raiz() {
        return "pgm-bff — contrato en /v3/api-docs.yaml, salud en /monitoring/health";
    }
}
