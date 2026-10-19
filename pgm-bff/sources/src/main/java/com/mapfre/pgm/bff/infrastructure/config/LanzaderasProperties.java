package com.mapfre.pgm.bff.infrastructure.config;

import com.mapfre.pgm.bff.domain.model.Lanzadera;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "pgm")
public record LanzaderasProperties(List<Lanzadera> lanzaderas) {
}
