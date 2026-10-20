package com.mapfre.pgm.bff.application;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import com.mapfre.pgm.bff.application.port.in.AuditoriaUseCase;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.application.port.out.ClientesPort.CriteriosBusqueda;
import com.mapfre.pgm.bff.application.service.BuscarClientesService;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class BuscarClientesServiceTest {

    private final ClientesPort port = mock(ClientesPort.class);
    private final AuditoriaUseCase auditoria = mock(AuditoriaUseCase.class);
    private final BuscarClientesService service = new BuscarClientesService(port, auditoria);

    @Test
    void rechazaBusquedaSinCriterios() {
        assertThatThrownBy(() -> service.buscar(new CriteriosBusqueda(null, "", null, null, null, null, null, 10), "u"))
                .isInstanceOf(IllegalArgumentException.class);
        verifyNoInteractions(port);
    }

    @Test
    void limitaResultadosYAudita() {
        when(port.buscar(any())).thenReturn(List.of());
        service.buscar(new CriteriosBusqueda("laura", null, null, null, null, null, null, 500), "u");
        ArgumentCaptor<CriteriosBusqueda> c = ArgumentCaptor.forClass(CriteriosBusqueda.class);
        verify(port).buscar(c.capture());
        org.assertj.core.api.Assertions.assertThat(c.getValue().limite()).isEqualTo(101);
        verify(auditoria).registrarAcceso("u", "BUSQUEDA_CLIENTES", null, "inicio");
    }

    @Test
    void aplicaLasValidacionesLiteralesDelBuscadorDePgm() {
        assertThatThrownBy(() -> service.buscar(c("J", null, null, null, null), "u"))
                .hasMessage("El nombre debe contener al menos 2 caracteres");
        assertThatThrownBy(() -> service.buscar(c("JOSE", "G", null, null, null), "u"))
                .hasMessage("El apellido debe contener al menos 2 caracteres");
        assertThatThrownBy(() -> service.buscar(c(null, "GARCIA", null, null, null), "u"))
                .hasMessage("Es necesario cumplimentar también el nombre o el segundo apellido");
        assertThatThrownBy(() -> service.buscar(c(null, null, "GARCIA", null, null), "u"))
                .hasMessage("Es necesario cumplimentar también el nombre o el primer apellido");
        assertThatThrownBy(() -> service.buscar(c(null, null, null, "noesemail", null), "u"))
                .hasMessage("Email no válido");
        assertThatThrownBy(() -> service.buscar(c(null, null, null, null, "123"), "u"))
                .hasMessage("Formato de número de teléfono inválido");
        verifyNoInteractions(port);
    }

    @Test
    void masDe100ResultadosEsExcesoDeResultados() {
        when(port.buscar(any())).thenReturn(java.util.stream.IntStream.range(0, 101)
                .mapToObj(n -> new com.mapfre.pgm.bff.domain.model.ClienteResumen("C-" + n, "N", "A", "NIF", "D" + n,
                        com.mapfre.pgm.bff.domain.model.Tipologia.PARTICULAR, com.mapfre.pgm.bff.domain.model.EstadoCliente.EN_VIGOR,
                        null, null, null, 0, null, null, null, false)).toList());
        assertThatThrownBy(() -> service.buscar(c("GARCIA", null, null, null, null), "u"))
                .isInstanceOf(com.mapfre.pgm.bff.domain.exception.DemasiadosResultadosException.class);
    }

    private static CriteriosBusqueda c(String nombre, String ap1, String ap2, String email, String telefono) {
        return new CriteriosBusqueda(nombre, null, telefono, email, null, null, null, 100, ap1, ap2, null, null, null, null, null);
    }
}
