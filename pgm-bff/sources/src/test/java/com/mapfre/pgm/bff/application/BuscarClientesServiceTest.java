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
        org.assertj.core.api.Assertions.assertThat(c.getValue().limite()).isEqualTo(50);
        verify(auditoria).registrarAcceso("u", "BUSQUEDA_CLIENTES", null, "inicio");
    }
}
