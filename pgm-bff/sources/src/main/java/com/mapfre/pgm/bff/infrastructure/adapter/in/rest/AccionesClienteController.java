package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.AccionesClienteUseCase;
import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.ListaDto;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

/** Menú ACCIONES de la cabecera y acciones de las palancas (DNI, RGPD, ACI, Plan de pagos, Cliente Total, Inducción). */
@RestController
@RequestMapping(path = "/api/v1/clientes/{id}", produces = "application/json")
public class AccionesClienteController {

    private final AccionesClienteUseCase acciones;

    public AccionesClienteController(AccionesClienteUseCase acciones) {
        this.acciones = acciones;
    }

    @GetMapping("/mas-datos")
    public MasDatos masDatos(@PathVariable String id, UsuarioActual usuario) {
        return acciones.masDatos(id, usuario.id());
    }

    @PutMapping(path = "/contacto", consumes = "application/json")
    public MasDatos contacto(@PathVariable String id, @RequestBody ContactoActualizado contacto, UsuarioActual usuario) {
        return acciones.actualizarContacto(id, contacto, usuario.id());
    }

    @GetMapping("/comunicaciones")
    public Comunicaciones comunicaciones(@PathVariable String id, @RequestParam(defaultValue = "30D") String periodo,
                                         UsuarioActual usuario) {
        return acciones.comunicaciones(id, periodo, usuario.id());
    }

    @GetMapping("/documentos")
    public ListaDto<DocumentoCliente> documentos(@PathVariable String id, @RequestParam(required = false) String tipo,
                                                 UsuarioActual usuario) {
        return ListaDto.de(acciones.documentos(id, tipo, usuario.id()));
    }

    @PostMapping("/dni/solicitud")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ResultadoAccion dni(@PathVariable String id, @RequestBody(required = false) Map<String, String> cuerpo,
                               UsuarioActual usuario) {
        return acciones.solicitarDigitalizacionDni(id, cuerpo == null ? null : cuerpo.get("canal"), usuario.id());
    }

    @GetMapping("/rgpd/metodos")
    public FirmaRgpd metodosRgpd(@PathVariable String id, UsuarioActual usuario) {
        return acciones.metodosFirmaRgpd(id, usuario.id());
    }

    @PostMapping(path = "/rgpd/firma", consumes = "application/json")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ResultadoAccion firmaRgpd(@PathVariable String id, @RequestBody SolicitudFirma solicitud, UsuarioActual usuario) {
        return acciones.firmarRgpd(id, solicitud.metodo(), usuario.id());
    }

    @PostMapping("/aci")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ResultadoAccion aci(@PathVariable String id, UsuarioActual usuario) {
        return acciones.altaAci(id, usuario.id());
    }

    @GetMapping("/cliente-total")
    public ClienteTotal clienteTotal(@PathVariable String id, UsuarioActual usuario) {
        return acciones.clienteTotal(id, usuario.id());
    }

    @PostMapping(path = "/cliente-total/empresas", consumes = "application/json")
    @ResponseStatus(HttpStatus.CREATED)
    public ClienteTotal empresa(@PathVariable String id, @RequestBody EmpresaVinculada empresa, UsuarioActual usuario) {
        return acciones.anadirEmpresaVinculada(id, empresa, usuario.id());
    }

    @GetMapping("/plan-pagos")
    public PlanPagos planPagos(@PathVariable String id, UsuarioActual usuario) {
        return acciones.planPagos(id, usuario.id());
    }

    @PostMapping("/plan-pagos/simulacion")
    public SimulacionPlanPagos simular(@PathVariable String id, @RequestBody(required = false) Map<String, String> cuerpo,
                                       UsuarioActual usuario) {
        return acciones.simularPlanPagos(id, cuerpo == null ? null : cuerpo.get("tipo"), usuario.id());
    }

    @PostMapping("/inducciones")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public ResultadoAccion inducir(@PathVariable String id, @RequestBody(required = false) Map<String, String> cuerpo,
                                   UsuarioActual usuario) {
        return acciones.inducir(id, cuerpo == null ? null : cuerpo.get("canal"), usuario.id());
    }
}
