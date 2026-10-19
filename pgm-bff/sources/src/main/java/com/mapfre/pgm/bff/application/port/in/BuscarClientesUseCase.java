package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.application.port.out.ClientesPort.CriteriosBusqueda;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import java.util.List;

public interface BuscarClientesUseCase {
    List<ClienteResumen> buscar(CriteriosBusqueda criterios, String usuario);
}
