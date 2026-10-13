package com.mapfre.vida.vencimientosmanuales.application.service;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.*;
import com.mapfre.vida.vencimientosmanuales.application.port.in.VencimientosUseCase;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class VencimientosApplicationService implements VencimientosUseCase {
    private final HostVencimientosPort host;
    private final LiquidationCalculator calculator = new LiquidationCalculator();

    public VencimientosApplicationService(HostVencimientosPort host) {
        this.host = host;
    }

    @Override
    public HostResponse execute(Operacion operation, Map<String, Object> fields) {
        return switch (operation) {
            case VT01 -> host.gestionarExpediente(new Vt01Request(fields));
            case VT02 -> host.gestionarVariables(new Vt02Request(fields));
            case VT03 -> host.gestionarCarteras(new Vt03Request(fields));
            case VT04 -> {
                HostResponse response = host.buscarExpedientes(new Vt04Request(fields));
                host.buscarDatosAdicionales(new Vt08Request(fields));
                yield response;
            }
            case VT05 -> host.listarCarteras(new Vt05Request(fields));
            case VT06 -> host.solicitarBdgi(new Vt06Request(fields));
            case VT07 -> host.cargarFichero(new Vt07Request(fields));
            case VT08 -> host.buscarDatosAdicionales(new Vt08Request(fields));
            case VT09 -> host.emitirFiniquitos(new Vt09Request(fields));
            case VT10 -> host.imprimirInformes(new Vt10Request(fields));
            case VT11 -> host.gestionarPersonas(new Vt11Request(fields));
            case VT12 -> host.gestionarCoaseguro(new Vt12Request(fields));
            case VT19 -> host.consultarCartera(new Vt19Request(fields));
        };
    }

    @Override
    public LiquidationCalculator.Result calculate(LiquidationCalculator.Input input) {
        return calculator.calculate(input);
    }
}
