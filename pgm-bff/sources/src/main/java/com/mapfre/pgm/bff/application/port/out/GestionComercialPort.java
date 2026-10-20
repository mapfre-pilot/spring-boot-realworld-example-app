package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.ActividadComercial;
import com.mapfre.pgm.bff.domain.model.AltaActividad;
import com.mapfre.pgm.bff.domain.model.CatalogoComercial;
import com.mapfre.pgm.bff.domain.model.GestionComercial;
import com.mapfre.pgm.bff.domain.model.GestionDetalle;
import com.mapfre.pgm.bff.domain.model.Observacion;

import java.util.List;
import java.util.Optional;

/** SGC 3.0 (business tasks) + iMediador EDGE (actividad comercial, catálogos), legacy de PGM vía API Gateway. */
public interface GestionComercialPort {
    List<GestionComercial> gestionesPorCliente(String clienteId);
    Optional<GestionDetalle> detalleGestion(String gestionId, String nuuma);
    GestionComercial cerrarGestion(String gestionId, String resultado, String nuuma);
    GestionComercial reabrirGestion(String gestionId, String nuuma);
    Observacion anadirObservacionGestion(String gestionId, String texto, String nuuma);
    List<ActividadComercial> actividadComercial(String clienteId, String nuuma);
    ActividadComercial crearActividad(AltaActividad alta, String nuuma);
    CatalogoComercial catalogo(CatalogoComercial.Tipo tipo, String estructura);
}
