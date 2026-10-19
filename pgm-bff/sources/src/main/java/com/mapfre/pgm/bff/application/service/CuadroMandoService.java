package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.CuadroMandoUseCase;
import com.mapfre.pgm.bff.application.port.out.CuadroMandoPort;
import com.mapfre.pgm.bff.domain.model.Kpi;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class CuadroMandoService implements CuadroMandoUseCase {

    private final CuadroMandoPort cuadroMandoPort;

    public CuadroMandoService(CuadroMandoPort cuadroMandoPort) {
        this.cuadroMandoPort = cuadroMandoPort;
    }

    @Override
    public List<Kpi> kpis(String periodo, String usuario) {
        return cuadroMandoPort.kpis(periodo == null || periodo.isBlank() ? "mes-actual" : periodo);
    }
}
