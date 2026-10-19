package com.mapfre.pgm.bff.application.service;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** Pilotos / feature flags (tercer eje del modelo de autorización). */
@ConfigurationProperties(prefix = "pgm.features")
public record FeatureFlags(boolean tarificacionSalud, boolean gestionComercial, boolean cuadroMando, boolean clickToCall) {
}
