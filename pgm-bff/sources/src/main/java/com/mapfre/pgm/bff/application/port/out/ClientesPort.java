package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import java.util.List;
import java.util.Optional;

/** PROD-APICANAL-CLIENTES (búsqueda federada + visión 360 nivel 1). */
public interface ClientesPort {
    List<ClienteResumen> buscar(CriteriosBusqueda criterios);

    Optional<Cliente> ficha(String clienteId);

    record CriteriosBusqueda(String texto, String documento, String telefono, String email,
                             String poliza, String tarjetaSanitaria, String localidad, int limite) {
        public boolean estaVacio() {
            return esBlanco(texto) && esBlanco(documento) && esBlanco(telefono) && esBlanco(email)
                    && esBlanco(poliza) && esBlanco(tarjetaSanitaria) && esBlanco(localidad);
        }

        private static boolean esBlanco(String s) {
            return s == null || s.isBlank();
        }
    }
}
