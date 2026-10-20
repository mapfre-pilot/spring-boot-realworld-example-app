package com.mapfre.pgm.bff.domain.model;

import java.util.List;

/** Catálogos iMediador: acciones comerciales (por estructura) y niveles de gestión (por origen). */
public record CatalogoComercial(Tipo tipo, List<Item> items) {
    public enum Tipo { ACCIONES, NIVELES_GESTION, COMPANIAS }
    public record Item(String codigo, String nombre) {}
}
