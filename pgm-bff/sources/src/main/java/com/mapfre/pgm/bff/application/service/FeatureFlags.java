package com.mapfre.pgm.bff.application.service;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** Pilotos / feature flags (tercer eje del modelo de autorización). */
@ConfigurationProperties(prefix = "pgm.features")
/** Constantes PGM_* de Appian que se mapean a flags: PGM_visualizacionRecibos, PGM_CONS_VER_DETALLE_PRESTACIONES. */
public record FeatureFlags(boolean tarificacionSalud, boolean gestionComercial, boolean cuadroMando, boolean clickToCall,
                           boolean visualizacionRecibos, boolean detallePrestaciones) {
}
