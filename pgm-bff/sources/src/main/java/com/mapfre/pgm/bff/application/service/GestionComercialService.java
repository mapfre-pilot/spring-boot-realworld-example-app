package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.GestionComercialUseCase;
import com.mapfre.pgm.bff.application.port.out.GestionComercialPort;
import com.mapfre.pgm.bff.application.port.out.OportunidadesPort;
import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.model.*;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Reproduce la degradación por perfil de la pestaña «Gestión comercial» de PGM:
 * sin NUUMA/estructura → «Esta acción aún no está disponible en PGM para tu usuario (…)»;
 * sin perfil SGC 3.0 → «No tienes permiso para ver las gestiones». Las escrituras pasan por PGO/SGC/iMediador vía Gateway.
 */
@Service
public class GestionComercialService implements GestionComercialUseCase {

    private final OportunidadesPort oportunidades;
    private final GestionComercialPort gestionComercial;
    private final UsuariosComercialesPort usuarios;
    private final AuditoriaUseCase auditoria;

    public GestionComercialService(OportunidadesPort oportunidades, GestionComercialPort gestionComercial,
                                   UsuariosComercialesPort usuarios, AuditoriaUseCase auditoria) {
        this.oportunidades = oportunidades;
        this.gestionComercial = gestionComercial;
        this.usuarios = usuarios;
        this.auditoria = auditoria;
    }

    @Override
    public List<Oportunidad> oportunidades(String clienteId, FiltroOportunidades f) {
        List<Oportunidad> todas = oportunidades.porClienteOportunidades(clienteId);
        if (f == null) {
            return todas;
        }
        return todas.stream()
                .filter(o -> f.producto() == null || f.producto() == o.ramo())
                .filter(o -> f.tipo() == null || f.tipo() == o.tipo())
                .filter(o -> f.clase() == null || f.clase() == o.clase())
                .filter(o -> f.contratado() == null || f.contratado() == o.contratado())
                .filter(o -> f.desde() == null || (o.fecha() != null && !o.fecha().isBefore(f.desde())))
                .filter(o -> f.hasta() == null || (o.fecha() != null && !o.fecha().isAfter(f.hasta())))
                .toList();
    }

    @Override
    public ResumenOportunidades resumenOportunidades(String clienteId) {
        return oportunidades.resumen(clienteId);
    }

    @Override
    public Optional<OportunidadDetalle> detalleOportunidad(String oportunidadId, String usuario) {
        return oportunidades.detalle(oportunidadId);
    }

    @Override
    public Oportunidad crearOportunidad(AltaOportunidad alta, String usuario) {
        String nuuma = exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.accionNoDisponible(nuuma));
        Oportunidad creada = oportunidades.crear(alta, nuuma);
        auditoria.registrarAcceso(usuario, "ALTA_VENCIMIENTO", alta.clienteId(), "ficha-cliente/gestion-comercial");
        return creada;
    }

    @Override
    public Observacion anadirObservacionOportunidad(String oportunidadId, String texto, String usuario) {
        return oportunidades.anadirObservacion(oportunidadId, texto, exigirNuuma(usuario));
    }

    @Override
    public void eliminarObservacionOportunidad(String oportunidadId, String observacionId, String usuario) {
        oportunidades.eliminarObservacion(oportunidadId, observacionId, exigirNuuma(usuario));
    }

    @Override
    public List<ActividadComercial> actividadComercial(String clienteId, FiltroActividad f, String usuario) {
        String nuuma = exigirNuuma(usuario);
        List<ActividadComercial> todas = gestionComercial.actividadComercial(clienteId, nuuma);
        if (f == null) {
            return todas;
        }
        return todas.stream()
                .filter(a -> f.desde() == null || (a.fecha() != null && !a.fecha().toLocalDate().isBefore(f.desde())))
                .filter(a -> f.hasta() == null || (a.fecha() != null && !a.fecha().toLocalDate().isAfter(f.hasta())))
                .filter(a -> f.gestionAlcanzada() == null || f.gestionAlcanzada().equalsIgnoreCase(a.gestionAlcanzada()))
                .filter(a -> f.producto() == null || f.producto().equalsIgnoreCase(a.producto()))
                .filter(a -> f.tipoAccion() == null || f.tipoAccion().equalsIgnoreCase(a.tipoAccion()))
                .toList();
    }

    @Override
    public ActividadComercial crearActividad(AltaActividad alta, String usuario) {
        String nuuma = exigirNuuma(usuario);
        ActividadComercial creada = gestionComercial.crearActividad(alta, nuuma);
        auditoria.registrarAcceso(usuario, "ALTA_ACTIVIDAD_COMERCIAL", alta.clienteId(), "ficha-cliente/gestion-comercial");
        return creada;
    }

    @Override
    public CatalogoComercial catalogo(CatalogoComercial.Tipo tipo, String usuario) {
        EstructuraComercial e = usuarios.estructuraDe(usuario).orElse(null);
        return gestionComercial.catalogo(tipo, e == null ? null : e.oficina());
    }

    @Override
    public List<GestionComercial> gestiones(String clienteId, String usuario) {
        exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.SIN_PERMISO_GESTIONES);
        return gestionComercial.gestionesPorCliente(clienteId).stream().filter(GestionComercial::visible).toList();
    }

    @Override
    public Optional<GestionDetalle> detalleGestion(String gestionId, String usuario) {
        String nuuma = exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.SIN_PERMISO_GESTIONES);
        return gestionComercial.detalleGestion(gestionId, nuuma);
    }

    @Override
    public GestionComercial cerrarGestion(String gestionId, String resultado, String usuario) {
        String nuuma = exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.SIN_PERMISO_GESTIONES);
        GestionComercial g = gestionComercial.cerrarGestion(gestionId, resultado, nuuma);
        auditoria.registrarAcceso(usuario, "CERRAR_GESTION", g.clienteId(), "ficha-cliente/gestion-comercial");
        return g;
    }

    @Override
    public GestionComercial reabrirGestion(String gestionId, String usuario) {
        String nuuma = exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.SIN_PERMISO_GESTIONES);
        GestionComercial g = gestionComercial.reabrirGestion(gestionId, nuuma);
        auditoria.registrarAcceso(usuario, "REABRIR_GESTION", g.clienteId(), "ficha-cliente/gestion-comercial");
        return g;
    }

    @Override
    public Observacion anadirObservacionGestion(String gestionId, String texto, String usuario) {
        String nuuma = exigirNuuma(usuario);
        exigirPerfilSgc30(usuario, TextosPgm.SIN_PERMISO_GESTIONES);
        return gestionComercial.anadirObservacionGestion(gestionId, texto, nuuma);
    }

    private String exigirNuuma(String usuario) {
        return usuarios.estructuraDe(usuario)
                .map(EstructuraComercial::nuuma)
                .filter(n -> n != null && !n.isBlank())
                .orElseThrow(() -> new AccesoNoAutorizadoException(
                        TextosPgm.accionNoDisponible(null) + ". " + TextosPgm.CONTACTA_ADMINISTRADOR));
    }

    private void exigirPerfilSgc30(String usuario, String mensaje) {
        if (usuarios.perfilSgc30De(usuario).isEmpty()) {
            throw new AccesoNoAutorizadoException(mensaje);
        }
    }
}
