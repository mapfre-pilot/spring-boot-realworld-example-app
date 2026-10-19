package com.mapfre.pgm.bff.application.port.out;

/** Centro de comunicaciones: click-to-call, WhatsApp Oficinas (API de plataforma por API Gateway). */
public interface ComunicacionesPort {
    String iniciarLlamada(String clienteId, String telefono, String usuario);
}
