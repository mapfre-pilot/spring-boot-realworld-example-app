package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Poliza;
import java.util.List;
import java.util.Optional;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;

/** PROD-APICANAL-POLIZAS. */
public interface PolizasPort {
    List<Poliza> porCliente(String clienteId);

    Optional<Poliza> detalle(String numeroPoliza);

    List<AccionPoliza> accionesPoliza(String numeroPoliza);
    List<DocumentoPoliza> documentosPoliza(String numeroPoliza);
    Optional<DetallePolizaRamo> detalleRamo(String numeroPoliza);
    List<EstadoAnterior> estadosAnteriores(String clienteId);
}
