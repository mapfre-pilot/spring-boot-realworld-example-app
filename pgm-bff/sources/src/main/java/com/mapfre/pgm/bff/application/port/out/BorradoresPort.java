package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.TarificacionSalud;

import java.util.List;
import java.util.Optional;

/** Almacén ligero de borradores de tarificación (en memoria en local; Redis/Mongo Atlas opcional en entornos). */
public interface BorradoresPort {
    record Borrador(String id, TarificacionSalud.Solicitud solicitud) {}
    String guardar(String usuario, TarificacionSalud.Solicitud solicitud);
    Optional<TarificacionSalud.Solicitud> recuperar(String usuario, String id);
    List<Borrador> listar(String usuario);
    boolean eliminar(String usuario, String id);
}
