package com.mapfre.pgm.bff;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;

@SpringBootApplication
@ConfigurationPropertiesScan
public class PgmBffApplication {
    private static final Logger log = LoggerFactory.getLogger(PgmBffApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(PgmBffApplication.class, args);
    }

    /** Traza de arranque exigida por ARQT-SBOOT-001: URL local, perfil activo y estado del Config Server. */
    @EventListener(ApplicationReadyEvent.class)
    void trazaArranque(ApplicationReadyEvent event) {
        Environment env = event.getApplicationContext().getEnvironment();
        String[] perfiles = env.getActiveProfiles().length > 0 ? env.getActiveProfiles() : env.getDefaultProfiles();
        String puerto = env.getProperty("local.server.port", env.getProperty("server.port", "8080"));
        String configServer = env.getProperty("spring.config.import", "no configurado");
        log.info("pgm-bff listo: url=http://localhost:{} perfil={} openapi=/v3/api-docs.yaml configServer={}",
            puerto, String.join(",", perfiles), configServer);
    }
}
