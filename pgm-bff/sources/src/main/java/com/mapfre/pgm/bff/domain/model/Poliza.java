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
        String lanzadera,
        TipoDetalle tipoDetalle,
        String companyId) {

    public Poliza(String numero, String clienteId, Ramo ramo, String producto, EstadoPoliza estado,
                  LocalDate fechaEfecto, LocalDate fechaVencimiento, BigDecimal primaAnual, String formaPago, String riesgo,
                  List<String> acciones, String lanzadera, TipoDetalle tipoDetalle) {
        this(numero, clienteId, ramo, producto, estado, fechaEfecto, fechaVencimiento, primaAnual, formaPago, riesgo,
                acciones, lanzadera, tipoDetalle, null);
    }

    public enum EstadoPoliza { EN_VIGOR, ANULADA, SUSPENDIDA }
    public enum TipoDetalle { AUTOS, SALUD, VIDA, HOGAR, CONSUMO_PROTEGIDO, HIPOTECA_SEGURA, GENERICA }
}
