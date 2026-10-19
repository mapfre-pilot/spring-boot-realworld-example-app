package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Kpi;
import java.util.List;

/** Métricas de negocio (sustituyen al cuadro de mando sobre PostgreSQL de Appian). */
public interface CuadroMandoPort {
    List<Kpi> kpis(String periodo);
}
