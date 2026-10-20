package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/** Diario de actividad comercial iMediador (SGC 2.0): Fecha y hora, Gestión alcanzada, Usuario, Acción, Tipo de acción, Comentarios, Producto, Prima. */
public record ActividadComercial(
        String id,
        String clienteId,
        LocalDateTime fecha,
        String gestionAlcanzada,
        String usuario,
        String accion,
        String tipoAccion,
        String comentarios,
        String producto,
        BigDecimal prima) {
}
