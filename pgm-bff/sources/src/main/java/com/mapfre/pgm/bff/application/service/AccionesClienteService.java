package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AccionesClienteUseCase;
import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.out.AccionesClientePort;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.domain.exception.RecursoNoEncontradoException;
import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import com.mapfre.pgm.bff.domain.model.Cliente;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Service;

/**
 * Reglas literales observadas en PGM (TEST, área A): ACI exige móvil o email; la firma RGPD por SMS/email se deshabilita
 * sin móvil/email; la inducción exige teléfono/email y cliente no Robinson; el periodo de comunicaciones es 30D | 12M | 3A.
 */
@Service
public class AccionesClienteService implements AccionesClienteUseCase {

    static final String MSG_ACI_SIN_CONTACTO =
            "Para solicitar el alta en ACI el cliente debe tener informado un teléfono móvil o un email";
    static final String MSG_ROBINSON = "Mensaje cliente robinson: el cliente está en la lista Robinson y no admite comunicaciones comerciales";
    static final String MSG_INDUCCION_SIN_CONTACTO = "Para inducir al cliente es necesario un teléfono o un email de contacto";
    static final String MSG_YA_ACI = "El cliente ya está dado de alta en ACI";
    static final String MSG_RGPD_FIRMADO = "El cliente ya tiene la cláusula RGPD firmada";
    private static final Set<String> PERIODOS = Set.of("30D", "12M", "3A");
    private static final Set<String> TIPOS_PLAN = Set.of("INDIVIDUAL", "FAMILIAR");

    private final AccionesClientePort acciones;
    private final ClientesPort clientes;
    private final AuditoriaUseCase auditoria;

    public AccionesClienteService(AccionesClientePort acciones, ClientesPort clientes, AuditoriaUseCase auditoria) {
        this.acciones = acciones;
        this.clientes = clientes;
        this.auditoria = auditoria;
    }

    private Cliente cliente(String id) {
        return clientes.ficha(id).orElseThrow(() -> new RecursoNoEncontradoException("cliente", id));
    }

    private static boolean tieneContacto(Cliente c) {
        return (c.telefono() != null && !c.telefono().isBlank()) || (c.email() != null && !c.email().isBlank());
    }

    @Override
    public MasDatos masDatos(String clienteId, String usuario) {
        cliente(clienteId);
        auditoria.registrarAcceso(usuario, "MAS_DATOS", clienteId, "mas-datos-cliente");
        return acciones.masDatos(clienteId).orElseThrow(() -> new RecursoNoEncontradoException("mas-datos", clienteId));
    }

    @Override
    public MasDatos actualizarContacto(String clienteId, ContactoActualizado contacto, String usuario) {
        cliente(clienteId);
        if (contacto == null || ((contacto.telefonos() == null || contacto.telefonos().isEmpty())
                && (contacto.emails() == null || contacto.emails().isEmpty()))) {
            throw new IllegalArgumentException("Debe informarse al menos un teléfono o un email");
        }
        if (contacto.emails() != null && contacto.emails().stream().anyMatch(e -> !e.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$"))) {
            throw new IllegalArgumentException("Email no válido");
        }
        if (contacto.telefonos() != null && contacto.telefonos().stream()
                .anyMatch(t -> t.numero() == null || !t.numero().matches("^\\d{9}$"))) {
            throw new IllegalArgumentException("Formato de número de teléfono inválido");
        }
        auditoria.registrarAcceso(usuario, "MODIFICAR_CONTACTO", clienteId, "mas-datos-cliente");
        return acciones.actualizarContacto(clienteId, contacto, usuario);
    }

    @Override
    public Comunicaciones comunicaciones(String clienteId, String periodo, String usuario) {
        cliente(clienteId);
        String p = periodo == null ? "30D" : periodo.toUpperCase();
        if (!PERIODOS.contains(p)) {
            throw new IllegalArgumentException("Periodo no válido: se admite 30D, 12M o 3A");
        }
        auditoria.registrarAcceso(usuario, "CENTRO_COMUNICACIONES", clienteId, "centro-comunicaciones");
        return acciones.comunicaciones(clienteId, p);
    }

    @Override
    public List<DocumentoCliente> documentos(String clienteId, String tipo, String usuario) {
        cliente(clienteId);
        auditoria.registrarAcceso(usuario, "CDD_CONSULTA", clienteId, "consulta-descarga-documentacion");
        return acciones.documentos(clienteId, tipo);
    }

    @Override
    public ResultadoAccion solicitarDigitalizacionDni(String clienteId, String canal, String usuario) {
        Cliente c = cliente(clienteId);
        if (c.palancas() != null && c.palancas().dniDigitalizado()) {
            throw new IllegalArgumentException("El cliente ya tiene la documentación digitalizada");
        }
        auditoria.registrarAcceso(usuario, "DIGITALIZAR_DNI", clienteId, "digitalizar-dni");
        return acciones.solicitarDigitalizacionDni(clienteId, canal == null ? "CAPTURA_WEB" : canal, usuario);
    }

    @Override
    public FirmaRgpd metodosFirmaRgpd(String clienteId, String usuario) {
        Cliente c = cliente(clienteId);
        FirmaRgpd base = acciones.metodosFirmaRgpd(clienteId);
        boolean movil = c.telefono() != null && !c.telefono().isBlank();
        boolean email = c.email() != null && !c.email().isBlank();
        List<MetodoFirma> metodos = base.metodos().stream().map(m -> switch (m.codigo()) {
            case "SMS" -> new MetodoFirma(m.codigo(), m.nombre(), m.disponible() && movil);
            case "EMAIL" -> new MetodoFirma(m.codigo(), m.nombre(), m.disponible() && email);
            default -> m;
        }).toList();
        return new FirmaRgpd(metodos, c.palancas() != null && c.palancas().rgpdFirmado() ? "FIRMADA" : base.estado());
    }

    @Override
    public ResultadoAccion firmarRgpd(String clienteId, String metodo, String usuario) {
        Cliente c = cliente(clienteId);
        if (c.palancas() != null && c.palancas().rgpdFirmado()) {
            throw new IllegalArgumentException(MSG_RGPD_FIRMADO);
        }
        FirmaRgpd disponibles = metodosFirmaRgpd(clienteId, usuario);
        boolean ok = disponibles.metodos().stream().anyMatch(m -> m.codigo().equalsIgnoreCase(metodo) && m.disponible());
        if (!ok) {
            throw new IllegalArgumentException("El método de firma «" + metodo + "» no está disponible para este cliente");
        }
        auditoria.registrarAcceso(usuario, "FIRMAR_RGPD", clienteId, "firma-rgpd");
        return acciones.firmarRgpd(clienteId, metodo.toUpperCase(), usuario);
    }

    @Override
    public ResultadoAccion altaAci(String clienteId, String usuario) {
        Cliente c = cliente(clienteId);
        if (c.palancas() != null && c.palancas().altaAci()) {
            throw new IllegalArgumentException(MSG_YA_ACI);
        }
        if (!tieneContacto(c)) {
            throw new IllegalArgumentException(MSG_ACI_SIN_CONTACTO);
        }
        auditoria.registrarAcceso(usuario, "ALTA_ACI", clienteId, "alta-aci");
        return acciones.altaAci(clienteId, usuario);
    }

    @Override
    public ClienteTotal clienteTotal(String clienteId, String usuario) {
        cliente(clienteId);
        auditoria.registrarAcceso(usuario, "CLIENTE_TOTAL", clienteId, "alta-cliente-total");
        return acciones.clienteTotal(clienteId).orElseThrow(() -> new RecursoNoEncontradoException("cliente-total", clienteId));
    }

    @Override
    public ClienteTotal anadirEmpresaVinculada(String clienteId, EmpresaVinculada empresa, String usuario) {
        cliente(clienteId);
        if (empresa == null || empresa.cif() == null || !empresa.cif().matches("^[A-HJNP-SUVW]\\d{7}[0-9A-J]$")) {
            throw new IllegalArgumentException("CIF de la empresa no válido");
        }
        auditoria.registrarAcceso(usuario, "CLIENTE_TOTAL_EMPRESA", clienteId, "alta-cliente-total");
        return acciones.anadirEmpresaVinculada(clienteId, empresa, usuario);
    }

    @Override
    public PlanPagos planPagos(String clienteId, String usuario) {
        cliente(clienteId);
        return acciones.planPagos(clienteId);
    }

    @Override
    public SimulacionPlanPagos simularPlanPagos(String clienteId, String tipo, String usuario) {
        cliente(clienteId);
        String t = tipo == null ? "INDIVIDUAL" : tipo.toUpperCase();
        if (!TIPOS_PLAN.contains(t)) {
            throw new IllegalArgumentException("Tipo de plan de pagos no válido: INDIVIDUAL o FAMILIAR");
        }
        PlanPagos plan = acciones.planPagos(clienteId);
        if (!plan.susceptible() || (t.equals("INDIVIDUAL") && !plan.individualDisponible())
                || (t.equals("FAMILIAR") && !plan.familiarDisponible())) {
            throw new IllegalArgumentException(plan.mensaje() != null ? plan.mensaje()
                    : "El cliente no es susceptible de plan de pagos " + t.toLowerCase());
        }
        auditoria.registrarAcceso(usuario, "SIMULAR_PLAN_PAGOS", clienteId, "plan-pagos");
        return acciones.simularPlanPagos(clienteId, t, usuario);
    }

    @Override
    public ResultadoAccion inducir(String clienteId, String canal, String usuario) {
        Cliente c = cliente(clienteId);
        if (c.robinson()) {
            throw new IllegalArgumentException(MSG_ROBINSON);
        }
        if (!tieneContacto(c)) {
            throw new IllegalArgumentException(MSG_INDUCCION_SIN_CONTACTO);
        }
        auditoria.registrarAcceso(usuario, "INDUCIR", clienteId, "induccion");
        return acciones.inducir(clienteId, canal == null ? "WEB" : canal, usuario);
    }
}
