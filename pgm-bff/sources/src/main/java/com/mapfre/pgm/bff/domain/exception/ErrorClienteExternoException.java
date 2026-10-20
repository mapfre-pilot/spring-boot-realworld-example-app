package com.mapfre.pgm.bff.domain.exception;

/** Respuesta 4xx del API remoto: no es un fallo transitorio reintentable. */
public class ErrorClienteExternoException extends SistemaExternoException {
    public ErrorClienteExternoException(String sistema, String mensaje, Throwable causa) {
        super(sistema, mensaje, causa);
    }
}
