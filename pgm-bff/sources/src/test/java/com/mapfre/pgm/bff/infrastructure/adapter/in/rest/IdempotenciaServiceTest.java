package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Duration;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.Test;
import org.springframework.http.ResponseEntity;

class IdempotenciaServiceTest {

    private final IdempotenciaService idempotencia = new IdempotenciaService(new ObjectMapper(), Duration.ofHours(24));

    @Test
    void repiteRespuestaSinEjecutarDeNuevo() {
        AtomicInteger ejecuciones = new AtomicInteger();
        var primera = idempotencia.ejecutar("usuario", "POST", "/recurso", "clave", "cuerpo", () -> {
            ejecuciones.incrementAndGet();
            return ResponseEntity.accepted().body("resultado");
        });
        var repetida = idempotencia.ejecutar("usuario", "POST", "/recurso", "clave", "cuerpo", () -> {
            ejecuciones.incrementAndGet();
            return ResponseEntity.accepted().body("otro");
        });

        assertThat(ejecuciones).hasValue(1);
        assertThat(primera.getBody()).isEqualTo("resultado");
        assertThat(repetida.getBody()).isEqualTo("resultado");
        assertThat(repetida.getHeaders().getFirst("Idempotent-Replayed")).isEqualTo("true");
    }

    @Test
    void rechazaReutilizacionDeClaveConCuerpoDistinto() {
        idempotencia.ejecutar("usuario", "POST", "/recurso", "clave", "primero",
                () -> ResponseEntity.ok("resultado"));

        assertThatThrownBy(() -> idempotencia.ejecutar("usuario", "POST", "/recurso", "clave", "segundo",
                () -> ResponseEntity.ok("otro"))).isInstanceOf(IdempotenciaEnConflictoException.class);
    }

    @Test
    void aislaLaClavePorUsuarioMetodoYRuta() {
        AtomicInteger ejecuciones = new AtomicInteger();
        for (String usuario : new String[] {"u1", "u2"}) {
            idempotencia.ejecutar(usuario, "POST", "/recurso", "clave", "mismo", () -> {
                ejecuciones.incrementAndGet();
                return ResponseEntity.ok("resultado");
            });
        }
        idempotencia.ejecutar("u1", "PUT", "/recurso", "clave", "mismo", () -> {
            ejecuciones.incrementAndGet();
            return ResponseEntity.ok("resultado");
        });
        idempotencia.ejecutar("u1", "POST", "/otra-ruta", "clave", "mismo", () -> {
            ejecuciones.incrementAndGet();
            return ResponseEntity.ok("resultado");
        });

        assertThat(ejecuciones).hasValue(4);
    }

    @Test
    void expiraTrasLaVentanaConfigurada() {
        IdempotenciaService servicio = new IdempotenciaService(new ObjectMapper(), Duration.ZERO);
        AtomicInteger ejecuciones = new AtomicInteger();
        for (int i = 0; i < 2; i++) {
            servicio.ejecutar("usuario", "POST", "/recurso", "clave", "cuerpo", () -> {
                ejecuciones.incrementAndGet();
                return ResponseEntity.ok("resultado");
            });
        }

        assertThat(ejecuciones).hasValue(2);
    }
}
