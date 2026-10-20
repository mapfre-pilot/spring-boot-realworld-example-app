package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDateTime;

/** Observación de un vencimiento PGO o de una gestión SGC 3.0 (histórico: fecha, fecha de actualización, texto, usuario). */
public record Observacion(String id, LocalDateTime fecha, LocalDateTime fechaActualizacion, String texto, String usuario) {
}
