package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.DetallePolizaUseCase;
import com.mapfre.pgm.bff.application.port.in.DetalleReciboUseCase;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.application.port.out.SiniestrosPort;
import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.application.port.in.ContextoUsuarioUseCase;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.domain.model.Ramo;
import java.util.Set;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.Poliza;
import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DetalleService implements DetallePolizaUseCase, DetalleReciboUseCase {

    private final PolizasPort polizasPort;
    private final RecibosPort recibosPort;
    private final SiniestrosPort siniestrosPort;
    private final UsuariosComercialesPort usuarios;
    private final ContextoUsuarioUseCase contexto;

    static final String MSG_FICHA_POLIZA_RESTRINGIDA =
            "La ficha de póliza de este ramo no está disponible para tu usuario. Contacta con el administrador de la aplicación si consideras que debes acceder";
    static final String MSG_DETALLE_RECIBOS_DESACTIVADO = "La visualización del detalle de recibos no está activa en este entorno";
    static final String MSG_DETALLE_PRESTACIONES_DESACTIVADO = "La visualización del detalle de prestaciones no está activa en este entorno";
    static final String MSG_DUPLICADO_SIN_NUUMA = "Para visualizar el duplicado del recibo es necesario un usuario con NUUMA";
    private static final Set<Ramo> RAMOS_RESTRINGIDOS = Set.of(Ramo.AUTOS, Ramo.HOGAR);

    public DetalleService(PolizasPort polizasPort, RecibosPort recibosPort, SiniestrosPort siniestrosPort,
                          UsuariosComercialesPort usuarios, ContextoUsuarioUseCase contexto) {
        this.polizasPort = polizasPort;
        this.recibosPort = recibosPort;
        this.siniestrosPort = siniestrosPort;
        this.usuarios = usuarios;
        this.contexto = contexto;
    }

    private boolean visible(String usuario, List<String> perfiles, String clave) {
        ContextoUsuario c = contexto.contexto(usuario, null, perfiles == null ? List.of() : perfiles);
        return Boolean.TRUE.equals(c.visibilidades().get(clave));
    }

    private Poliza polizaVisible(String numeroPoliza, String usuario, List<String> perfiles) {
        Poliza p = detalle(numeroPoliza);
        if (RAMOS_RESTRINGIDOS.contains(p.ramo()) && !visible(usuario, perfiles, Visibilidades.FICHA_POLIZA_AUTOS_HOGAR)) {
            throw new AccesoNoAutorizadoException(MSG_FICHA_POLIZA_RESTRINGIDA);
        }
        return p;
    }

    @Override
    public Poliza detalle(String numeroPoliza, String usuario, List<String> perfiles) {
        return polizaVisible(numeroPoliza, usuario, perfiles);
    }

    @Override
    public List<AccionPoliza> accionesPoliza(String numeroPoliza, String usuario, List<String> perfiles) {
        detalle(numeroPoliza);
        boolean nuuma = usuarios.estructuraDe(usuario).map(EstructuraComercial::nuuma).filter(n -> n != null && !n.isBlank()).isPresent();
        return polizasPort.accionesPoliza(numeroPoliza).stream().filter(a -> !a.requiereNuuma() || nuuma).toList();
    }

    @Override
    public List<DocumentoPoliza> documentosPoliza(String numeroPoliza) {
        detalle(numeroPoliza);
        return polizasPort.documentosPoliza(numeroPoliza);
    }

    @Override
    public DetallePolizaRamo detalleRamo(String numeroPoliza, String usuario, List<String> perfiles) {
        polizaVisible(numeroPoliza, usuario, perfiles);
        return polizasPort.detalleRamo(numeroPoliza)
                .orElseThrow(() -> new RecursoNoEncontradoException("detalle-poliza", numeroPoliza));
    }

    @Override
    public List<EstadoAnterior> estadosAnteriores(String clienteId) {
        return polizasPort.estadosAnteriores(clienteId);
    }

    @Override
    public List<AccionRecibo> accionesRecibo(String numeroRecibo, String usuario, List<String> perfiles) {
        Recibo r = detalleRecibo(numeroRecibo);
        List<AccionRecibo> acciones = new java.util.ArrayList<>();
        acciones.add(new AccionRecibo("CONSULTA_RECIBOS", "Consulta Recibos", "EXTERNA",
                "/consuweb/recibos/consulta?numRecibo=" + r.numero()));
        if (visible(usuario, perfiles, Visibilidades.DUPLICADO_RECIBO)) {
            acciones.add(new AccionRecibo("VISUALIZAR_DUPLICADO", "Visualizar duplicado", "OPERACION", null));
        }
        if (visible(usuario, perfiles, Visibilidades.DETALLE_RECIBOS)) {
            acciones.add(new AccionRecibo("DETALLE", "Detalle del recibo", "INTERNA", null));
        }
        return acciones;
    }

    @Override
    public ReciboDetalle detalleCompleto(String numeroRecibo, String usuario, List<String> perfiles) {
        detalleRecibo(numeroRecibo);
        if (!visible(usuario, perfiles, Visibilidades.DETALLE_RECIBOS)) {
            throw new AccesoNoAutorizadoException(MSG_DETALLE_RECIBOS_DESACTIVADO);
        }
        return recibosPort.detalleCompleto(numeroRecibo)
                .orElseThrow(() -> new RecursoNoEncontradoException("detalle-recibo", numeroRecibo));
    }

    @Override
    public DuplicadoRecibo duplicado(String numeroRecibo, String usuario) {
        detalleRecibo(numeroRecibo);
        String nuuma = usuarios.estructuraDe(usuario).map(EstructuraComercial::nuuma)
                .filter(n -> n != null && !n.isBlank())
                .orElseThrow(() -> new AccesoNoAutorizadoException(MSG_DUPLICADO_SIN_NUUMA));
        return recibosPort.duplicado(numeroRecibo, nuuma);
    }

    @Override
    public PrestacionDetalle detallePrestacion(String numero, String usuario, List<String> perfiles) {
        if (!visible(usuario, perfiles, Visibilidades.DETALLE_PRESTACIONES)) {
            throw new AccesoNoAutorizadoException(MSG_DETALLE_PRESTACIONES_DESACTIVADO);
        }
        return siniestrosPort.detallePrestacion(numero)
                .orElseThrow(() -> new RecursoNoEncontradoException("prestacion", numero));
    }

    @Override
    public Poliza detalle(String numeroPoliza) {
        return polizasPort.detalle(numeroPoliza)
                .orElseThrow(() -> new RecursoNoEncontradoException("Póliza", numeroPoliza));
    }

    @Override
    public List<Recibo> recibosDePoliza(String numeroPoliza) {
        Poliza poliza = detalle(numeroPoliza);
        return recibosPort.porClienteRecibos(poliza.clienteId()).stream()
                .filter(r -> numeroPoliza.equals(r.polizaNumero()))
                .toList();
    }

    @Override
    public Recibo detalleRecibo(String numeroRecibo) {
        return recibosPort.detalleRecibo(numeroRecibo)
                .orElseThrow(() -> new RecursoNoEncontradoException("Recibo", numeroRecibo));
    }
}
