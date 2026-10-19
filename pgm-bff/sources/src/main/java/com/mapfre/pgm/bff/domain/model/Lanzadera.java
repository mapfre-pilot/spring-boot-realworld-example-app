package com.mapfre.pgm.bff.domain.model;

/** Enlace de navegación a otra aplicación (NSE, GESALUD, GESVIDA, Portal Interno, SGC, SGO, Citrix). No es una integración. */
public record Lanzadera(String codigo, String nombre, String destino, Ramo ramo, String url, boolean requiereNuuma) {
}
