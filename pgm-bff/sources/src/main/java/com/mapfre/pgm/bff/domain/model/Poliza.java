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

    public static TipoDetalle clasificarTipoDetalle(Ramo ramo, String numero) {
        if (ramo == Ramo.SALUD) return TipoDetalle.SALUD;
        if (ramo == Ramo.HOGAR) return TipoDetalle.HOGAR;
        if (ramo == Ramo.AUTOS) return TipoDetalle.AUTOS;
        if ((ramo == Ramo.VIDA || ramo == Ramo.AHORRO || ramo == Ramo.RIESGO)
                && numero != null && numero.length() <= 11) return TipoDetalle.VIDA;
        return TipoDetalle.GENERICA;
    }

    public enum EstadoPoliza { EN_VIGOR, ANULADA, SUSPENDIDA }
    public enum TipoDetalle { AUTOS, SALUD, VIDA, HOGAR, GENERICA }
}
