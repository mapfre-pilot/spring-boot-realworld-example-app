package com.mapfre.pgm.bff.application.port.in;

import java.util.List;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.domain.model.Recibo;

public interface DetalleReciboUseCase {
    Recibo detalleRecibo(String numeroRecibo);

    List<AccionRecibo> accionesRecibo(String numeroRecibo, String usuario, List<String> perfiles);
    ReciboDetalle detalleCompleto(String numeroRecibo, String usuario, List<String> perfiles);
    DuplicadoRecibo duplicado(String numeroRecibo, String usuario);
    PrestacionDetalle detallePrestacion(String numero, String usuario, List<String> perfiles);
}
