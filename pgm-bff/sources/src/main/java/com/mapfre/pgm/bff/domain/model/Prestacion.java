package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;

public record Prestacion(
        String numero,
        String clienteId,
        String polizaNumero,
        Ramo ramo,
        String tipo,
        EstadoPrestacion estado,
        LocalDate fechaOcurrencia,
        LocalDate fechaApertura,
        String descripcion,
        String tramitador) {

    public enum EstadoPrestacion { ABIERTA, EN_TRAMITE, CERRADA }
}
