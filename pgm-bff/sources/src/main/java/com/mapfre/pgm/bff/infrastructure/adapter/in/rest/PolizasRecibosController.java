package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import java.util.List;
import org.springframework.web.bind.annotation.PostMapping;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
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

    // ---------- Área B: ficha de póliza por ramo, acciones, documentación, estados anteriores, recibo y prestación ----------
    @GetMapping("/polizas/{numero}/ficha")
    public Poliza fichaPoliza(@PathVariable String numero, UsuarioActual usuario) {
        return polizas.detalle(numero, usuario.id(), usuario.perfiles());
    }

    @GetMapping("/polizas/{numero}/acciones")
    public ListaDto<AccionPoliza> accionesPoliza(@PathVariable String numero, UsuarioActual usuario) {
        return ListaDto.de(polizas.accionesPoliza(numero, usuario.id(), usuario.perfiles()));
    }

    @GetMapping("/polizas/{numero}/documentos")
    public ListaDto<DocumentoPoliza> documentosPoliza(@PathVariable String numero) {
        return ListaDto.de(polizas.documentosPoliza(numero));
    }

    @GetMapping("/polizas/{numero}/detalle-ramo")
    public DetallePolizaRamo detalleRamo(@PathVariable String numero, UsuarioActual usuario) {
        return polizas.detalleRamo(numero, usuario.id(), usuario.perfiles());
    }

    @GetMapping("/clientes/{id}/estados-anteriores")
    public ListaDto<EstadoAnterior> estadosAnteriores(@PathVariable String id) {
        return ListaDto.de(polizas.estadosAnteriores(id));
    }

    @GetMapping("/recibos/{numero}/acciones")
    public ListaDto<AccionRecibo> accionesRecibo(@PathVariable String numero, UsuarioActual usuario) {
        return ListaDto.de(recibos.accionesRecibo(numero, usuario.id(), usuario.perfiles()));
    }

    @GetMapping("/recibos/{numero}/detalle")
    public ReciboDetalle detalleRecibo(@PathVariable String numero, UsuarioActual usuario) {
        return recibos.detalleCompleto(numero, usuario.id(), usuario.perfiles());
    }

    @PostMapping("/recibos/{numero}/duplicado")
    public DuplicadoRecibo duplicado(@PathVariable String numero, UsuarioActual usuario) {
        return recibos.duplicado(numero, usuario.id());
    }

    @GetMapping("/prestaciones/{numero}")
    public PrestacionDetalle prestacion(@PathVariable String numero, UsuarioActual usuario) {
        return recibos.detallePrestacion(numero, usuario.id(), usuario.perfiles());
    }
}
