package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.DetallePolizaUseCase;
import com.mapfre.pgm.bff.application.port.in.DetalleReciboUseCase;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DetalleService implements DetallePolizaUseCase, DetalleReciboUseCase {

    private final PolizasPort polizasPort;
    private final RecibosPort recibosPort;

    public DetalleService(PolizasPort polizasPort, RecibosPort recibosPort) {
        this.polizasPort = polizasPort;
        this.recibosPort = recibosPort;
    }

    @Override
    public Poliza detalle(String numeroPoliza) {
        return polizasPort.detalle(numeroPoliza)
                .orElseThrow(() -> new RecursoNoEncontradoException("Póliza", numeroPoliza));
    }

    @Override
    public List<Recibo> recibosDePoliza(String numeroPoliza) {
        Poliza poliza = detalle(numeroPoliza);
        return recibosPort.porClienteRecibos(poliza.clienteId()).stream()
                .filter(r -> numeroPoliza.equals(r.polizaNumero()))
                .toList();
    }

    @Override
    public Recibo detalleRecibo(String numeroRecibo) {
        return recibosPort.detalleRecibo(numeroRecibo)
                .orElseThrow(() -> new RecursoNoEncontradoException("Recibo", numeroRecibo));
    }
}
