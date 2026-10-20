package com.mapfre.pgm.bff.domain.model;

/** Contadores «Todos · Completo · Incompleto» del sumario PGO (/apipgo/client/opportunities/summary). */
public record ResumenOportunidades(int todos, int completos, int incompletos, int presupuestos) {
}
