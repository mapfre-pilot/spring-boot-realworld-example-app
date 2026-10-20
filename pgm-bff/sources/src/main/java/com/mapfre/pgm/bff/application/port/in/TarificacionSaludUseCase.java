package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import com.mapfre.pgm.bff.application.port.out.BorradoresPort;
import java.util.List;
import java.util.Optional;

public interface TarificacionSaludUseCase {
    TarificacionSalud.Resultado tarificar(TarificacionSalud.Solicitud solicitud, String usuario);

    String guardarBorrador(TarificacionSalud.Solicitud solicitud, String usuario);

    Optional<TarificacionSalud.Solicitud> borrador(String id, String usuario);
    List<BorradoresPort.Borrador> borradores(String usuario);
    boolean eliminarBorrador(String id, String usuario);
}
