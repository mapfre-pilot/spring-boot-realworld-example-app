package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import java.util.List;
import java.util.Map;

/** DTOs del contrato /api/v1 que no coinciden 1:1 con el dominio. */
public final class ApiDtos {
    private ApiDtos() {}

    public record ContextoUsuarioDto(String usuario, String nombre, List<String> perfiles, String perfilSgc30,
                                     EstructuraComercial estructura, Map<String, Boolean> visibilidades) {
        public static ContextoUsuarioDto de(ContextoUsuario c) {
            return new ContextoUsuarioDto(c.usuario(), c.nombre(), c.perfiles(), c.perfilSgc30(), c.estructura(), c.visibilidades());
        }
    }

    public record TarificacionSaludRequest(
            String clienteId,
            @NotBlank String producto,
            @NotBlank @Pattern(regexp = "\\d{5}", message = "código postal de 5 dígitos") String codigoPostal,
            @NotEmpty List<Integer> edades,
            boolean copago) {
    }

    public record BorradorCreadoDto(String id) {
    }

    public record AuditoriaRequest(@NotBlank String accion, String clienteId, @NotBlank String pantalla) {
    }

    public record LlamadaRequest(@NotBlank String clienteId, @NotBlank String telefono) {
    }

    public record ObservacionRequest(@NotBlank String texto) {
    }
    public record CierreGestionRequest(@NotBlank @Pattern(regexp = "POSITIVA|NEGATIVA") String resultado) {
    }
    public record BorradorResumenDto(String id, String producto, String codigoPostal, int asegurados) {
    }
    public record LlamadaDto(String idLlamada) {
    }

    public record ListaDto<T>(List<T> items, int total) {
        public static <T> ListaDto<T> de(List<T> items) {
            return new ListaDto<>(items, items.size());
        }
    }
}
