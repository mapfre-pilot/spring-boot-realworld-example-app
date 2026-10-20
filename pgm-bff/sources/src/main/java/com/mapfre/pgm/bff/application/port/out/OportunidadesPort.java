package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.AltaOportunidad;
import com.mapfre.pgm.bff.domain.model.Observacion;
import com.mapfre.pgm.bff.domain.model.Oportunidad;
import com.mapfre.pgm.bff.domain.model.OportunidadDetalle;
import com.mapfre.pgm.bff.domain.model.ResumenOportunidades;

import java.util.List;
import java.util.Optional;

/** PGO /apipgo (legacy de PGM publicado en el API Gateway). */
public interface OportunidadesPort {
    List<Oportunidad> porClienteOportunidades(String clienteId);
    ResumenOportunidades resumen(String clienteId);
    Optional<OportunidadDetalle> detalle(String oportunidadId);
    Oportunidad crear(AltaOportunidad alta, String nuuma);
    Observacion anadirObservacion(String oportunidadId, String texto, String nuuma);
    void eliminarObservacion(String oportunidadId, String observacionId, String nuuma);
}
