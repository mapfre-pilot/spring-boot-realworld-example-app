package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDateTime;

/** Documento anexo (PGO attachment, documento SGC 3.0 o documento SGO). */
public record DocumentoAdjunto(String id, String nombre, String tipo, LocalDateTime fecha, String usuario) {
}
