package com.mapfre.vida.vencimientosmanuales.application.port.in;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.VtRequest;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.VtResponse;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;

public interface VencimientosUseCase {
    VtResponse execute(Operacion operation, VtRequest request);

    LiquidationCalculator.Result calculate(LiquidationCalculator.Input input);
}
