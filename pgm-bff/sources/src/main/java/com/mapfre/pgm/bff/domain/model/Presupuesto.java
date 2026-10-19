package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public record Presupuesto(
        String numero,
        String clienteId,
        Ramo ramo,
        String producto,
        String estado,
        LocalDate fecha,
        LocalDate fechaCaducidad,
        BigDecimal primaAnual) {
}
