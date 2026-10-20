package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.*;
import com.mapfre.pgm.bff.domain.model.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.stream.Stream;
import java.time.LocalDateTime;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.application.port.out.BorradoresPort;
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
        GestionComercialPort, UsuariosComercialesPort, SgoPort, ComunicacionesPort, BorradoresPort {

    private record UsuarioLocal(String perfilSgc30, EstructuraComercial estructura) {}

    private final List<Prestacion> prestaciones;
    private final List<Presupuesto> presupuestos;
    private final List<Oportunidad> oportunidades;
    private final List<GestionComercial> gestiones;
    private final List<SolicitudSgo> solicitudes;
    private final List<ActividadComercial> actividades;
    private final Map<String, List<Observacion>> observaciones = new ConcurrentHashMap<>();
    private final List<Oportunidad> oportunidadesCreadas = new CopyOnWriteArrayList<>();
    private final Map<String, GestionComercial> gestionesModificadas = new ConcurrentHashMap<>();
    private final Map<String, UsuarioLocal> usuarios;
    private final Map<String, TarificacionSalud.Solicitud> borradores = new ConcurrentHashMap<>();

    public InMemoryPlataformasAdapter(ObjectMapper mapper) {
        prestaciones = LocalDataLoader.load(mapper, "prestaciones.json", new TypeReference<>() {});
        presupuestos = LocalDataLoader.load(mapper, "presupuestos.json", new TypeReference<>() {});
        oportunidades = LocalDataLoader.load(mapper, "oportunidades.json", new TypeReference<>() {});
        gestiones = LocalDataLoader.load(mapper, "gestiones.json", new TypeReference<>() {});
        solicitudes = LocalDataLoader.load(mapper, "sgo.json", new TypeReference<>() {});
        actividades = new CopyOnWriteArrayList<>(LocalDataLoader.load(mapper, "actividad.json", new TypeReference<List<ActividadComercial>>() {}));
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
        return Stream.concat(oportunidades.stream(), oportunidadesCreadas.stream())
                .filter(o -> o.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public ResumenOportunidades resumen(String clienteId) {
        List<Oportunidad> l = porClienteOportunidades(clienteId);
        int completos = (int) l.stream().filter(o -> o.clase() == Oportunidad.Clase.COMPLETO).count();
        int incompletos = (int) l.stream().filter(o -> o.clase() != Oportunidad.Clase.COMPLETO).count();
        int pptos = (int) presupuestos.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId)).count();
        return new ResumenOportunidades(l.size(), completos, incompletos, pptos);
    }

    @Override
    public Optional<OportunidadDetalle> detalle(String oportunidadId) {
        return Stream.concat(oportunidades.stream(), oportunidadesCreadas.stream())
                .filter(o -> o.id().equals(oportunidadId)).findFirst()
                .map(o -> new OportunidadDetalle(o,
                        new LinkedHashMap<>(Map.of("Fecha de vencimiento", String.valueOf(o.fecha()),
                                "Entidad competencia", o.entidadCompetencia() == null ? "-" : o.entidadCompetencia(),
                                "Clase de vencimiento", o.clase() == null ? "-" : o.clase().name())),
                        new LinkedHashMap<>(Map.of("Producto", o.ramo().name(), "Prima / Saldo", o.prima() == null ? "-" : o.prima().toPlainString())),
                        new LinkedHashMap<>(Map.of("Riesgo", o.descripcion() == null ? "-" : o.descripcion())),
                        observaciones.getOrDefault(o.id(), List.of()),
                        List.of()));
    }

    @Override
    public Oportunidad crear(AltaOportunidad alta, String nuuma) {
        Oportunidad o = new Oportunidad("O-" + UUID.randomUUID().toString().substring(0, 8), alta.clienteId(),
                alta.tipo() == null ? Oportunidad.Tipo.VENCIMIENTO : alta.tipo(), alta.ramo(), null, alta.fecha(),
                alta.comentarios(), Oportunidad.Prioridad.MEDIA, Oportunidad.Clase.INCOMPLETO, nuuma,
                alta.entidadCompetencia(), alta.prima(), alta.comentarios(), 0, false);
        oportunidadesCreadas.add(o);
        return o;
    }

    @Override
    public Observacion anadirObservacion(String oportunidadId, String texto, String nuuma) {
        Observacion obs = new Observacion(UUID.randomUUID().toString(), LocalDateTime.now(), LocalDateTime.now(), texto, nuuma);
        observaciones.computeIfAbsent(oportunidadId, k -> new CopyOnWriteArrayList<>()).add(obs);
        return obs;
    }

    @Override
    public void eliminarObservacion(String oportunidadId, String observacionId, String nuuma) {
        observaciones.getOrDefault(oportunidadId, new CopyOnWriteArrayList<>()).removeIf(o -> o.id().equals(observacionId));
    }

    @Override
    public List<GestionComercial> gestionesPorCliente(String clienteId) {
        return gestiones.stream().filter(g -> g.clienteId().equalsIgnoreCase(clienteId))
                .map(g -> gestionesModificadas.getOrDefault(g.id(), g)).toList();
    }

    @Override
    public Optional<GestionDetalle> detalleGestion(String gestionId, String nuuma) {
        return gestiones.stream().filter(g -> g.id().equals(gestionId)).findFirst()
                .map(g -> gestionesModificadas.getOrDefault(g.id(), g))
                .map(g -> new GestionDetalle(g, "Media", g.gestor(), List.of("600000001"), "cliente@correo.invalid",
                        observaciones.getOrDefault("G/" + g.id(), List.of()), List.of(),
                        actividades.stream().filter(a -> a.clienteId().equalsIgnoreCase(g.clienteId())).toList()));
    }

    @Override
    public GestionComercial cerrarGestion(String gestionId, String resultado, String nuuma) {
        GestionComercial g = gestiones.stream().filter(x -> x.id().equals(gestionId)).findFirst()
                .map(x -> gestionesModificadas.getOrDefault(x.id(), x))
                .orElseThrow(() -> new RecursoNoEncontradoException("Gestión", gestionId));
        GestionComercial cerrada = new GestionComercial(g.id(), g.clienteId(), g.tipo(),
                "NEGATIVA".equalsIgnoreCase(resultado) ? "CERRADA_NEGATIVA" : "CERRADA_POSITIVA", g.fecha(), g.descripcion(),
                g.gestor(), g.origen(), g.fechaCaducidad(), g.probabilidadConversion(), g.agendado(), g.whatsapp(), g.permisos());
        gestionesModificadas.put(g.id(), cerrada);
        return cerrada;
    }

    @Override
    public GestionComercial reabrirGestion(String gestionId, String nuuma) {
        GestionComercial g = gestiones.stream().filter(x -> x.id().equals(gestionId)).findFirst()
                .map(x -> gestionesModificadas.getOrDefault(x.id(), x))
                .orElseThrow(() -> new RecursoNoEncontradoException("Gestión", gestionId));
        GestionComercial abierta = new GestionComercial(g.id(), g.clienteId(), g.tipo(), "ABIERTA", g.fecha(), g.descripcion(),
                g.gestor(), g.origen(), g.fechaCaducidad(), g.probabilidadConversion(), g.agendado(), g.whatsapp(), g.permisos());
        gestionesModificadas.put(g.id(), abierta);
        return abierta;
    }

    @Override
    public Observacion anadirObservacionGestion(String gestionId, String texto, String nuuma) {
        Observacion obs = new Observacion(UUID.randomUUID().toString(), LocalDateTime.now(), LocalDateTime.now(), texto, nuuma);
        observaciones.computeIfAbsent("G/" + gestionId, k -> new CopyOnWriteArrayList<>()).add(obs);
        return obs;
    }

    @Override
    public List<ActividadComercial> actividadComercial(String clienteId, String nuuma) {
        return actividades.stream().filter(a -> a.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public ActividadComercial crearActividad(AltaActividad alta, String nuuma) {
        ActividadComercial a = new ActividadComercial("A-" + UUID.randomUUID().toString().substring(0, 8), alta.clienteId(),
                LocalDateTime.now(), alta.nivelGestion(), nuuma, "Nueva actividad", "NGA", alta.comentario(),
                alta.polizaNumero(), null);
        actividades.add(a);
        return a;
    }

    @Override
    public CatalogoComercial catalogo(CatalogoComercial.Tipo tipo, String estructura) {
        List<CatalogoComercial.Item> items = switch (tipo) {
            case ACCIONES -> List.of(new CatalogoComercial.Item("LLAMADA", "Llamada"), new CatalogoComercial.Item("VISITA", "Visita"),
                    new CatalogoComercial.Item("EMAIL", "Email"), new CatalogoComercial.Item("WHATSAPP", "WhatsApp"));
            case NIVELES_GESTION -> List.of(new CatalogoComercial.Item("1", "Contactado"), new CatalogoComercial.Item("2", "Interesado"),
                    new CatalogoComercial.Item("3", "Presupuestado"), new CatalogoComercial.Item("8", "Contratado"),
                    new CatalogoComercial.Item("9", "No interesado"));
            case COMPANIAS -> List.of(new CatalogoComercial.Item("ALLIANZ", "Allianz"), new CatalogoComercial.Item("AXA", "AXA"),
                    new CatalogoComercial.Item("MUTUA", "Mutua Madrileña"), new CatalogoComercial.Item("OTRA", "Otra"));
        };
        return new CatalogoComercial(tipo, items);
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
    public Optional<SolicitudSgoDetalle> detalleSolicitud(String solicitudId) {
        return solicitudes.stream().filter(s -> s.id().equals(solicitudId)).findFirst()
                .map(s -> new SolicitudSgoDetalle(s,
                        new LinkedHashMap<>(Map.of("Tipo", s.tipo(), "Estado", s.estado(), "Fecha", String.valueOf(s.fecha()))),
                        documentosSolicitud(solicitudId)));
    }

    @Override
    public List<DocumentoAdjunto> documentosSolicitud(String solicitudId) {
        return solicitudes.stream().anyMatch(s -> s.id().equals(solicitudId))
                ? List.of(new DocumentoAdjunto(solicitudId + "-D1", "Solicitud firmada.pdf", "application/pdf",
                        LocalDateTime.of(2026, 9, 1, 10, 0), "SGO"))
                : List.of();
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

    @Override
    public List<BorradoresPort.Borrador> listar(String usuario) {
        String prefijo = usuario + "/";
        return borradores.entrySet().stream().filter(e -> e.getKey().startsWith(prefijo))
                .map(e -> new BorradoresPort.Borrador(e.getKey().substring(prefijo.length()), e.getValue())).toList();
    }

    @Override
    public boolean eliminar(String usuario, String id) {
        return borradores.remove(usuario + "/" + id) != null;
    }
}
