package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.in.BuscarClientesUseCase;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.application.port.out.ClientesPort.CriteriosBusqueda;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class BuscarClientesService implements BuscarClientesUseCase {

    static final int LIMITE_MAXIMO = 50;

    private final ClientesPort clientesPort;
    private final AuditoriaUseCase auditoria;

    public BuscarClientesService(ClientesPort clientesPort, AuditoriaUseCase auditoria) {
        this.clientesPort = clientesPort;
        this.auditoria = auditoria;
    }

    @Override
    public List<ClienteResumen> buscar(CriteriosBusqueda criterios, String usuario) {
        if (criterios.estaVacio()) {
            throw new IllegalArgumentException("Indique al menos un criterio de búsqueda");
        }
        int limite = criterios.limite() <= 0 ? LIMITE_MAXIMO : Math.min(criterios.limite(), LIMITE_MAXIMO);
        List<ClienteResumen> resultado = clientesPort.buscar(new CriteriosBusqueda(
                criterios.texto(), criterios.documento(), criterios.telefono(), criterios.email(),
                criterios.poliza(), criterios.tarjetaSanitaria(), criterios.localidad(), limite));
        auditoria.registrarAcceso(usuario, "BUSQUEDA_CLIENTES", null, "inicio");
        return resultado;
    }
}
