package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import java.util.Optional;

public interface TarificacionSaludUseCase {
    TarificacionSalud.Resultado tarificar(TarificacionSalud.Solicitud solicitud, String usuario);

    String guardarBorrador(TarificacionSalud.Solicitud solicitud, String usuario);

    Optional<TarificacionSalud.Solicitud> borrador(String id, String usuario);
}
