package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;
import java.util.Optional;

/** PROD-APICANAL-RECIBOS. */
public interface RecibosPort {
    List<Recibo> porClienteRecibos(String clienteId);

    Optional<Recibo> detalleRecibo(String numeroRecibo);
}
