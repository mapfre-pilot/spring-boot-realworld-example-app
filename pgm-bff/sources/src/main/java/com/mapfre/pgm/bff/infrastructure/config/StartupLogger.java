package com.mapfre.pgm.bff.infrastructure.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/** ARQT-SBOOT-001: el log de arranque muestra URL local, perfil activo y estado del Config Server. */
@Component
public class StartupLogger {

    private static final Logger log = LoggerFactory.getLogger(StartupLogger.class);
    private final Environment env;

    public StartupLogger(Environment env) {
        this.env = env;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void onReady() {
        String port = env.getProperty("local.server.port", env.getProperty("server.port", "8080"));
        String perfiles = String.join(",", env.getActiveProfiles().length == 0 ? env.getDefaultProfiles() : env.getActiveProfiles());
        boolean configServer = Boolean.parseBoolean(env.getProperty("spring.cloud.config.enabled", "false"));
        log.info("pgm-bff arrancado | url=http://localhost:{} | perfil={} | configServer={} | health=http://localhost:{}/monitoring/health | openapi=http://localhost:{}/v3/api-docs.yaml",
                port, perfiles, configServer ? "habilitado (" + env.getProperty("CONFIG_SERVER_URL", "") + ")" : "deshabilitado", port, port);
    }
}
