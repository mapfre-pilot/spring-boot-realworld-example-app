package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.*;
import java.util.List;
import java.util.Optional;

/** Casos de uso por pestaña de la ficha de cliente. */
public interface FichaClienteUseCase {
    Cliente ficha(String clienteId, String usuario);

    List<Poliza> productos(String clienteId);

    List<Recibo> recibos(String clienteId);

    List<Prestacion> prestaciones(String clienteId);

    List<Presupuesto> presupuestos(String clienteId);

    List<Oportunidad> oportunidades(String clienteId);

    List<GestionComercial> gestiones(String clienteId, String usuario);

    List<SolicitudSgo> solicitudesSgo(String clienteId);
    Optional<SolicitudSgoDetalle> solicitudSgo(String solicitudId);
    List<DocumentoAdjunto> documentosSgo(String solicitudId);
}
