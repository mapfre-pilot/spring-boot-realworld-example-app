package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record Poliza(
        String numero,
        String clienteId,
        Ramo ramo,
        String producto,
        EstadoPoliza estado,
        LocalDate fechaEfecto,
        LocalDate fechaVencimiento,
        BigDecimal primaAnual,
        String formaPago,
        String riesgo,
        List<String> acciones,
        String lanzadera) {

    public enum EstadoPoliza { EN_VIGOR, ANULADA, SUSPENDIDA }
}
