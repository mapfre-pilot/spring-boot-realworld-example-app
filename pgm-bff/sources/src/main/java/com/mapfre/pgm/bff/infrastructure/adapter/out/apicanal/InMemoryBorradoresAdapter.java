package com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal;

import com.mapfre.pgm.bff.application.port.out.BorradoresPort;
import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Borradores en memoria del proceso. Redis/Mongo Atlas queda como Open Question del WRK-SPEC (almacén ligero opcional). */
@Component
@Profile("!local")
public class InMemoryBorradoresAdapter implements BorradoresPort {

    private final Map<String, TarificacionSalud.Solicitud> borradores = new ConcurrentHashMap<>();

    @Override
    public String guardar(String usuario, TarificacionSalud.Solicitud solicitud) {
        String id = UUID.randomUUID().toString();
        borradores.put(usuario + "/" + id, solicitud);
        return id;
    }

    @Override
    public Optional<TarificacionSalud.Solicitud> recuperar(String usuario, String id) {
        return Optional.ofNullable(borradores.get(usuario + "/" + id));
    }

    @Override
    public List<Borrador> listar(String usuario) {
        String prefijo = usuario + "/";
        return borradores.entrySet().stream()
                .filter(e -> e.getKey().startsWith(prefijo))
                .map(e -> new Borrador(e.getKey().substring(prefijo.length()), e.getValue()))
                .toList();
    }

    @Override
    public boolean eliminar(String usuario, String id) {
        return borradores.remove(usuario + "/" + id) != null;
    }
}
