package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDateTime;

/** Gestión comercial SGC 3.0 / actividad comercial iMediador. */
public record GestionComercial(
        String id,
        String clienteId,
        String tipo,
        String estado,
        LocalDateTime fecha,
        String descripcion,
        String gestor,
        String origen) {
}
