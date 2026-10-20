package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.PosicionCliente.PrestacionDetalle;
import com.mapfre.pgm.bff.domain.model.Prestacion;
import java.util.List;
import java.util.Optional;

/** PROD-APICANAL-SINIESTROS (prestaciones y siniestros) + detalle de expediente METS vía Gateway. */
public interface SiniestrosPort {
    List<Prestacion> porClientePrestaciones(String clienteId);

    Optional<PrestacionDetalle> detallePrestacion(String numero);
}
