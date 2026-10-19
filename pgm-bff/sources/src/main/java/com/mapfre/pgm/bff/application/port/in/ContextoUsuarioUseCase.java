package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import java.util.List;

public interface ContextoUsuarioUseCase {
    ContextoUsuario contexto(String usuario, String nombre, List<String> perfiles);
}
