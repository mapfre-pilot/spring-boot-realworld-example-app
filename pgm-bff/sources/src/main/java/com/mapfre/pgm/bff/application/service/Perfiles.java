package com.mapfre.pgm.bff.application.service;

/** Grupos Entra ID equivalentes a los grupos Appian de PGM. */
public final class Perfiles {
    private Perfiles() {}

    public static final String USUARIO = "PGM_USUARIO";
    public static final String ASESOR_COMERCIAL = "PGM_ASESOR_COMERCIAL";
    public static final String VISUALIZAR_CDM = "PGM_VISUALIZAR_CDM";
    public static final String ADMINISTRADOR = "PGM_ADMINISTRADOR";
    /** Grupos Appian que habilitan la ficha de póliza Autos/Hogar (área B: `PGM_USUARIOSGRUPOTRABAJO`, `PGM_GR_DETALLEHOGAR`). */
    public static final String GRUPO_TRABAJO = "PGM_USUARIOSGRUPOTRABAJO";
    public static final String DETALLE_HOGAR = "PGM_GR_DETALLEHOGAR";
}
