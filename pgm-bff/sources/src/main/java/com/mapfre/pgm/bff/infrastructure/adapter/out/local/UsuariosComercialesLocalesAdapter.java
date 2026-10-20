package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import java.util.Map;
import java.util.Optional;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Catálogo sintético de usuarios reutilizado por los perfiles local y simulador. */
@Component
@Profile({"simulador", "pruebas"})
@Primary
public class UsuariosComercialesLocalesAdapter implements UsuariosComercialesPort {

    private record UsuarioLocal(String perfilSgc30, EstructuraComercial estructura) {}

    private final Map<String, UsuarioLocal> usuarios;

    public UsuariosComercialesLocalesAdapter(ObjectMapper mapper) {
        usuarios = LocalDataLoader.load(mapper, "usuarios.json", new TypeReference<>() {});
    }

    @Override
    public Optional<EstructuraComercial> estructuraDe(String usuario) {
        return Optional.ofNullable(usuarios.get(usuario)).map(UsuarioLocal::estructura);
    }

    @Override
    public Optional<String> perfilSgc30De(String usuario) {
        return Optional.ofNullable(usuarios.get(usuario)).map(UsuarioLocal::perfilSgc30);
    }
}
