package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.TarificacionSaludUseCase;
import com.mapfre.pgm.bff.application.port.out.BorradoresPort;
import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class TarificacionSaludService implements TarificacionSaludUseCase {

    private final VentasPort ventasPort;
    private final BorradoresPort borradoresPort;

    public TarificacionSaludService(VentasPort ventasPort, BorradoresPort borradoresPort) {
        this.ventasPort = ventasPort;
        this.borradoresPort = borradoresPort;
    }

    @Override
    public TarificacionSalud.Resultado tarificar(TarificacionSalud.Solicitud solicitud, String usuario) {
        if (solicitud.edades() == null || solicitud.edades().isEmpty()) {
            throw new IllegalArgumentException("Indique al menos un asegurado");
        }
        if (solicitud.edades().stream().anyMatch(e -> e == null || e < 0 || e > 120)) {
            throw new IllegalArgumentException("Edad de asegurado fuera de rango (0-120)");
        }
        return ventasPort.tarificarSalud(solicitud);
    }

    @Override
    public String guardarBorrador(TarificacionSalud.Solicitud solicitud, String usuario) {
        return borradoresPort.guardar(usuario, solicitud);
    }

    @Override
    public Optional<TarificacionSalud.Solicitud> borrador(String id, String usuario) {
        return borradoresPort.recuperar(usuario, id);
    }

    @Override
    public List<BorradoresPort.Borrador> borradores(String usuario) {
        return borradoresPort.listar(usuario);
    }

    @Override
    public boolean eliminarBorrador(String id, String usuario) {
        return borradoresPort.eliminar(usuario, id);
    }
}
