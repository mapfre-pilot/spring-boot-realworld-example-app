package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.RegistroAuditoria;

public interface AuditoriaPort {
    void registrar(RegistroAuditoria registro);
}
