package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.actuate.observability.AutoConfigureObservability;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.test.context.ActiveProfiles;

/** ARQT-SBOOT-001: /monitoring/health, /monitoring/metrics y /monitoring/prometheus responden 200 sobre HTTP real. */
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("local")
@AutoConfigureObservability
class ObservabilityEndpointsTest {

    @Autowired TestRestTemplate rest;

    @Test
    void endpointsDeObservabilidadResponden200() {
        for (String path : new String[] {"/monitoring/health", "/monitoring/metrics", "/monitoring/prometheus"}) {
            assertThat(rest.getForEntity(path, String.class).getStatusCode()).as(path).isEqualTo(HttpStatus.OK);
        }
        assertThat(rest.getForEntity("/monitoring/prometheus", String.class).getBody()).contains("componente=\"pgm-bff\"");
    }
}
