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
import org.springframework.http.ResponseEntity;
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
    private final IdempotenciaService idempotencia;

    public ContextoController(ContextoUsuarioUseCase contexto, AutorizacionService autorizacion,
                              LanzaderasUseCase lanzaderas, AuditoriaUseCase auditoria, CuadroMandoUseCase cuadroMando,
                              IdempotenciaService idempotencia) {
        this.contexto = contexto;
        this.autorizacion = autorizacion;
        this.lanzaderas = lanzaderas;
        this.auditoria = auditoria;
        this.cuadroMando = cuadroMando;
        this.idempotencia = idempotencia;
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
    public ResponseEntity<Void> auditoria(@Valid @RequestBody AuditoriaRequest req,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/auditoria", key, req, () -> {
            auditoria.registrarAcceso(u.id(), req.accion(), req.clienteId(), req.pantalla());
            return ResponseEntity.status(HttpStatus.ACCEPTED).build();
        });
    }

    @GetMapping("/cuadro-mando/kpis")
    public ListaDto<Kpi> kpis(@RequestParam(required = false) String periodo, UsuarioActual u) {
        ContextoUsuario ctx = contexto.contexto(u.id(), u.nombre(), u.perfiles());
        autorizacion.exigir(ctx, Visibilidades.CUADRO_MANDO);
        return ListaDto.de(cuadroMando.kpis(periodo, u.id()));
    }
}
