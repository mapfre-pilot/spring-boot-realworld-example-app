package com.mapfre.pgm.bff.domain.exception;

public class RecursoNoEncontradoException extends RuntimeException {
    public RecursoNoEncontradoException(String recurso, String id) {
        super(recurso + " " + id + " no encontrado");
    }
}
