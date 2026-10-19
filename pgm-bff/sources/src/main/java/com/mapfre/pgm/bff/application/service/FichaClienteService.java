package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.FichaClienteUseCase;
import com.mapfre.pgm.bff.application.port.out.*;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.*;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class FichaClienteService implements FichaClienteUseCase {

    private final ClientesPort clientesPort;
    private final PolizasPort polizasPort;
    private final RecibosPort recibosPort;
    private final SiniestrosPort siniestrosPort;
    private final VentasPort ventasPort;
    private final OportunidadesPort oportunidadesPort;
    private final GestionComercialPort gestionComercialPort;
    private final SgoPort sgoPort;
    private final AuditoriaUseCase auditoria;

    public FichaClienteService(ClientesPort clientesPort, PolizasPort polizasPort, RecibosPort recibosPort,
                               SiniestrosPort siniestrosPort, VentasPort ventasPort, OportunidadesPort oportunidadesPort,
                               GestionComercialPort gestionComercialPort, SgoPort sgoPort, AuditoriaUseCase auditoria) {
        this.clientesPort = clientesPort;
        this.polizasPort = polizasPort;
        this.recibosPort = recibosPort;
        this.siniestrosPort = siniestrosPort;
        this.ventasPort = ventasPort;
        this.oportunidadesPort = oportunidadesPort;
        this.gestionComercialPort = gestionComercialPort;
        this.sgoPort = sgoPort;
        this.auditoria = auditoria;
    }

    @Override
    public Cliente ficha(String clienteId, String usuario) {
        Cliente cliente = clientesPort.ficha(clienteId)
                .orElseThrow(() -> new RecursoNoEncontradoException("Cliente", clienteId));
        auditoria.registrarAcceso(usuario, "CONSULTA_FICHA", clienteId, "ficha-cliente");
        return cliente;
    }

    @Override
    public List<Poliza> productos(String clienteId) {
        return polizasPort.porCliente(clienteId);
    }

    @Override
    public List<Recibo> recibos(String clienteId) {
        return recibosPort.porClienteRecibos(clienteId);
    }

    @Override
    public List<Prestacion> prestaciones(String clienteId) {
        return siniestrosPort.porClientePrestaciones(clienteId);
    }

    @Override
    public List<Presupuesto> presupuestos(String clienteId) {
        return ventasPort.presupuestosPorCliente(clienteId);
    }

    @Override
    public List<Oportunidad> oportunidades(String clienteId) {
        return oportunidadesPort.porClienteOportunidades(clienteId);
    }

    @Override
    public List<GestionComercial> gestiones(String clienteId, String usuario) {
        boolean tieneEstructura = gestionComercialPort.estructuraDe(usuario)
                .map(e -> e.nuuma() != null && !e.nuuma().isBlank()).orElse(false);
        if (!tieneEstructura || gestionComercialPort.perfilSgc30De(usuario).isEmpty()) {
            throw new AccesoNoAutorizadoException("Gestión comercial requiere perfil SGC 3.0 y estructura comercial (NUUMA)");
        }
        return gestionComercialPort.gestionesPorCliente(clienteId);
    }

    @Override
    public List<SolicitudSgo> solicitudesSgo(String clienteId) {
        return sgoPort.solicitudesPorCliente(clienteId);
    }
}
