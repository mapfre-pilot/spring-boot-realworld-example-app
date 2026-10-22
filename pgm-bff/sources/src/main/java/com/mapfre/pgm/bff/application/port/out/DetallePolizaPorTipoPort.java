package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.DetallePolizaRamo;
import java.util.Optional;

public interface DetallePolizaPorTipoPort {
    Optional<DetallePolizaRamo> detalleRamo(Poliza poliza);
}
