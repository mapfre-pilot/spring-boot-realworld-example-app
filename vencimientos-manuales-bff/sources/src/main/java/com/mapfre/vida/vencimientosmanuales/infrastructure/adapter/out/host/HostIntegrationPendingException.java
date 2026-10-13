package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

public class HostIntegrationPendingException extends RuntimeException {
    public HostIntegrationPendingException() {
        super("Integración CTG pendiente");
    }
}
