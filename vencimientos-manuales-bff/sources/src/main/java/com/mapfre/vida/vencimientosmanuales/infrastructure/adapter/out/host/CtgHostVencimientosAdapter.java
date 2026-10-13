package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
@Profile("!local")
public class CtgHostVencimientosAdapter implements HostVencimientosPort {
    @Override
    @HostAudit
    public HostResponse execute(Operacion operacion, Map<String, Object> camposXml) {
        throw new HostIntegrationPendingException();
    }
}
