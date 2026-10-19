package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;

public record Alerta(String tipo, String texto, LocalDate fecha) {
}
