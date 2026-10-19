package com.mapfre.pgm.bff.infrastructure.config;

import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "pgm.local")
public record LocalProperties(String usuarioPorDefecto, List<String> perfilesPorDefecto) {
}
