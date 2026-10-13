package com.mapfre.vida.vencimientosmanuales.infrastructure.config;

import io.micrometer.prometheusmetrics.PrometheusConfig;
import io.micrometer.prometheusmetrics.PrometheusMeterRegistry;
import org.springframework.boot.actuate.metrics.export.prometheus.PrometheusScrapeEndpoint;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Properties;

@Configuration
public class PrometheusConfiguration {
    @Bean
    @ConditionalOnMissingBean(PrometheusMeterRegistry.class)
    PrometheusMeterRegistry prometheusMeterRegistry() {
        return new PrometheusMeterRegistry(PrometheusConfig.DEFAULT);
    }

    @Bean
    @ConditionalOnMissingBean(PrometheusScrapeEndpoint.class)
    PrometheusScrapeEndpoint prometheusScrapeEndpoint(PrometheusMeterRegistry registry) {
        return new PrometheusScrapeEndpoint(registry.getPrometheusRegistry(), new Properties());
    }
}
