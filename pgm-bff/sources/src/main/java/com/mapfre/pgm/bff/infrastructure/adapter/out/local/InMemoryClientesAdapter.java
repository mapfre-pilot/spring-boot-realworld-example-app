package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.ClientesPort;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import com.mapfre.pgm.bff.domain.model.Poliza;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/** Simula PROD-APICANAL-CLIENTES (búsqueda federada y ficha 360) con datos sintéticos. */
@Component
@Profile("local")
public class InMemoryClientesAdapter implements ClientesPort {

    private final List<Cliente> clientes;
    private final PolizasPort polizasPort;

    public InMemoryClientesAdapter(ObjectMapper mapper, PolizasPort polizasPort) {
        this.clientes = LocalDataLoader.load(mapper, "clientes.json", new TypeReference<>() {});
        this.polizasPort = polizasPort;
    }

    @Override
    public List<ClienteResumen> buscar(CriteriosBusqueda c) {
        return clientes.stream()
                .filter(cl -> coincide(c.texto(), cl.nombreCompleto() + " " + cl.documento() + " " + cl.id()))
                .filter(cl -> coincide(c.documento(), cl.documento()))
                .filter(cl -> coincide(c.telefono(), cl.telefono()))
                .filter(cl -> coincide(c.email(), cl.email()))
                .filter(cl -> coincide(c.localidad(), cl.direccion() == null ? "" : cl.direccion().localidad()))
                .filter(cl -> c.poliza() == null || c.poliza().isBlank()
                        || polizasPort.porCliente(cl.id()).stream().anyMatch(p -> p.numero().equalsIgnoreCase(c.poliza())))
                .filter(cl -> c.tarjetaSanitaria() == null || c.tarjetaSanitaria().isBlank()
                        || polizasPort.porCliente(cl.id()).stream().anyMatch(p -> p.ramo() == com.mapfre.pgm.bff.domain.model.Ramo.SALUD))
                .limit(c.limite())
                .map(this::resumen)
                .toList();
    }

    @Override
    public Optional<Cliente> ficha(String clienteId) {
        return clientes.stream().filter(cl -> cl.id().equalsIgnoreCase(clienteId)).findFirst();
    }

    private ClienteResumen resumen(Cliente cl) {
        long enVigor = polizasPort.porCliente(cl.id()).stream()
                .filter(p -> p.estado() == Poliza.EstadoPoliza.EN_VIGOR).count();
        return new ClienteResumen(cl.id(), cl.nombre(), cl.apellidos(), cl.tipoDocumento(), cl.documento(), cl.tipologia(),
                cl.estado(), cl.telefono(), cl.email(), cl.direccion() == null ? null : cl.direccion().localidad(), (int) enVigor);
    }

    private static boolean coincide(String criterio, String valor) {
        if (criterio == null || criterio.isBlank()) {
            return true;
        }
        return valor != null && normaliza(valor).contains(normaliza(criterio));
    }

    private static String normaliza(String s) {
        return Normalizer.normalize(s, Normalizer.Form.NFD).replaceAll("\\p{M}", "").toLowerCase(Locale.ROOT).trim();
    }
}
