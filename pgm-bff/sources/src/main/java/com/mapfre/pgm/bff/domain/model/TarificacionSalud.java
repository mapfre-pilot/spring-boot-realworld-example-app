package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.util.List;

public final class TarificacionSalud {
    private TarificacionSalud() {}

    public record Solicitud(String clienteId, String producto, String codigoPostal, List<Integer> edades, boolean copago) {
    }

    public record Resultado(String id, String producto, BigDecimal primaMensual, BigDecimal primaAnual,
                            List<String> coberturas, String estado) {
    }
}
