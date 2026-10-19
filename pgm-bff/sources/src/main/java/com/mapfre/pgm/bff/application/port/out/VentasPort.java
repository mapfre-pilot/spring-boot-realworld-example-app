package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Presupuesto;
import com.mapfre.pgm.bff.domain.model.TarificacionSalud;
import java.util.List;

/** PROD-APICANAL-VENTAS (presupuestos, tarificación). */
public interface VentasPort {
    List<Presupuesto> presupuestosPorCliente(String clienteId);

    TarificacionSalud.Resultado tarificarSalud(TarificacionSalud.Solicitud solicitud);
}
