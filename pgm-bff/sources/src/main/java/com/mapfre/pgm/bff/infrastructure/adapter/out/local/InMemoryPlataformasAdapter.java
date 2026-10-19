package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.*;
import com.mapfre.pgm.bff.domain.model.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Simula en local las APIs de plataforma (PGO, SGC 3.0, iMediador, SGO, comunicaciones) y API Canal
 * Siniestros/Ventas. Un único componente para mantener el perfil local pequeño; en entornos reales cada
 * puerto tiene su adaptador HTTP en {@code adapter.out.apicanal}.
 */
@Component
@Profile("local")
public class InMemoryPlataformasAdapter implements SiniestrosPort, VentasPort, OportunidadesPort,
        GestionComercialPort, SgoPort, ComunicacionesPort, BorradoresPort {

    private record UsuarioLocal(String perfilSgc30, EstructuraComercial estructura) {}

    private final List<Prestacion> prestaciones;
    private final List<Presupuesto> presupuestos;
    private final List<Oportunidad> oportunidades;
    private final List<GestionComercial> gestiones;
    private final List<SolicitudSgo> solicitudes;
    private final Map<String, UsuarioLocal> usuarios;
    private final Map<String, TarificacionSalud.Solicitud> borradores = new ConcurrentHashMap<>();

    public InMemoryPlataformasAdapter(ObjectMapper mapper) {
        prestaciones = LocalDataLoader.load(mapper, "prestaciones.json", new TypeReference<>() {});
        presupuestos = LocalDataLoader.load(mapper, "presupuestos.json", new TypeReference<>() {});
        oportunidades = LocalDataLoader.load(mapper, "oportunidades.json", new TypeReference<>() {});
        gestiones = LocalDataLoader.load(mapper, "gestiones.json", new TypeReference<>() {});
        solicitudes = LocalDataLoader.load(mapper, "sgo.json", new TypeReference<>() {});
        usuarios = LocalDataLoader.load(mapper, "usuarios.json", new TypeReference<>() {});
    }

    @Override
    public List<Prestacion> porClientePrestaciones(String clienteId) {
        return prestaciones.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public List<Presupuesto> presupuestosPorCliente(String clienteId) {
        return presupuestos.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud s) {
        BigDecimal base = s.edades().stream()
                .map(e -> BigDecimal.valueOf(28 + Math.max(0, e - 18) * 1.35 + (e > 60 ? 40 : 0)))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (s.copago()) {
            base = base.multiply(BigDecimal.valueOf(0.82));
        }
        BigDecimal mensual = base.setScale(2, RoundingMode.HALF_UP);
        return new TarificacionSalud.Resultado(UUID.randomUUID().toString(), s.producto(), mensual,
                mensual.multiply(BigDecimal.valueOf(12)).setScale(2, RoundingMode.HALF_UP),
                List.of("Asistencia primaria", "Especialistas", "Hospitalización", "Urgencias 24h"), "SIMULADA");
    }

    @Override
    public List<Oportunidad> porClienteOportunidades(String clienteId) {
        return oportunidades.stream().filter(o -> o.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public List<GestionComercial> gestionesPorCliente(String clienteId) {
        return gestiones.stream().filter(g -> g.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public Optional<EstructuraComercial> estructuraDe(String usuario) {
        return Optional.ofNullable(usuarios.get(usuario)).map(UsuarioLocal::estructura);
    }

    @Override
    public Optional<String> perfilSgc30De(String usuario) {
        return Optional.ofNullable(usuarios.get(usuario)).map(UsuarioLocal::perfilSgc30);
    }

    @Override
    public List<SolicitudSgo> solicitudesPorCliente(String clienteId) {
        return solicitudes.stream().filter(s -> s.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public String iniciarLlamada(String clienteId, String telefono, String usuario) {
        return "LLAMADA-" + UUID.randomUUID();
    }

    @Override
    public String guardar(String usuario, TarificacionSalud.Solicitud solicitud) {
        String id = UUID.randomUUID().toString();
        borradores.put(usuario + "/" + id, solicitud);
        return id;
    }

    @Override
    public Optional<TarificacionSalud.Solicitud> recuperar(String usuario, String id) {
        return Optional.ofNullable(borradores.get(usuario + "/" + id));
    }
}
