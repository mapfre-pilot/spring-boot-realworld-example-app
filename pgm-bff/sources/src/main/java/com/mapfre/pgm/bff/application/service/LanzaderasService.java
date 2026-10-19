package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.LanzaderasUseCase;
import com.mapfre.pgm.bff.application.port.out.GestionComercialPort;
import com.mapfre.pgm.bff.application.port.out.LanzaderasPort;
import com.mapfre.pgm.bff.domain.model.Lanzadera;
import com.mapfre.pgm.bff.domain.model.Ramo;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class LanzaderasService implements LanzaderasUseCase {

    private final LanzaderasPort lanzaderasPort;
    private final GestionComercialPort gestionComercialPort;

    public LanzaderasService(LanzaderasPort lanzaderasPort, GestionComercialPort gestionComercialPort) {
        this.lanzaderasPort = lanzaderasPort;
        this.gestionComercialPort = gestionComercialPort;
    }

    @Override
    public List<Lanzadera> disponibles(Ramo ramo, String usuario) {
        boolean tieneNuuma = gestionComercialPort.estructuraDe(usuario)
                .map(e -> e.nuuma() != null && !e.nuuma().isBlank()).orElse(false);
        return lanzaderasPort.todas().stream()
                .filter(l -> ramo == null || l.ramo() == null || l.ramo() == ramo)
                .filter(l -> !l.requiereNuuma() || tieneNuuma)
                .toList();
    }
}
