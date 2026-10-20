package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.BuscarClientesUseCase;
import com.mapfre.pgm.bff.application.port.in.FichaClienteUseCase;
import com.mapfre.pgm.bff.application.port.out.ClientesPort.CriteriosBusqueda;
import com.mapfre.pgm.bff.domain.model.*;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.ListaDto;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(path = "/api/v1/clientes", produces = "application/json")
public class ClientesController {

    private final BuscarClientesUseCase buscar;
    private final FichaClienteUseCase ficha;

    public ClientesController(BuscarClientesUseCase buscar, FichaClienteUseCase ficha) {
        this.buscar = buscar;
        this.ficha = ficha;
    }

    @GetMapping("/search")
    public ListaDto<ClienteResumen> buscar(@RequestParam(required = false) String q,
                                           @RequestParam(required = false) String documento,
                                           @RequestParam(required = false) String telefono,
                                           @RequestParam(required = false) String email,
                                           @RequestParam(required = false) String poliza,
                                           @RequestParam(required = false) String tarjetaSanitaria,
                                           @RequestParam(required = false) String localidad,
                                           @RequestParam(defaultValue = "100") int limite,
                                           @RequestParam(required = false) String primerApellido,
                                           @RequestParam(required = false) String segundoApellido,
                                           @RequestParam(required = false) String codigoPostal,
                                           @RequestParam(required = false) String expediente,
                                           @RequestParam(required = false) String matricula,
                                           @RequestParam(required = false) String presupuesto,
                                           @RequestParam(required = false) String recibo,
                                           UsuarioActual usuario) {
        return ListaDto.de(buscar.buscar(new CriteriosBusqueda(q, documento, telefono, email, poliza, tarjetaSanitaria,
                localidad, limite, primerApellido, segundoApellido, codigoPostal, expediente, matricula, presupuesto, recibo),
                usuario.id()));
    }

    @GetMapping("/{id}/ficha")
    public Cliente ficha(@PathVariable String id, UsuarioActual usuario) {
        return ficha.ficha(id, usuario.id());
    }

    @GetMapping("/{id}/productos")
    public ListaDto<Poliza> productos(@PathVariable String id) {
        return ListaDto.de(ficha.productos(id));
    }

    @GetMapping("/{id}/recibos")
    public ListaDto<Recibo> recibos(@PathVariable String id) {
        return ListaDto.de(ficha.recibos(id));
    }

    @GetMapping("/{id}/prestaciones")
    public ListaDto<Prestacion> prestaciones(@PathVariable String id) {
        return ListaDto.de(ficha.prestaciones(id));
    }

    @GetMapping("/{id}/presupuestos")
    public ListaDto<Presupuesto> presupuestos(@PathVariable String id) {
        return ListaDto.de(ficha.presupuestos(id));
    }

    @GetMapping("/{id}/gestiones")
    public ListaDto<GestionComercial> gestiones(@PathVariable String id, UsuarioActual usuario) {
        return ListaDto.de(ficha.gestiones(id, usuario.id()));
    }

    @GetMapping("/{id}/solicitudes-sgo")
    public ListaDto<SolicitudSgo> solicitudesSgo(@PathVariable String id) {
        return ListaDto.de(ficha.solicitudesSgo(id));
    }
}
