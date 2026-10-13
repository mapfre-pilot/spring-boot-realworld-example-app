package com.mapfre.vida.vencimientosmanuales.application;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.BusquedaExpedientes;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt04Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt04Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.VtRequest;
import com.mapfre.vida.vencimientosmanuales.application.service.VencimientosApplicationService;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.CALLS_REAL_METHODS;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class VencimientosApplicationServiceTest {
    @Test
    void busquedaOrquestaVT04YVT08ConElPuertoHost() {
        HostVencimientosPort host = mock(HostVencimientosPort.class, CALLS_REAL_METHODS);
        Vt04Response response = new Vt04Response(java.util.List.of(), 0, 20, 0, "ACEPTADO", null);
        when(host.execute(eq(Operacion.VT04), any(VtRequest.class))).thenReturn(response);
        when(host.execute(eq(Operacion.VT08), any(VtRequest.class)))
                .thenReturn(new com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt08Response(
                        java.util.List.of(), "ACEPTADO", null));

        VencimientosApplicationService service = new VencimientosApplicationService(host);

        assertSame(response, service.execute(Operacion.VT04, new Vt04Request("C1",
                new BusquedaExpedientes("2024", "123456", null, null, null, null, null, null, 0, 20))));
        verify(host).execute(eq(Operacion.VT04), any(VtRequest.class));
        verify(host).execute(eq(Operacion.VT08), any(VtRequest.class));
    }
}
