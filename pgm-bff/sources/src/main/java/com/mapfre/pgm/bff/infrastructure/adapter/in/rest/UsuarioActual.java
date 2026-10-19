package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import java.util.List;

/** Identidad resuelta por la capa de entrada (JWT de Entra ID o cabeceras en perfil local). */
public record UsuarioActual(String id, String nombre, List<String> perfiles) {
}
