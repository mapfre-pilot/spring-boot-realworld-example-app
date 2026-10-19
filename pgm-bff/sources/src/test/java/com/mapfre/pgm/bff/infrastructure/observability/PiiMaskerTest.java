package com.mapfre.pgm.bff.infrastructure.observability;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class PiiMaskerTest {

    @Test
    void enmascaraDniIbanEmailYTelefono() {
        String out = PiiMasker.mask("cliente 12345678Z iban ES9121000418450200051332 mail juan@example.com tel 600123456");
        assertThat(out).doesNotContain("12345678Z", "ES9121000418450200051332", "juan@example.com", "600123456");
        assertThat(out).contains("*****", "IBAN****", "***@***");
    }

    @Test
    void noTocaIdentificadoresFuncionales() {
        assertThat(PiiMasker.mask("accion=CONSULTA_FICHA clienteId=C-1001 poliza=AUT-000100")).isEqualTo("accion=CONSULTA_FICHA clienteId=C-1001 poliza=AUT-000100");
    }
}
