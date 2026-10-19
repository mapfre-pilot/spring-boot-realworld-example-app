package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.mapfre.pgm.bff.application.port.out.LanzaderasPort;
import com.mapfre.pgm.bff.domain.model.Lanzadera;
import com.mapfre.pgm.bff.infrastructure.config.LanzaderasProperties;
import java.util.List;
import org.springframework.stereotype.Component;

/** Catálogo de lanzaderas desde configuración (sustituye a APICatalogo_URLIntegracion). Válido en todos los perfiles. */
@Component
public class ConfigLanzaderasAdapter implements LanzaderasPort {

    private final LanzaderasProperties props;

    public ConfigLanzaderasAdapter(LanzaderasProperties props) {
        this.props = props;
    }

    @Override
    public List<Lanzadera> todas() {
        return props.lanzaderas() == null ? List.of() : props.lanzaderas();
    }
}
