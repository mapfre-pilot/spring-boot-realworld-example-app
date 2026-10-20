package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

/** Alta de vencimiento/oportunidad incompleta (POST /apipgo/opportunity/incomplete) desde «Añadir Vencimiento / Presupuesto». */
public record AltaOportunidad(
        String clienteId,
        Ramo ramo,
        Oportunidad.Tipo tipo,
        LocalDate fecha,
        String entidadCompetencia,
        BigDecimal prima,
        String comentarios,
        Map<String, String> datosProducto,
        Map<String, String> datosRiesgo) {
}
