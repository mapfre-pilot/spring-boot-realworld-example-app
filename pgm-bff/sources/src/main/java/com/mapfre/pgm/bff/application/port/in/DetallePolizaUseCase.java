package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;

public interface DetallePolizaUseCase {
    Poliza detalle(String numeroPoliza);

    List<Recibo> recibosDePoliza(String numeroPoliza);
}
