package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Prestacion;
import java.util.List;

/** PROD-APICANAL-SINIESTROS (prestaciones y siniestros). */
public interface SiniestrosPort {
    List<Prestacion> porClientePrestaciones(String clienteId);
}
