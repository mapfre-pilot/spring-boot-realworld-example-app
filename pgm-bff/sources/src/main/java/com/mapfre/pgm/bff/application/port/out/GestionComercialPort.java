package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import com.mapfre.pgm.bff.domain.model.GestionComercial;
import java.util.List;
import java.util.Optional;

/** SGC 3.0 + iMediador (APIs de plataforma por API Gateway). */
public interface GestionComercialPort {
    List<GestionComercial> gestionesPorCliente(String clienteId);

    Optional<EstructuraComercial> estructuraDe(String usuario);

    Optional<String> perfilSgc30De(String usuario);
}
