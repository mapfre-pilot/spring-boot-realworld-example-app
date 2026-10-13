package com.mapfre.vida.vencimientosmanuales;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@SpringBootApplication
public class VencimientosManualesBffApplication {
    public static void main(String[] args) {
        SpringApplication.run(VencimientosManualesBffApplication.class, args);
    }

    @Component
    static class StartupLog {
        private static final Logger LOGGER = LoggerFactory.getLogger(StartupLog.class);
        private final Environment environment;

        StartupLog(Environment environment) {
            this.environment = environment;
        }

        @EventListener(ApplicationReadyEvent.class)
        void reportStartup() {
            LOGGER.info("service_startup url=http://localhost:{} profile={} config_server=not_configured",
                    environment.getProperty("server.port", "8080"),
                    String.join(",", environment.getActiveProfiles()));
        }
    }
}
