package com.mapfre.vida.vencimientosmanuales.application;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.HostResponse;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.application.service.VencimientosApplicationService;
import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.CALLS_REAL_METHODS;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class VencimientosApplicationServiceTest {
    @Test
    void busquedaOrquestaVT04YVT08ConElPuertoHost() {
        HostVencimientosPort host = mock(HostVencimientosPort.class, CALLS_REAL_METHODS);
        HostResponse response = new HostResponse(Map.of("content", java.util.List.of()));
        when(host.execute(eq(Operacion.VT04), anyMap())).thenReturn(response);
        when(host.execute(eq(Operacion.VT08), anyMap())).thenReturn(new HostResponse(Map.of()));

        VencimientosApplicationService service = new VencimientosApplicationService(host);

        assertSame(response, service.execute(Operacion.VT04, Map.of("ANIO-E", "2024")));
        verify(host).execute(eq(Operacion.VT04), anyMap());
        verify(host).execute(eq(Operacion.VT08), anyMap());
    }
}
