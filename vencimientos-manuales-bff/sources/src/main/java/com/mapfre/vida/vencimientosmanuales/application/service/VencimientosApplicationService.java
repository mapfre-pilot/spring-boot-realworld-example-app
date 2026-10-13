package com.mapfre.vida.vencimientosmanuales.application.service;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.*;
import com.mapfre.vida.vencimientosmanuales.application.port.in.VencimientosUseCase;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;
import org.springframework.stereotype.Service;

@Service
public class VencimientosApplicationService implements VencimientosUseCase {
    private final HostVencimientosPort host;
    private final LiquidationCalculator calculator = new LiquidationCalculator();

    public VencimientosApplicationService(HostVencimientosPort host) {
        this.host = host;
    }

    @Override
    public VtResponse execute(Operacion operation, VtRequest request) {
        VtResponse response = host.execute(operation, request);
        if (operation == Operacion.VT04 && request instanceof Vt04Request search) {
            host.execute(Operacion.VT08, new Vt08Request(search.busqueda().anio(),
                    search.busqueda().numero(), "S", null, null));
        }
        return response;
    }

    @Override
    public LiquidationCalculator.Result calculate(LiquidationCalculator.Input input) {
        return calculator.calculate(input);
    }
}
