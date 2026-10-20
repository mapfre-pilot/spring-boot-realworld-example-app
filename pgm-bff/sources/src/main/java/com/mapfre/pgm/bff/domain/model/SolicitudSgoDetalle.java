package com.mapfre.pgm.bff.domain.model;

import java.util.List;
import java.util.Map;

/** Detalle de solicitud SGO (ConsultarSolicitudes/ConsultarDocumentos vía fachada REST del Gateway). */
public record SolicitudSgoDetalle(SolicitudSgo solicitud, Map<String, String> datos, List<DocumentoAdjunto> documentos) {
}
