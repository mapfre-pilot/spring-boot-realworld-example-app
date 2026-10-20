package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.DocumentoAdjunto;
import com.mapfre.pgm.bff.domain.model.SolicitudSgo;
import com.mapfre.pgm.bff.domain.model.SolicitudSgoDetalle;

import java.util.List;
import java.util.Optional;

/** SGO — solicitudes y documentos (fachada REST del Gateway sobre ConsultarSolicitudes / ConsultarDocumentos). */
public interface SgoPort {
    List<SolicitudSgo> solicitudesPorCliente(String clienteId);
    Optional<SolicitudSgoDetalle> detalleSolicitud(String solicitudId);
    List<DocumentoAdjunto> documentosSolicitud(String solicitudId);
}
