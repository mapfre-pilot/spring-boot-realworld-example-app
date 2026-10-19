package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.DetallePolizaUseCase;
import com.mapfre.pgm.bff.application.port.in.DetalleReciboUseCase;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Recibo;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.ListaDto;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/api/v1", produces = "application/json")
public class PolizasRecibosController {

    private final DetallePolizaUseCase polizas;
    private final DetalleReciboUseCase recibos;

    public PolizasRecibosController(DetallePolizaUseCase polizas, DetalleReciboUseCase recibos) {
        this.polizas = polizas;
        this.recibos = recibos;
    }

    @GetMapping("/polizas/{numero}")
    public Poliza poliza(@PathVariable String numero) {
        return polizas.detalle(numero);
    }

    @GetMapping("/polizas/{numero}/recibos")
    public ListaDto<Recibo> recibosDePoliza(@PathVariable String numero) {
        return ListaDto.de(polizas.recibosDePoliza(numero));
    }

    @GetMapping("/recibos/{numero}")
    public Recibo recibo(@PathVariable String numero) {
        return recibos.detalleRecibo(numero);
    }
}
