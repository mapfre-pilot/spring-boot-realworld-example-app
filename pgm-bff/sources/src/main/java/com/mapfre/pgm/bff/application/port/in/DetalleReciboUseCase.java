package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.Recibo;

public interface DetalleReciboUseCase {
    Recibo detalleRecibo(String numeroRecibo);
}
