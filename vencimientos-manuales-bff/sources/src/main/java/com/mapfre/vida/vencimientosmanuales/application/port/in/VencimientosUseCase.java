package com.mapfre.vida.vencimientosmanuales.application.port.in;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.HostResponse;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;

import java.util.Map;

public interface VencimientosUseCase {
    HostResponse execute(Operacion operation, Map<String, Object> fields);

    LiquidationCalculator.Result calculate(LiquidationCalculator.Input input);
}
