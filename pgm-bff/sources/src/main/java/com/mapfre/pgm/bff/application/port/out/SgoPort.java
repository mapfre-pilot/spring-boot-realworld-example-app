package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.SolicitudSgo;
import java.util.List;

/** SGO — solicitudes y documentos (API de plataforma por API Gateway). */
public interface SgoPort {
    List<SolicitudSgo> solicitudesPorCliente(String clienteId);
}
