package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.impresion;

import com.mapfre.vida.vencimientosmanuales.application.port.out.ImpresionPort;
import com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host.HostIntegrationPendingException;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@Profile("local")
public class InMemoryImpresionAdapter implements ImpresionPort {
    @Override
    public PrintJob submit(String tipo, String idempotencyKey) {
        return new PrintJob(UUID.nameUUIDFromBytes((tipo + idempotencyKey).getBytes()), "ACEPTADO");
    }
}

@Component
@Profile("!local")
class PendingImpresionAdapter implements ImpresionPort {
    @Override
    public PrintJob submit(String tipo, String idempotencyKey) {
        throw new HostIntegrationPendingException();
    }
}
