package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("!local")
public class CtgHostVencimientosAdapter implements HostVencimientosPort {
    private final B372VtXmlMapper xmlMapper;

    public CtgHostVencimientosAdapter(B372VtXmlMapper xmlMapper) {
        this.xmlMapper = xmlMapper;
    }

    @Override
    @HostAudit
    public VtResponse execute(Operacion operacion, VtRequest request) {
        xmlMapper.toXmlFields(request);
        throw new HostIntegrationPendingException();
    }
}
