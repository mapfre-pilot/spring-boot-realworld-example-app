package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;

/** Vencimientos y oportunidades comerciales (PGO). */
public record Oportunidad(
        String id,
        String clienteId,
        Tipo tipo,
        Ramo ramo,
        String polizaNumero,
        LocalDate fecha,
        String descripcion,
        Prioridad prioridad) {

    public enum Tipo { VENCIMIENTO, OPORTUNIDAD, CROSSELLING }
    public enum Prioridad { ALTA, MEDIA, BAJA }
}
