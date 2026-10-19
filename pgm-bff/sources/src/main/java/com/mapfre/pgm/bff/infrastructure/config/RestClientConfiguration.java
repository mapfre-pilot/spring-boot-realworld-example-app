package com.mapfre.pgm.bff.infrastructure.config;

import java.time.Duration;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.web.client.RestClientCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.web.client.RestClient;

/** Cliente HTTP hacia el API Gateway: timeouts explícitos, cabecera de tenant y propagación de trazas (Micrometer). */
@Configuration
@Profile("!local")
public class RestClientConfiguration {

    @Bean
    RestClient gatewayRestClient(RestClient.Builder builder, GatewayProperties props,
                                 ObjectProvider<RestClientCustomizer> customizers) {
        JdkClientHttpRequestFactory factory = new JdkClientHttpRequestFactory();
        factory.setReadTimeout(Duration.ofMillis(props.readTimeoutMs()));
        customizers.orderedStream().forEach(c -> c.customize(builder));
        return builder
                .requestFactory(factory)
                .defaultHeader("X-Tenant", props.tenant())
                .defaultHeader("Accept", "application/json")
                .build();
    }
}
