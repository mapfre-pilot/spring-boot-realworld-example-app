package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;

public record SolicitudSgo(String id, String clienteId, String tipo, String estado, LocalDate fecha, String descripcion) {
}
