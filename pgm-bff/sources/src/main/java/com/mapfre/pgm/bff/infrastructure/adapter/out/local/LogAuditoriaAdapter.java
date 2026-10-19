package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.mapfre.pgm.bff.application.port.out.AuditoriaPort;
import com.mapfre.pgm.bff.domain.model.RegistroAuditoria;
import io.micrometer.core.instrument.MeterRegistry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/** Auditoría por NUUMA: log JSON estructurado (sin PII) + contador Prometheus. Válido en todos los perfiles. */
@Component
public class LogAuditoriaAdapter implements AuditoriaPort {

    private static final Logger audit = LoggerFactory.getLogger("AUDITORIA");
    private final MeterRegistry registry;

    public LogAuditoriaAdapter(MeterRegistry registry) {
        this.registry = registry;
    }

    @Override
    public void registrar(RegistroAuditoria r) {
        audit.info("auditoria accion={} pantalla={} nuuma={} usuario={} clienteId={}",
                r.accion(), r.pantalla(), r.nuuma(), r.usuario(), r.clienteId() == null ? "-" : r.clienteId());
        registry.counter("pgm.accesos", "accion", r.accion(), "pantalla", r.pantalla() == null ? "-" : r.pantalla()).increment();
    }
}
