package com.mapfre.pgm.bff.infrastructure.config;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.config.MeterFilter;
import org.springframework.boot.actuate.autoconfigure.metrics.MeterRegistryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Prometheus (/monitoring/prometheus) con etiquetas comunes y sin PII en nombres/etiquetas de métrica. */
@Configuration
public class ObservabilityConfiguration {

    @Bean
    MeterRegistryCustomizer<MeterRegistry> commonTags() {
        return registry -> registry.config()
                .commonTags("componente", "pgm-bff", "canal", "oficinas")
                .meterFilter(MeterFilter.deny(id -> id.getName().startsWith("jvm.buffer")));
    }
}
