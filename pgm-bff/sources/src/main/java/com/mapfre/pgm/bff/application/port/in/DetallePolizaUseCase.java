package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;

public interface DetallePolizaUseCase {
    Poliza detalle(String numeroPoliza);

    List<Recibo> recibosDePoliza(String numeroPoliza);

    /** Ficha de póliza: Autos/Hogar solo con grupo de trabajo / detalle hogar (área B). */
    Poliza detalle(String numeroPoliza, String usuario, List<String> perfiles);
    List<AccionPoliza> accionesPoliza(String numeroPoliza, String usuario, List<String> perfiles);
    List<DocumentoPoliza> documentosPoliza(String numeroPoliza);
    DetallePolizaRamo detalleRamo(String numeroPoliza, String usuario, List<String> perfiles);
    List<EstadoAnterior> estadosAnteriores(String clienteId);
}
