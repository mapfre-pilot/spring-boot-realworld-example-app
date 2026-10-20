package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/** Pestaña «Gestión comercial» de la ficha: vencimientos (PGO), actividad comercial (iMediador) y gestiones (SGC 3.0). */
public interface GestionComercialUseCase {
    record FiltroOportunidades(Ramo producto, Oportunidad.Tipo tipo, LocalDate desde, LocalDate hasta, Boolean contratado,
                               Oportunidad.Clase clase) {}
    record FiltroActividad(LocalDate desde, LocalDate hasta, String gestionAlcanzada, String producto, String tipoAccion) {}

    List<Oportunidad> oportunidades(String clienteId, FiltroOportunidades filtro);
    ResumenOportunidades resumenOportunidades(String clienteId);
    Optional<OportunidadDetalle> detalleOportunidad(String oportunidadId, String usuario);
    Oportunidad crearOportunidad(AltaOportunidad alta, String usuario);
    Observacion anadirObservacionOportunidad(String oportunidadId, String texto, String usuario);
    void eliminarObservacionOportunidad(String oportunidadId, String observacionId, String usuario);

    List<ActividadComercial> actividadComercial(String clienteId, FiltroActividad filtro, String usuario);
    ActividadComercial crearActividad(AltaActividad alta, String usuario);
    CatalogoComercial catalogo(CatalogoComercial.Tipo tipo, String usuario);

    List<GestionComercial> gestiones(String clienteId, String usuario);
    Optional<GestionDetalle> detalleGestion(String gestionId, String usuario);
    GestionComercial cerrarGestion(String gestionId, String resultado, String usuario);
    GestionComercial reabrirGestion(String gestionId, String usuario);
    Observacion anadirObservacionGestion(String gestionId, String texto, String usuario);
}
