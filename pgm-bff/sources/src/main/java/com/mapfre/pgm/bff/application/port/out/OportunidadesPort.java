package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Oportunidad;
import java.util.List;

/** PGO (API de plataforma por API Gateway). */
public interface OportunidadesPort {
    List<Oportunidad> porClienteOportunidades(String clienteId);
}
