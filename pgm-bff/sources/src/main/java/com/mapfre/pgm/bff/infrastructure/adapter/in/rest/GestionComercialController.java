package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.FichaClienteUseCase;
import com.mapfre.pgm.bff.application.port.in.GestionComercialUseCase;
import com.mapfre.pgm.bff.application.port.in.GestionComercialUseCase.FiltroActividad;
import com.mapfre.pgm.bff.application.port.in.GestionComercialUseCase.FiltroOportunidades;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.*;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.ListaDto;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.ObservacionRequest;
import com.mapfre.pgm.bff.infrastructure.adapter.in.rest.ApiDtos.CierreGestionRequest;
import jakarta.validation.Valid;
import java.net.URI;
import java.time.LocalDate;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/** Pestaña «Gestión comercial» de la ficha: vencimientos PGO, actividad comercial iMediador, gestiones SGC 3.0 y SGO. */
@RestController
@RequestMapping(path = "/api/v1", produces = "application/json")
public class GestionComercialController {

    private final GestionComercialUseCase gc;
    private final FichaClienteUseCase ficha;
    private final IdempotenciaService idempotencia;

    public GestionComercialController(GestionComercialUseCase gc, FichaClienteUseCase ficha, IdempotenciaService idempotencia) {
        this.gc = gc;
        this.ficha = ficha;
        this.idempotencia = idempotencia;
    }

    // ----- SGO: detalle de solicitud y documentos -----

    @GetMapping("/solicitudes-sgo/{id}")
    public SolicitudSgoDetalle solicitudSgo(@PathVariable String id) {
        return ficha.solicitudSgo(id).orElseThrow(() -> new RecursoNoEncontradoException("Solicitud SGO", id));
    }

    @GetMapping("/solicitudes-sgo/{id}/documentos")
    public ListaDto<DocumentoAdjunto> documentosSgo(@PathVariable String id) {
        return ListaDto.de(ficha.documentosSgo(id));
    }

    // ----- Vencimientos / oportunidades (PGO) -----

    @GetMapping("/clientes/{id}/oportunidades")
    public ListaDto<Oportunidad> oportunidades(@PathVariable String id,
            @RequestParam(required = false) Ramo producto,
            @RequestParam(required = false) Oportunidad.Tipo tipo,
            @RequestParam(required = false) Oportunidad.Clase clase,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
            @RequestParam(required = false) Boolean contratado) {
        return ListaDto.de(gc.oportunidades(id, new FiltroOportunidades(producto, tipo, desde, hasta, contratado, clase)));
    }

    @GetMapping("/clientes/{id}/oportunidades/resumen")
    public ResumenOportunidades resumenOportunidades(@PathVariable String id) {
        return gc.resumenOportunidades(id);
    }

    @PostMapping(path = "/clientes/{id}/oportunidades", consumes = "application/json")
    public ResponseEntity<Oportunidad> crearOportunidad(@PathVariable String id, @Valid @RequestBody AltaOportunidad alta,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/clientes/" + id + "/oportunidades", key, alta, () -> {
            AltaOportunidad conCliente = new AltaOportunidad(id, alta.ramo(), alta.tipo(), alta.fecha(), alta.entidadCompetencia(),
                    alta.prima(), alta.comentarios(), alta.datosProducto(), alta.datosRiesgo());
            Oportunidad o = gc.crearOportunidad(conCliente, u.id());
            return ResponseEntity.created(URI.create("/api/v1/oportunidades/" + o.id())).body(o);
        });
    }

    @GetMapping("/oportunidades/{id}")
    public OportunidadDetalle detalleOportunidad(@PathVariable String id, UsuarioActual u) {
        return gc.detalleOportunidad(id, u.id()).orElseThrow(() -> new RecursoNoEncontradoException("Vencimiento", id));
    }

    @PostMapping(path = "/oportunidades/{id}/observaciones", consumes = "application/json")
    public ResponseEntity<Observacion> observacionOportunidad(@PathVariable String id, @Valid @RequestBody ObservacionRequest req,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/oportunidades/" + id + "/observaciones", key, req,
                () -> ResponseEntity.status(201).body(gc.anadirObservacionOportunidad(id, req.texto(), u.id())));
    }

    @DeleteMapping("/oportunidades/{id}/observaciones/{obsId}")
    public ResponseEntity<Void> eliminarObservacionOportunidad(@PathVariable String id, @PathVariable String obsId, UsuarioActual u) {
        gc.eliminarObservacionOportunidad(id, obsId, u.id());
        return ResponseEntity.noContent().build();
    }

    // ----- Actividad comercial (iMediador) -----

    @GetMapping("/clientes/{id}/actividad-comercial")
    public ListaDto<ActividadComercial> actividad(@PathVariable String id,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate desde,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hasta,
            @RequestParam(required = false) String gestionAlcanzada,
            @RequestParam(required = false) String producto,
            @RequestParam(required = false) String tipoAccion, UsuarioActual u) {
        return ListaDto.de(gc.actividadComercial(id, new FiltroActividad(desde, hasta, gestionAlcanzada, producto, tipoAccion), u.id()));
    }

    @PostMapping(path = "/clientes/{id}/actividad-comercial", consumes = "application/json")
    public ResponseEntity<ActividadComercial> crearActividad(@PathVariable String id, @Valid @RequestBody AltaActividad alta,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/clientes/" + id + "/actividad-comercial", key, alta, () -> {
            AltaActividad conCliente = new AltaActividad(id, alta.nivelGestion(), alta.comentario(), alta.polizaNumero(), alta.sinRgpd());
            return ResponseEntity.status(201).body(gc.crearActividad(conCliente, u.id()));
        });
    }

    @GetMapping("/catalogos-comerciales/{tipo}")
    public CatalogoComercial catalogo(@PathVariable CatalogoComercial.Tipo tipo, UsuarioActual u) {
        return gc.catalogo(tipo, u.id());
    }

    // ----- Gestiones SGC 3.0 -----

    @GetMapping("/gestiones/{id}")
    public GestionDetalle detalleGestion(@PathVariable String id, UsuarioActual u) {
        return gc.detalleGestion(id, u.id()).orElseThrow(() -> new RecursoNoEncontradoException("Gestión", id));
    }

    @PostMapping(path = "/gestiones/{id}/cierre", consumes = "application/json")
    public ResponseEntity<GestionComercial> cerrar(@PathVariable String id, @Valid @RequestBody CierreGestionRequest req,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/gestiones/" + id + "/cierre", key, req,
                () -> ResponseEntity.ok(gc.cerrarGestion(id, req.resultado(), u.id())));
    }

    @PostMapping("/gestiones/{id}/reapertura")
    public ResponseEntity<GestionComercial> reabrir(@PathVariable String id,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/gestiones/" + id + "/reapertura", key, id,
                () -> ResponseEntity.ok(gc.reabrirGestion(id, u.id())));
    }

    @PostMapping(path = "/gestiones/{id}/observaciones", consumes = "application/json")
    public ResponseEntity<Observacion> observacionGestion(@PathVariable String id, @Valid @RequestBody ObservacionRequest req,
            @RequestHeader(value = "Idempotency-Key", required = false) String key, UsuarioActual u) {
        return idempotencia.ejecutar(u.id(), "POST", "/api/v1/gestiones/" + id + "/observaciones", key, req,
                () -> ResponseEntity.status(201).body(gc.anadirObservacionGestion(id, req.texto(), u.id())));
    }
}
