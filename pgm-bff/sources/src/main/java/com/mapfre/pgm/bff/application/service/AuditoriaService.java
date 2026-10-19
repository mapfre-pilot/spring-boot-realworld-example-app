package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.out.AuditoriaPort;
import com.mapfre.pgm.bff.application.port.out.GestionComercialPort;
import com.mapfre.pgm.bff.domain.model.RegistroAuditoria;
import java.time.Instant;
import org.springframework.stereotype.Service;

@Service
public class AuditoriaService implements AuditoriaUseCase {

    private final AuditoriaPort auditoriaPort;
    private final GestionComercialPort gestionComercialPort;

    public AuditoriaService(AuditoriaPort auditoriaPort, GestionComercialPort gestionComercialPort) {
        this.auditoriaPort = auditoriaPort;
        this.gestionComercialPort = gestionComercialPort;
    }

    @Override
    public void registrarAcceso(String usuario, String accion, String clienteId, String pantalla) {
        String nuuma = gestionComercialPort.estructuraDe(usuario).map(e -> e.nuuma()).orElse("SIN_NUUMA");
        auditoriaPort.registrar(new RegistroAuditoria(usuario, nuuma, accion, clienteId, pantalla, Instant.now()));
    }
}
