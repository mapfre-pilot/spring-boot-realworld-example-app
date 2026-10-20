package com.mapfre.pgm.bff.domain.model;

import java.util.List;
import java.util.Map;

/** Detalle de vencimiento (PGM_DetalleVencimiento): datos generales, datos de producto/riesgo por ramo, observaciones y anexos. */
public record OportunidadDetalle(
        Oportunidad oportunidad,
        Map<String, String> datosGenerales,
        Map<String, String> datosProducto,
        Map<String, String> datosRiesgo,
        List<Observacion> observaciones,
        List<DocumentoAdjunto> documentos) {
}
