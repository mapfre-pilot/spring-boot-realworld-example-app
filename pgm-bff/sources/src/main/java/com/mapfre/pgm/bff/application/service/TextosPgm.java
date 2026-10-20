package com.mapfre.pgm.bff.application.service;

/** Textos literales de PGM (Appian TEST, observados en la ronda de pruebas 2026-10-20) que la SPA muestra tal cual. */
public final class TextosPgm {
    private TextosPgm() {}

    public static final String ACCION_NO_DISPONIBLE =
            "Esta acción aún no está disponible en PGM para tu usuario (%s)";
    public static final String CONTACTA_ADMINISTRADOR =
            "Contacta con el administrador de la aplicación si consideras que debes acceder";
    public static final String PUEDES_SGC20 = "Puedes realizarla desde SGC 2.0";
    public static final String FIRMA_CLAUSULA_MEDIADORES =
            "Para tener acceso al Alta de Vencimientos es necesario tener firmada la Cláusula Informativa Mediadores";
    public static final String SIN_PERMISO_GESTIONES = "No tienes permiso para ver las gestiones";
    public static final String NGA_NO_DISPONIBLE =
            "El alta de NGA aún no está disponible en PGM para tu usuario (%s). Solo se pueden añadir comentarios.";
    public static final String SIN_NUUMA = "sin Nuuma";

    public static String accionNoDisponible(String nuuma) {
        return ACCION_NO_DISPONIBLE.formatted(nuuma == null || nuuma.isBlank() ? SIN_NUUMA : nuuma);
    }
}
