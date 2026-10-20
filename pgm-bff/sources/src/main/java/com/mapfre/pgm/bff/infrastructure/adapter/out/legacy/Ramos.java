package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.domain.model.Ramo;

/** Traducción de códigos/descripciones de ramo legacy (MAPFRE: 1xx Autos, 2xx Hogar/Patrimoniales, 3xx Vida…) al enum del BFF. */
final class Ramos {
    private Ramos() {}

    static Ramo de(String codigo, String descripcion) {
        String d = ((descripcion == null ? "" : descripcion) + " " + (codigo == null ? "" : codigo)).toUpperCase();
        if (d.contains("AUTO") || d.contains("MOTO") || d.contains("CAMION") || d.contains("FLOTA")) return Ramo.AUTOS;
        if (d.contains("HOGAR") || d.contains("COMUNIDAD") || d.contains("PATRIMONI") || d.contains("HOME")) return Ramo.HOGAR;
        if (d.contains("SALUD") || d.contains("HEALTH") || d.contains("DENTAL")) return Ramo.SALUD;
        if (d.contains("DECESO")) return Ramo.DECESOS;
        if (d.contains("AHORRO") || d.contains("RENTA") || d.contains("UNIT") || d.contains("PLAN")) return Ramo.AHORRO;
        if (d.contains("VIDA") || d.contains("LIFE")) return Ramo.VIDA;
        if (d.contains("EMPRESA") || d.contains("COMERCIO") || d.contains("RC") || d.contains("PYME")) return Ramo.EMPRESAS;
        if (codigo != null && codigo.matches("\\d{3}")) {
            return switch (codigo.charAt(0)) {
                case '1' -> Ramo.AUTOS;
                case '2' -> Ramo.HOGAR;
                case '3' -> Ramo.VIDA;
                case '4' -> Ramo.SALUD;
                default -> Ramo.OTROS;
            };
        }
        return Ramo.OTROS;
    }
}
