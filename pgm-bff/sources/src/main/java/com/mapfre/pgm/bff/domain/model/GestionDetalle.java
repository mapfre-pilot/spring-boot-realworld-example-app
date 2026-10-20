package com.mapfre.pgm.bff.domain.model;

import java.util.List;

/** Detalle de gestión SGC 3.0 (PGM_DetalleGestion30): potencialidad, asignación, contacto, observaciones y gestiones alcanzadas. */
public record GestionDetalle(
        GestionComercial gestion,
        String potencialidad,
        String asignadaA,
        List<String> telefonos,
        String email,
        List<Observacion> observaciones,
        List<DocumentoAdjunto> documentos,
        List<ActividadComercial> gestionesAlcanzadas) {
}
