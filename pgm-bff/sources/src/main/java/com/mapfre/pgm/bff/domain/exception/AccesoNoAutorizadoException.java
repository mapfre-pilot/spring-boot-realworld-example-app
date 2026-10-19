package com.mapfre.pgm.bff.domain.exception;

public class AccesoNoAutorizadoException extends RuntimeException {
    public AccesoNoAutorizadoException(String motivo) {
        super(motivo);
    }
}
