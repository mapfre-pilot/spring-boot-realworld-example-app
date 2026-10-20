package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.BuscarClientesUseCase;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.domain.exception.DemasiadosResultadosException;
import com.mapfre.pgm.bff.application.port.out.ClientesPort.CriteriosBusqueda;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class BuscarClientesService implements BuscarClientesUseCase {

    static final int LIMITE_MAXIMO = 100;

    private final ClientesPort clientesPort;
    private final AuditoriaUseCase auditoria;

    public BuscarClientesService(ClientesPort clientesPort, AuditoriaUseCase auditoria) {
        this.clientesPort = clientesPort;
        this.auditoria = auditoria;
    }

    @Override
    public List<ClienteResumen> buscar(CriteriosBusqueda c, String usuario) {
        if (c.estaVacio()) {
            throw new IllegalArgumentException("Indique al menos un criterio de búsqueda");
        }
        validar(c);
        int limite = c.limite() <= 0 ? LIMITE_MAXIMO : Math.min(c.limite(), LIMITE_MAXIMO);
        List<ClienteResumen> resultado = clientesPort.buscar(new CriteriosBusqueda(
                c.texto(), c.documento(), c.telefono(), c.email(), c.poliza(), c.tarjetaSanitaria(), c.localidad(), limite + 1,
                c.primerApellido(), c.segundoApellido(), c.codigoPostal(), c.expediente(), c.matricula(), c.presupuesto(), c.recibo()));
        auditoria.registrarAcceso(usuario, "BUSQUEDA_CLIENTES", null, "inicio");
        if (resultado.size() > limite) {
            throw new DemasiadosResultadosException();
        }
        return resultado;
    }

    /** Reglas de PGM_EsValidaBusquedaCliente / PGM_ValidaEmail con sus textos literales. */
    static void validar(CriteriosBusqueda c) {
        boolean hayNombre = !esBlanco(c.texto());
        boolean hayApellido1 = !esBlanco(c.primerApellido());
        boolean hayApellido2 = !esBlanco(c.segundoApellido());
        if (hayNombre && c.texto().trim().length() < 2) {
            throw new IllegalArgumentException("El nombre debe contener al menos 2 caracteres");
        }
        if ((hayApellido1 && c.primerApellido().trim().length() < 2) || (hayApellido2 && c.segundoApellido().trim().length() < 2)) {
            throw new IllegalArgumentException("El apellido debe contener al menos 2 caracteres");
        }
        if (hayApellido1 && !hayNombre && !hayApellido2) {
            throw new IllegalArgumentException("Es necesario cumplimentar también el nombre o el segundo apellido");
        }
        if (hayApellido2 && !hayNombre && !hayApellido1) {
            throw new IllegalArgumentException("Es necesario cumplimentar también el nombre o el primer apellido");
        }
        if (!esBlanco(c.email()) && !c.email().matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            throw new IllegalArgumentException("Email no válido");
        }
        if (!esBlanco(c.telefono()) && !c.telefono().replaceAll("[\\s-]", "").matches("^\\+?\\d{9,15}$")) {
            throw new IllegalArgumentException("Formato de número de teléfono inválido");
        }
        if (!esBlanco(c.poliza()) && !c.poliza().matches("^[A-Za-z0-9/-]{4,20}$")) {
            throw new IllegalArgumentException("Formato de número de póliza inválido");
        }
    }

    private static boolean esBlanco(String v) {
        return v == null || v.isBlank();
    }
}
