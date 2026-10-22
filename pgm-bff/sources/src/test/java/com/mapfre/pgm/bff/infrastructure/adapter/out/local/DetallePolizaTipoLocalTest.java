package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.domain.model.Poliza;
import org.junit.jupiter.api.Test;

class DetallePolizaTipoLocalTest {

    private final InMemoryPolizasAdapter adapter =
            new InMemoryPolizasAdapter(
                    new ObjectMapper().findAndRegisterModules(), "https://apps.example.invalid");

    @Test
    void mapeaCadaTipoDeDetalleDePolizaSintetica() {
        assertTipo("AUT-000100", Poliza.TipoDetalle.AUTOS);
        assertTipo("SAL-000102", Poliza.TipoDetalle.SALUD);
        assertDetalle("VID-000103", Poliza.TipoDetalle.VIDA, true);
        assertTipo("HOG-000101", Poliza.TipoDetalle.HOGAR);
        assertTipo("CON-000600", Poliza.TipoDetalle.CONSUMO_PROTEGIDO);
        assertTipo("HIP-000601", Poliza.TipoDetalle.HIPOTECA_SEGURA);
        assertTipo("DEC-000201", Poliza.TipoDetalle.GENERICA);
    }

    private void assertDetalle(String numero, Poliza.TipoDetalle tipo, boolean primasPeriodicas) {
        assertThat(adapter.detalle(numero).flatMap(adapter::detalleRamo))
                .get()
                .satisfies(detalle -> {
                    assertThat(detalle.tipoDetalle()).isEqualTo(tipo);
                    assertThat(detalle.primasPeriodicas()).isEqualTo(primasPeriodicas);
                    assertThat(detalle.idPoliza()).isEqualTo(numero);
                    assertThat(detalle.bloques()).isNotEmpty();
                });
    }

    private void assertTipo(String numero, Poliza.TipoDetalle tipo) {
        assertThat(adapter.detalle(numero).flatMap(adapter::detalleRamo))
                .get()
                .extracting(detalle -> detalle.tipoDetalle())
                .isEqualTo(tipo);
    }
}
