package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.Lanzadera;
import com.mapfre.pgm.bff.domain.model.Ramo;
import java.util.List;

public interface LanzaderasUseCase {
    List<Lanzadera> disponibles(Ramo ramo, String usuario);
}
