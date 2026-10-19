package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.Kpi;
import java.util.List;

public interface CuadroMandoUseCase {
    List<Kpi> kpis(String periodo, String usuario);
}
