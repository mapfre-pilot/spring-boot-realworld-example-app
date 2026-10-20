package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.GestionComercial;
import java.util.List;

/** SGC 3.0 + iMediador (APIs de plataforma por API Gateway). */
public interface GestionComercialPort {
    List<GestionComercial> gestionesPorCliente(String clienteId);
}
