package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.application.port.out.SiniestrosPort;
import com.mapfre.pgm.bff.application.port.out.VentasPort;
import com.mapfre.pgm.bff.domain.model.*;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.ApiCanalClientesAdapter;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.ApiCanalPolizasRecibosAdapter;
import com.mapfre.pgm.bff.infrastructure.adapter.out.apicanal.DestinoServicioResolver;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Optional;

/**
 * Enrutado por capacidad según el «Origen de datos» de la pestaña Configuración: API Canal (PROD-APICANAL-*) o los servicios
 * legacy que ya usa PGM en Appian. Ambos salen por el API Gateway (ARCH-FIS-COM-001); el cambio no requiere reinicio.
 */
public final class OrigenDatosRouters {
    private OrigenDatosRouters() {}

    static boolean legacy(DestinoServicioResolver destinos, String capacidad) {
        return destinos.origenDatos().map(o -> o.esLegacy(capacidad)).orElse(false);
    }

    @Component @Primary @Profile("!local")
    public static class Clientes implements ClientesPort {
        private final DestinoServicioResolver destinos;
        private final ApiCanalClientesAdapter apiCanal;
        private final LegacyClientesAdapter legacy;

        public Clientes(DestinoServicioResolver destinos, ApiCanalClientesAdapter apiCanal, LegacyClientesAdapter legacy) {
            this.destinos = destinos; this.apiCanal = apiCanal; this.legacy = legacy;
        }
        private ClientesPort d() { return legacy(destinos, "clientes") ? legacy : apiCanal; }
        @Override public List<ClienteResumen> buscar(CriteriosBusqueda c) { return d().buscar(c); }
        @Override public Optional<Cliente> ficha(String id) { return d().ficha(id); }
    }

    @Component @Primary @Profile("!local")
    public static class Polizas implements PolizasPort {
        private final DestinoServicioResolver destinos;
        private final ApiCanalPolizasRecibosAdapter apiCanal;
        private final LegacyPolizasAdapter legacy;

        public Polizas(DestinoServicioResolver destinos, ApiCanalPolizasRecibosAdapter apiCanal, LegacyPolizasAdapter legacy) {
            this.destinos = destinos; this.apiCanal = apiCanal; this.legacy = legacy;
        }
        private PolizasPort d() { return legacy(destinos, "polizas") ? legacy : apiCanal; }
        @Override public List<Poliza> porCliente(String id) { return d().porCliente(id); }
        @Override public Optional<Poliza> detalle(String n) { return d().detalle(n); }
        @Override public List<AccionPoliza> accionesPoliza(String n) { return d().accionesPoliza(n); }
        @Override public List<DocumentoPoliza> documentosPoliza(String n) { return d().documentosPoliza(n); }
        @Override public Optional<DetallePolizaRamo> detalleRamo(Poliza p) { return d().detalleRamo(p); }
        @Override public List<EstadoAnterior> estadosAnteriores(String id) { return d().estadosAnteriores(id); }
    }

    @Component @Primary @Profile("!local")
    public static class Recibos implements RecibosPort {
        private final DestinoServicioResolver destinos;
        private final ApiCanalPolizasRecibosAdapter apiCanal;
        private final LegacyRecibosAdapter legacy;

        public Recibos(DestinoServicioResolver destinos, ApiCanalPolizasRecibosAdapter apiCanal, LegacyRecibosAdapter legacy) {
            this.destinos = destinos; this.apiCanal = apiCanal; this.legacy = legacy;
        }
        private RecibosPort d() { return legacy(destinos, "recibos") ? legacy : apiCanal; }
        @Override public List<Recibo> porClienteRecibos(String id) { return d().porClienteRecibos(id); }
        @Override public Optional<Recibo> detalleRecibo(String n) { return d().detalleRecibo(n); }
        @Override public Optional<ReciboDetalle> detalleCompleto(String n) { return d().detalleCompleto(n); }
        @Override public DuplicadoRecibo duplicado(String n, String nuuma) { return d().duplicado(n, nuuma); }
    }

    /** Siniestros: API Canal Siniestros no publica la consulta por cliente; en ambos orígenes se usa negocioclientes/METS (legacy). */
    @Component @Primary @Profile("!local")
    public static class Siniestros implements SiniestrosPort {
        private final ApiCanalPolizasRecibosAdapter comun;
        public Siniestros(ApiCanalPolizasRecibosAdapter comun) { this.comun = comun; }
        @Override public List<Prestacion> porClientePrestaciones(String id) { return comun.porClientePrestaciones(id); }
        @Override public Optional<PrestacionDetalle> detallePrestacion(String n) { return comun.detallePrestacion(n); }
    }

    @Component @Primary @Profile("!local")
    public static class Ventas implements VentasPort {
        private final DestinoServicioResolver destinos;
        private final ApiCanalPolizasRecibosAdapter apiCanal;
        private final LegacyVentasAdapter legacy;

        public Ventas(DestinoServicioResolver destinos, ApiCanalPolizasRecibosAdapter apiCanal, LegacyVentasAdapter legacy) {
            this.destinos = destinos; this.apiCanal = apiCanal; this.legacy = legacy;
        }
        private VentasPort d() { return legacy(destinos, "ventas") ? legacy : apiCanal; }
        @Override public List<Presupuesto> presupuestosPorCliente(String id) { return d().presupuestosPorCliente(id); }
        @Override public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud s) { return d().tarificarSalud(s); }
    }
}
