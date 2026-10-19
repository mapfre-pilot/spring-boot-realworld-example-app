package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Lanzadera;
import java.util.List;

/** Catálogo de lanzaderas (configuración, antes APICatalogo_URLIntegracion). */
public interface LanzaderasPort {
    List<Lanzadera> todas();
}
