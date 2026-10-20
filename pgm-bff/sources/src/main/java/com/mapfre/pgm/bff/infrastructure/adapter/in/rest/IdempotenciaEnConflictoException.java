package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

public class IdempotenciaEnConflictoException extends RuntimeException {
    public IdempotenciaEnConflictoException() {
        super("La clave Idempotency-Key ya se utilizó con un cuerpo distinto");
    }
}
