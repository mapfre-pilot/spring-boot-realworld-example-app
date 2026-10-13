package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OpenApiController {
    private final Resource specification = new ClassPathResource("openapi/vencimientos-manuales-bff.yaml");

    @GetMapping(value = {"/v3/api-docs", "/v3/api-docs.yaml"}, produces = "application/yaml")
    public Resource specification() {
        return specification;
    }
}
