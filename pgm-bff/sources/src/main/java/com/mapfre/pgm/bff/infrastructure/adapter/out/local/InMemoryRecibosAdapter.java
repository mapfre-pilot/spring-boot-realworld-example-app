package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import java.util.Base64;
import java.math.BigDecimal;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.RecibosPort;
import com.mapfre.pgm.bff.domain.model.Recibo;
import java.util.List;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("local")
public class InMemoryRecibosAdapter implements RecibosPort {

    private final List<Recibo> recibos;

    public InMemoryRecibosAdapter(ObjectMapper mapper) {
        this.recibos = LocalDataLoader.load(mapper, "recibos.json", new TypeReference<>() {});
    }

    @Override
    public List<Recibo> porClienteRecibos(String clienteId) {
        return recibos.stream().filter(r -> r.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public Optional<Recibo> detalleRecibo(String numeroRecibo) {
        return recibos.stream().filter(r -> r.numero().equalsIgnoreCase(numeroRecibo)).findFirst();
    }

    @Override
    public Optional<ReciboDetalle> detalleCompleto(String numeroRecibo) {
        return detalleRecibo(numeroRecibo).map(r -> new ReciboDetalle(r, "Producto " + r.ramo().name().toLowerCase(), "Riesgo asegurado (demo)",
                switch (r.formaPago()) { case "Domiciliación" -> "Domiciliación bancaria"; case "Tarjeta" -> "Pago con tarjeta"; default -> r.formaPago(); },
                "Tomador de la póliza", "Oficina 0001 · Agente 12345",
                r.importe(), r.importe().multiply(new BigDecimal("0.08")).setScale(2, java.math.RoundingMode.HALF_UP),
                r.estado() == Recibo.EstadoRecibo.DEVUELTO ? List.of("Devolución bancaria", "Reenvío al banco") : List.of(),
                List.of(
                        new DisponibilidadPorOrigen("Datos Personales", "LOCAL", false, "El perfil local no contiene los datos personales del pagador."),
                        new DisponibilidadPorOrigen("Contacto", "LOCAL", false, "El perfil local no contiene los datos de contacto del pagador."),
                        new DisponibilidadPorOrigen("Correspondencia", "LOCAL", false, "El perfil local no contiene los datos de correspondencia del pagador."))));
    }

    @Override
    public DuplicadoRecibo duplicado(String numeroRecibo, String nuuma) {
        String contenido = "Duplicado recibo " + numeroRecibo + " solicitado por " + nuuma;
        return new DuplicadoRecibo(numeroRecibo, "duplicado-" + numeroRecibo + ".pdf", "application/pdf",
                Base64.getEncoder().encodeToString(contenido.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
    }
}
