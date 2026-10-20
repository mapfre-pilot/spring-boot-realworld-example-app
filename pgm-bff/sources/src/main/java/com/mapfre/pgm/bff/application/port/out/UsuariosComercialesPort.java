package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import java.util.Optional;

/** Consulta la estructura y el perfil comercial del usuario autenticado. */
public interface UsuariosComercialesPort {
    Optional<EstructuraComercial> estructuraDe(String usuario);

    Optional<String> perfilSgc30De(String usuario);
}
