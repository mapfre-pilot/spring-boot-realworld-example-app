package com.mapfre.vida.vencimientosmanuales.application.port.out;

import java.util.UUID;

public interface ImpresionPort {
    PrintJob submit(String tipo, String idempotencyKey);
    record PrintJob(UUID id, String estado) {}
}
