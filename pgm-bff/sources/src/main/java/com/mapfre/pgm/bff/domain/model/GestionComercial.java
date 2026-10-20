package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Gestión SGC 3.0 (business task). Columnas de PGM: F. caducidad, Acci. Comercial (+ WhatsApp), Comentarios,
 * Prob. (probabilidad de conversión), Estado (ABIERTA / CERRADA / CADUCADA), Agendado, Usuario (NUUMA).
 * Solo se listan las filas cuyos permisos contienen VIEW.
 */
public record GestionComercial(
        String id,
        String clienteId,
        String tipo,
        String estado,
        LocalDateTime fecha,
        String descripcion,
        String gestor,
        String origen,
        LocalDate fechaCaducidad,
        Integer probabilidadConversion,
        boolean agendado,
        boolean whatsapp,
        List<String> permisos) {
    public boolean visible() {
        return permisos == null || permisos.isEmpty() || permisos.contains("VIEW");
    }
}
