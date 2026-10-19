package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Poliza;
import java.util.List;
import java.util.Optional;

/** PROD-APICANAL-POLIZAS. */
public interface PolizasPort {
    List<Poliza> porCliente(String clienteId);

    Optional<Poliza> detalle(String numeroPoliza);
}
