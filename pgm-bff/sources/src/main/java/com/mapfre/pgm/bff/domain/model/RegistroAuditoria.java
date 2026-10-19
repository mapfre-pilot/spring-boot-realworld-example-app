package com.mapfre.pgm.bff.domain.model;

import java.time.Instant;

/** Auditoría de accesos por NUUMA (sustituye al registro de consultas de iMediador/BDEC). Nunca contiene PII. */
public record RegistroAuditoria(String usuario, String nuuma, String accion, String clienteId, String pantalla, Instant timestamp) {
}
