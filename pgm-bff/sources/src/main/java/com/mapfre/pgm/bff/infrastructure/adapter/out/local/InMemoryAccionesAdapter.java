package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.mapfre.pgm.bff.application.port.out.AccionesClientePort;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.EstadoCliente;
import com.mapfre.pgm.bff.domain.model.Tipologia;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Simula las acciones de cabecera (Clients API/EDGE, consentimientos, ACI, DPVE, Cliente Total) con datos sintéticos en memoria. */
@Component
@Profile("local")
public class InMemoryAccionesAdapter implements AccionesClientePort {

    private final ClientesPort clientes;
    private final Map<String, ContactoActualizado> contactos = new ConcurrentHashMap<>();
    private final Map<String, List<EmpresaVinculada>> empresas = new ConcurrentHashMap<>();

    public InMemoryAccionesAdapter(ClientesPort clientes) {
        this.clientes = clientes;
    }

    private Optional<Cliente> cliente(String id) {
        return clientes.ficha(id);
    }

    @Override
    public Optional<MasDatos> masDatos(String clienteId) {
        return cliente(clienteId).map(c -> {
            ContactoActualizado ct = contactos.getOrDefault(clienteId, new ContactoActualizado(
                    c.telefono() == null ? List.of() : List.of(new Telefono("MOVIL", "PERSONAL", "+34", c.telefono())),
                    c.email() == null ? List.of() : List.of(c.email())));
            Integer edad = c.fechaNacimiento() == null ? null : Period.between(c.fechaNacimiento(), LocalDate.now()).getYears();
            return new MasDatos(c.nacionalidad(), "Castellano", c.fechaNacimiento(), edad,
                    c.tipologia() == Tipologia.EMPRESA ? null : "No informado", 0,
                    c.tipologia() == Tipologia.EMPRESA ? "Jurídica" : "Física", "No informado", false,
                    c.tipologia() == Tipologia.AUTONOMO ? "Autónomo" : "No informado",
                    ct.telefonos(), ct.emails(),
                    Map.of("Datos personales", "Contratación", "Datos de contacto", "Cliente", "Consentimientos", "Firma RGPD"),
                    c.robinson() ? List.of("Cliente en lista Robinson") : List.of());
        });
    }

    @Override
    public MasDatos actualizarContacto(String clienteId, ContactoActualizado contacto, String usuario) {
        contactos.put(clienteId, contacto);
        return masDatos(clienteId).orElseThrow();
    }

    @Override
    public Comunicaciones comunicaciones(String clienteId, String periodo) {
        LocalDateTime base = LocalDateTime.now().minusDays(3);
        Cliente c = cliente(clienteId).orElse(null);
        List<Interaccion> interacciones = List.of(
                new Interaccion("I-" + clienteId + "-1", base, "TELEFONO", "Consulta recibo", "El cliente consulta el estado de un recibo", "CERRADA"),
                new Interaccion("I-" + clienteId + "-2", base.minusDays(40), "OFICINA", "Cambio de datos", "Actualización de teléfono", "CERRADA"),
                new Interaccion("I-" + clienteId + "-3", base.minusDays(400), "WEB", "Petición de información", "Solicitud presupuesto Hogar", "CERRADA"));
        List<Interaccion> reclamaciones = List.of(
                new Interaccion("R-" + clienteId + "-1", base.minusDays(200), "ESCRITO", "Reclamación siniestro", "Disconformidad con la valoración", "RESUELTA"));
        int dias = switch (periodo) { case "12M" -> 365; case "3A" -> 1095; default -> 30; };
        LocalDateTime desde = LocalDateTime.now().minusDays(dias);
        return new Comunicaciones(c == null ? List.of() : c.alertas(),
                interacciones.stream().filter(i -> i.fecha().isAfter(desde)).toList(),
                reclamaciones.stream().filter(i -> i.fecha().isAfter(desde)).toList(), periodo);
    }

    @Override
    public List<DocumentoCliente> documentos(String clienteId, String tipo) {
        List<DocumentoCliente> docs = List.of(
                new DocumentoCliente("D-" + clienteId + "-1", "DNI", "DNI", "DNI anverso y reverso", LocalDate.of(2023, 5, 10), LocalDate.of(2033, 5, 10), "Alto", "Identificación", null, null),
                new DocumentoCliente("D-" + clienteId + "-2", "RGPD", "CLAUSULA", "Cláusula RGPD firmada", LocalDate.of(2024, 1, 15), null, "Alto", "Consentimiento", null, "RGPD-2024"),
                new DocumentoCliente("D-" + clienteId + "-3", "CONTRATO", "POLIZA", "Condiciones particulares", LocalDate.of(2024, 3, 1), LocalDate.of(2025, 3, 1), "Medio", "Contrato", "P-2001", null));
        return tipo == null ? docs : docs.stream().filter(d -> d.tipoDocumento().equalsIgnoreCase(tipo)).toList();
    }

    @Override
    public ResultadoAccion solicitarDigitalizacionDni(String clienteId, String canal, String usuario) {
        return new ResultadoAccion("SOLICITADA", "Se ha iniciado la captura de documentación por " + canal, "DNI-" + UUID.randomUUID().toString().substring(0, 8));
    }

    @Override
    public FirmaRgpd metodosFirmaRgpd(String clienteId) {
        return new FirmaRgpd(List.of(
                new MetodoFirma("BIOMETRICA", "Firma biométrica en tableta", true),
                new MetodoFirma("EMAIL", "Firma digital por email", true),
                new MetodoFirma("SMS", "Firma digital por SMS", true),
                new MetodoFirma("IMPRESION", "Impresión y firma manuscrita", true)), "PENDIENTE");
    }

    @Override
    public ResultadoAccion firmarRgpd(String clienteId, String metodo, String usuario) {
        return new ResultadoAccion("ENVIADA", "Solicitud de firma RGPD enviada por " + metodo, "RGPD-" + UUID.randomUUID().toString().substring(0, 8));
    }

    @Override
    public ResultadoAccion altaAci(String clienteId, String usuario) {
        return new ResultadoAccion("SOLICITADA", "Alta en ACI solicitada; el cliente recibirá un enlace de activación", "ACI-" + UUID.randomUUID().toString().substring(0, 8));
    }

    @Override
    public Optional<ClienteTotal> clienteTotal(String clienteId) {
        return cliente(clienteId).map(c -> {
            List<EmpresaVinculada> lista = empresas.getOrDefault(clienteId, List.of());
            boolean total = c.palancas() != null && c.palancas().clienteTotal();
            return new ClienteTotal(c.documento(), c.nombreCompleto(), total ? "Cliente Total" : "Cliente",
                    total ? null : "Cliente Total", lista, !lista.isEmpty() && !total);
        });
    }

    @Override
    public ClienteTotal anadirEmpresaVinculada(String clienteId, EmpresaVinculada empresa, String usuario) {
        List<EmpresaVinculada> lista = new ArrayList<>(empresas.getOrDefault(clienteId, List.of()));
        lista.add(new EmpresaVinculada(empresa.cif(), empresa.razonSocial(), empresa.actividad(), empresa.segmento(),
                empresa.clasificacion(), empresa.cargo(), "PENDIENTE_FIRMA"));
        empresas.put(clienteId, lista);
        return clienteTotal(clienteId).orElseThrow();
    }

    @Override
    public PlanPagos planPagos(String clienteId) {
        Cliente c = cliente(clienteId).orElse(null);
        boolean potencial = c != null && c.estado() == EstadoCliente.POTENCIAL;
        boolean ya = c != null && c.palancas() != null && c.palancas().planPagos();
        if (potencial) return new PlanPagos(false, false, false, "El cliente potencial no es susceptible de plan de pagos");
        if (ya) return new PlanPagos(false, false, false, "El cliente ya tiene un plan de pagos contratado");
        boolean familia = c != null && c.familia() != null && c.familia().size() > 1;
        return new PlanPagos(true, true, familia, null);
    }

    @Override
    public SimulacionPlanPagos simularPlanPagos(String clienteId, String tipo, String usuario) {
        List<String> productos = clientes.ficha(clienteId).map(c -> List.of("Autos", "Hogar")).orElse(List.of());
        return new SimulacionPlanPagos(tipo, tipo.equals("FAMILIAR") ? new BigDecimal("148.20") : new BigDecimal("96.75"), 12, productos);
    }

    @Override
    public ResultadoAccion inducir(String clienteId, String canal, String usuario) {
        return new ResultadoAccion("ENVIADA", "Inducción enviada por " + canal, "IND-" + UUID.randomUUID().toString().substring(0, 8));
    }
}
