package com.mapfre.pgm.bff.domain.model;

/** Indicadores de la cabecera de la ficha PGM (DNI, RGPD, ACI, Cliente Total, Plan de pagos, En familia, DpV). */
public record Palancas(
        boolean dniDigitalizado,
        boolean rgpdFirmado,
        boolean altaAci,
        boolean clienteTotal,
        boolean planPagos,
        boolean enFamilia,
        boolean dpv) {
}
