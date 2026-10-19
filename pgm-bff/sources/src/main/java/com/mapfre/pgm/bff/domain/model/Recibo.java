package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public record Recibo(
        String numero,
        String clienteId,
        String polizaNumero,
        Ramo ramo,
        EstadoRecibo estado,
        BigDecimal importe,
        LocalDate fechaEmision,
        LocalDate fechaVencimiento,
        String formaPago,
        String ibanEnmascarado) {

    public enum EstadoRecibo { COBRADO, PENDIENTE, DEVUELTO, ANULADO }
}
