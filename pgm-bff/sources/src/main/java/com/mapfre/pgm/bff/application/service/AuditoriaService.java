package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.out.AuditoriaPort;
import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.domain.model.RegistroAuditoria;
import java.time.Instant;
import org.springframework.stereotype.Service;

@Service
public class AuditoriaService implements AuditoriaUseCase {

    private final AuditoriaPort auditoriaPort;
    private final UsuariosComercialesPort usuariosComercialesPort;

    public AuditoriaService(AuditoriaPort auditoriaPort, UsuariosComercialesPort usuariosComercialesPort) {
        this.auditoriaPort = auditoriaPort;
        this.usuariosComercialesPort = usuariosComercialesPort;
    }

    @Override
    public void registrarAcceso(String usuario, String accion, String clienteId, String pantalla) {
        String nuuma = usuariosComercialesPort.estructuraDe(usuario).map(e -> e.nuuma()).orElse("SIN_NUUMA");
        auditoriaPort.registrar(new RegistroAuditoria(usuario, nuuma, accion, clienteId, pantalla, Instant.now()));
    }
}
