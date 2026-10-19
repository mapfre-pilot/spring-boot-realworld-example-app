package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.ContextoUsuarioUseCase;
import com.mapfre.pgm.bff.application.port.in.CuadroMandoUseCase;
import com.mapfre.pgm.bff.application.port.in.LanzaderasUseCase;
import com.mapfre.pgm.bff.application.service.AutorizacionService;
import com.mapfre.pgm.bff.application.service.Visibilidades;
import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import com.mapfre.pgm.bff.domain.model.Kpi;
import com.mapfre.pgm.bff.domain.model.Lanzadera;
import com.mapfre.pgm.bff.domain.model.Ramo;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.*;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

/** Contexto de usuario (visibilidades), lanzaderas, auditoría y cuadro de mando. */
@RestController
@RequestMapping(path = "/api/v1", produces = "application/json")
public class ContextoController {

    private final ContextoUsuarioUseCase contexto;
    private final AutorizacionService autorizacion;
    private final LanzaderasUseCase lanzaderas;
    private final AuditoriaUseCase auditoria;
    private final CuadroMandoUseCase cuadroMando;

    public ContextoController(ContextoUsuarioUseCase contexto, AutorizacionService autorizacion,
                              LanzaderasUseCase lanzaderas, AuditoriaUseCase auditoria, CuadroMandoUseCase cuadroMando) {
        this.contexto = contexto;
        this.autorizacion = autorizacion;
        this.lanzaderas = lanzaderas;
        this.auditoria = auditoria;
        this.cuadroMando = cuadroMando;
    }

    @GetMapping("/contexto")
    public ContextoUsuarioDto contexto(UsuarioActual u) {
        return ContextoUsuarioDto.de(contexto.contexto(u.id(), u.nombre(), u.perfiles()));
    }

    @GetMapping("/lanzaderas")
    public ListaDto<Lanzadera> lanzaderas(@RequestParam(required = false) Ramo ramo, UsuarioActual u) {
        return ListaDto.de(lanzaderas.disponibles(ramo, u.id()));
    }

    @PostMapping(path = "/auditoria", consumes = "application/json")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public void auditoria(@Valid @RequestBody AuditoriaRequest req, UsuarioActual u) {
        auditoria.registrarAcceso(u.id(), req.accion(), req.clienteId(), req.pantalla());
    }

    @GetMapping("/cuadro-mando/kpis")
    public ListaDto<Kpi> kpis(@RequestParam(required = false) String periodo, UsuarioActual u) {
        ContextoUsuario ctx = contexto.contexto(u.id(), u.nombre(), u.perfiles());
        autorizacion.exigir(ctx, Visibilidades.CUADRO_MANDO);
        return ListaDto.de(cuadroMando.kpis(periodo, u.id()));
    }
}
