package com.mapfre.pgm.bff.application.port.in;

public interface AuditoriaUseCase {
    void registrarAcceso(String usuario, String accion, String clienteId, String pantalla);
}
