package com.mapfre.pgm.bff.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.mapfre.pgm.bff.application.port.out.UsuariosComercialesPort;
import com.mapfre.pgm.bff.application.service.AutorizacionService;
import com.mapfre.pgm.bff.application.service.FeatureFlags;
import com.mapfre.pgm.bff.application.service.Perfiles;
import com.mapfre.pgm.bff.application.service.Visibilidades;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;

/** Reglas observadas en Appian: grupo gobierna tarjetas; Gestión comercial exige además perfil SGC 3.0 y NUUMA. */
class AutorizacionServiceTest {

    private final UsuariosComercialesPort gc = mock(UsuariosComercialesPort.class);
    private final AutorizacionService service = new AutorizacionService(gc, new FeatureFlags(true, true, true, true));

    @Test
    void asesorConNuumaYPerfilSgcVeGestionComercialCompleta() {
        when(gc.estructuraDe("u1")).thenReturn(Optional.of(new EstructuraComercial("NU1", "0001", "Madrid", "Centro")));
        when(gc.perfilSgc30De("u1")).thenReturn(Optional.of("ASESOR"));
        ContextoUsuario ctx = service.contexto("u1", "U1", List.of(Perfiles.ASESOR_COMERCIAL));
        assertThat(ctx.visibilidades()).containsEntry(Visibilidades.GESTION_COMERCIAL, true)
                .containsEntry(Visibilidades.GESTIONES_SGC30, true)
                .containsEntry(Visibilidades.ANADIR_VENCIMIENTO, true)
                .containsEntry(Visibilidades.CUADRO_MANDO, false);
    }

    @Test
    void asesorSinNuumaVeTarjetaPeroNoGestionesNiVencimientos() {
        when(gc.estructuraDe("u2")).thenReturn(Optional.empty());
        when(gc.perfilSgc30De("u2")).thenReturn(Optional.empty());
        ContextoUsuario ctx = service.contexto("u2", "U2", List.of(Perfiles.ASESOR_COMERCIAL, Perfiles.VISUALIZAR_CDM));
        assertThat(ctx.visibilidades()).containsEntry(Visibilidades.GESTION_COMERCIAL, true)
                .containsEntry(Visibilidades.GESTIONES_SGC30, false)
                .containsEntry(Visibilidades.ACTIVIDAD_COMERCIAL, false)
                .containsEntry(Visibilidades.CUADRO_MANDO, true);
    }

    @Test
    void usuarioBasicoNoVeGestionComercialYExigirLanzaExcepcion() {
        when(gc.estructuraDe("u3")).thenReturn(Optional.empty());
        when(gc.perfilSgc30De("u3")).thenReturn(Optional.empty());
        ContextoUsuario ctx = service.contexto("u3", "U3", List.of(Perfiles.USUARIO));
        assertThat(ctx.visibilidades()).containsEntry(Visibilidades.FICHA_CLIENTE, true).containsEntry(Visibilidades.GESTION_COMERCIAL, false);
        assertThatThrownBy(() -> service.exigir(ctx, Visibilidades.CUADRO_MANDO)).isInstanceOf(AccesoNoAutorizadoException.class);
    }

    @Test
    void featureFlagApagadoOcultaTarificacion() {
        AutorizacionService sinPiloto = new AutorizacionService(gc, new FeatureFlags(false, true, true, true));
        when(gc.estructuraDe("u4")).thenReturn(Optional.empty());
        when(gc.perfilSgc30De("u4")).thenReturn(Optional.empty());
        assertThat(sinPiloto.contexto("u4", "U4", List.of(Perfiles.USUARIO)).visibilidades())
                .containsEntry(Visibilidades.TARIFICACION_SALUD, false);
    }
}
