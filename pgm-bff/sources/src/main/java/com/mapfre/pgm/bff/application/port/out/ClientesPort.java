package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Cliente;
import com.mapfre.pgm.bff.domain.model.ClienteResumen;
import java.util.List;
import java.util.Optional;

/** PROD-APICANAL-CLIENTES (búsqueda federada + visión 360 nivel 1). */
public interface ClientesPort {
    List<ClienteResumen> buscar(CriteriosBusqueda criterios);

    Optional<Cliente> ficha(String clienteId);

    /** Los 13 criterios del «Buscador de clientes» de PGM (PGM_FormularioBusqueda_Cliente). */
    record CriteriosBusqueda(String texto, String documento, String telefono, String email,
                             String poliza, String tarjetaSanitaria, String localidad, int limite,
                             String primerApellido, String segundoApellido, String codigoPostal,
                             String expediente, String matricula, String presupuesto, String recibo) {
        public CriteriosBusqueda(String texto, String documento, String telefono, String email,
                                 String poliza, String tarjetaSanitaria, String localidad, int limite) {
            this(texto, documento, telefono, email, poliza, tarjetaSanitaria, localidad, limite,
                    null, null, null, null, null, null, null);
        }
        public boolean estaVacio() {
            return esBlanco(texto) && esBlanco(documento) && esBlanco(telefono) && esBlanco(email)
                    && esBlanco(poliza) && esBlanco(tarjetaSanitaria) && esBlanco(localidad)
                    && esBlanco(primerApellido) && esBlanco(segundoApellido) && esBlanco(codigoPostal)
                    && esBlanco(expediente) && esBlanco(matricula) && esBlanco(presupuesto) && esBlanco(recibo);
        }

        private static boolean esBlanco(String s) {
            return s == null || s.isBlank();
        }
    }
}
