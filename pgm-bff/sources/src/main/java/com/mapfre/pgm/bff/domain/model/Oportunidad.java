package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * Vencimientos y oportunidades comerciales (PGO /apipgo). Columnas de la tabla «Vencimientos» de PGM:
 * Producto/Riesgo, Venc./Oport., Anexos, Usuario, Entidad competencia, F. Venci./Opor., Prima/Saldo,
 * Comentarios y Clase de Vcto. (Completo / Incompleto / PRECOTIZADO).
 */
public record Oportunidad(
        String id,
        String clienteId,
        Tipo tipo,
        Ramo ramo,
        String polizaNumero,
        LocalDate fecha,
        String descripcion,
        Prioridad prioridad,
        Clase clase,
        String usuario,
        String entidadCompetencia,
        BigDecimal prima,
        String comentarios,
        int anexos,
        boolean contratado) {
    public enum Tipo { VENCIMIENTO, OPORTUNIDAD, CROSSELLING }
    public enum Prioridad { ALTA, MEDIA, BAJA }
    public enum Clase { COMPLETO, INCOMPLETO, PRECOTIZADO }
}
