package com.mapfre.pgm.bff.domain.exception;

/** Fallo (timeout, 5xx, circuito abierto) de API Canal o de una API de plataforma. */
public class SistemaExternoException extends RuntimeException {
    private final String sistema;

    public SistemaExternoException(String sistema, String mensaje, Throwable causa) {
        super(mensaje, causa);
        this.sistema = sistema;
    }

    public String getSistema() {
        return sistema;
    }
}
