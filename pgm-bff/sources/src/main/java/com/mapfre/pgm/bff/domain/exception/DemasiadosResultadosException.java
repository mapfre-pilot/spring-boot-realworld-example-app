package com.mapfre.pgm.bff.domain.exception;

/** PGM_Exceso_Resultados_de_busqueda: más de 100 coincidencias. */
public class DemasiadosResultadosException extends RuntimeException {
    public DemasiadosResultadosException() {
        super("Hay demasiados resultados para los criterios introducidos. Por favor, realiza de nuevo la búsqueda con unos criterios más específicos");
    }
}
