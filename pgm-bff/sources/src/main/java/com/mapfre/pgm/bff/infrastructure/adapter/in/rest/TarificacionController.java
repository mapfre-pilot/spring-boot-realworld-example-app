package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.ContextoUsuarioUseCase;
import com.mapfre.pgm.bff.application.port.in.TarificacionSaludUseCase;
import com.mapfre.pgm.bff.application.port.out.ComunicacionesPort;
import com.mapfre.pgm.bff.application.service.AutorizacionService;
import com.mapfre.pgm.bff.application.service.Visibilidades;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.*;
import jakarta.validation.Valid;
import java.net.URI;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/** Nueva producción: tarificación rápida de Salud, borradores y centro de comunicaciones. */
@RestController
@RequestMapping(path = "/api/v1", produces = "application/json")
public class TarificacionController {

    private final TarificacionSaludUseCase tarificacion;
    private final ContextoUsuarioUseCase contexto;
    private final AutorizacionService autorizacion;
    private final AuditoriaUseCase auditoria;
    private final ComunicacionesPort comunicaciones;

    public TarificacionController(TarificacionSaludUseCase tarificacion, ContextoUsuarioUseCase contexto,
                                  AutorizacionService autorizacion, AuditoriaUseCase auditoria, ComunicacionesPort comunicaciones) {
        this.tarificacion = tarificacion;
        this.contexto = contexto;
        this.autorizacion = autorizacion;
        this.auditoria = auditoria;
        this.comunicaciones = comunicaciones;
    }

    @PostMapping(path = "/tarificacion/salud", consumes = "application/json")
    public TarificacionSalud.Resultado tarificar(@Valid @RequestBody TarificacionSaludRequest req, UsuarioActual u) {
        autorizacion.exigir(contexto.contexto(u.id(), u.nombre(), u.perfiles()), Visibilidades.TARIFICACION_SALUD);
        TarificacionSalud.Resultado r = tarificacion.tarificar(aSolicitud(req), u.id());
        auditoria.registrarAcceso(u.id(), "TARIFICACION_SALUD", req.clienteId(), "nueva-produccion");
        return r;
    }

    @PostMapping(path = "/tarificacion/salud/borradores", consumes = "application/json")
    public ResponseEntity<BorradorCreadoDto> guardarBorrador(@Valid @RequestBody TarificacionSaludRequest req, UsuarioActual u) {
        String id = tarificacion.guardarBorrador(aSolicitud(req), u.id());
        return ResponseEntity.created(URI.create("/api/v1/tarificacion/salud/borradores/" + id)).body(new BorradorCreadoDto(id));
    }

    @GetMapping("/tarificacion/salud/borradores/{id}")
    public TarificacionSalud.Solicitud borrador(@PathVariable String id, UsuarioActual u) {
        return tarificacion.borrador(id, u.id()).orElseThrow(() -> new RecursoNoEncontradoException("Borrador", id));
    }

    @PostMapping(path = "/comunicaciones/llamadas", consumes = "application/json")
    public LlamadaDto llamar(@Valid @RequestBody LlamadaRequest req, UsuarioActual u) {
        auditoria.registrarAcceso(u.id(), "CLICK_TO_CALL", req.clienteId(), "centro-comunicaciones");
        return new LlamadaDto(comunicaciones.iniciarLlamada(req.clienteId(), req.telefono(), u.id()));
    }

    private static TarificacionSalud.Solicitud aSolicitud(TarificacionSaludRequest r) {
        return new TarificacionSalud.Solicitud(r.clienteId(), r.producto(), r.codigoPostal(), r.edades(), r.copago());
    }
}
