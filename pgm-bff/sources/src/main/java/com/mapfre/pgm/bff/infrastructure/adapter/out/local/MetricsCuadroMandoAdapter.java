package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.mapfre.pgm.bff.application.port.out.CuadroMandoPort;
import com.mapfre.pgm.bff.domain.model.Kpi;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.search.Search;
import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Component;

/**
 * Cuadro de mando de uso a partir de las métricas propias del BFF (contador pgm.accesos). En entornos reales
 * los KPIs históricos salen de Prometheus/Grafana; aquí se exponen los del proceso en curso. Válido en todos los perfiles.
 */
@Component
public class MetricsCuadroMandoAdapter implements CuadroMandoPort {

    private final MeterRegistry registry;

    public MetricsCuadroMandoAdapter(MeterRegistry registry) {
        this.registry = registry;
    }

    @Override
    public List<Kpi> kpis(String periodo) {
        List<Kpi> kpis = new ArrayList<>();
        kpis.add(new Kpi("busquedas", "Búsquedas de clientes", suma("BUSQUEDA_CLIENTES"), "consultas", periodo));
        kpis.add(new Kpi("fichas", "Fichas de cliente consultadas", suma("CONSULTA_FICHA"), "consultas", periodo));
        kpis.add(new Kpi("tarificaciones", "Tarificaciones de Salud", suma("TARIFICACION_SALUD"), "operaciones", periodo));
        kpis.add(new Kpi("lanzaderas", "Lanzaderas abiertas", suma("LANZADERA"), "clics", periodo));
        return kpis;
    }

    private double suma(String accion) {
        return Search.in(registry).name("pgm.accesos").tag("accion", accion).counters().stream()
                .mapToDouble(c -> c.count()).sum();
    }
}
