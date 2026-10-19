package com.mapfre.pgm.bff.domain.model;

import java.util.List;
import java.util.Map;

/**
 * Contexto de autorización del usuario: grupo/perfil (Entra ID) × estructura comercial × feature flags.
 * Las visibilidades las calcula el BFF; la SPA solo las pinta.
 */
public record ContextoUsuario(
        String usuario,
        String nombre,
        List<String> perfiles,
        String perfilSgc30,
        EstructuraComercial estructura,
        Map<String, Boolean> visibilidades) {

    public boolean tienePerfil(String perfil) {
        return perfiles != null && perfiles.contains(perfil);
    }
}
