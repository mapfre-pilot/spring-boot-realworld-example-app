package com.mapfre.pgm.bff.domain.model;

/** Nueva actividad / gestión alcanzada (iMediador insertarActividad). */
public record AltaActividad(String clienteId, String nivelGestion, String comentario, String polizaNumero, boolean sinRgpd) {
}
