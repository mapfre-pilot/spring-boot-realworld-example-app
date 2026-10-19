package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.domain.model.Poliza;
import java.util.List;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("local")
public class InMemoryPolizasAdapter implements PolizasPort {

    private final List<Poliza> polizas;

    public InMemoryPolizasAdapter(ObjectMapper mapper) {
        this.polizas = LocalDataLoader.load(mapper, "polizas.json", new TypeReference<>() {});
    }

    @Override
    public List<Poliza> porCliente(String clienteId) {
        return polizas.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public Optional<Poliza> detalle(String numeroPoliza) {
        return polizas.stream().filter(p -> p.numero().equalsIgnoreCase(numeroPoliza)).findFirst();
    }
}
