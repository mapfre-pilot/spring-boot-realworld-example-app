package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

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
}
