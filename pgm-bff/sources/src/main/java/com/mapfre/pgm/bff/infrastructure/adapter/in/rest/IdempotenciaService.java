package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;
import java.util.function.Supplier;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

/** Idempotencia de peticiones POST en memoria, aislada por usuario, método, recurso y clave. */
@Component
public class IdempotenciaService {

    private record Clave(String usuario, String metodo, String ruta, String id) {}
    private record Respuesta(int status, HttpHeaders headers, Object body) {}

    private static final class Entrada {
        private final String hashCuerpo;
        private final CompletableFuture<Respuesta> respuesta = new CompletableFuture<>();
        private volatile Instant expira = Instant.MAX;

        private Entrada(String hashCuerpo) {
            this.hashCuerpo = hashCuerpo;
        }
    }

    private final ObjectMapper mapper;
    private final Duration ventana;
    private final Clock clock;
    private final ConcurrentMap<Clave, Entrada> respuestas = new ConcurrentHashMap<>();
    private final ThreadLocal<String> claveActual = new ThreadLocal<>();

    @Autowired
    public IdempotenciaService(ObjectMapper mapper, @Value("${pgm.idempotencia.ventana:PT24H}") Duration ventana) {
        this(mapper, ventana, Clock.systemUTC());
    }

    IdempotenciaService(ObjectMapper mapper, Duration ventana, Clock clock) {
        this.mapper = mapper;
        this.ventana = ventana;
        this.clock = clock;
    }

    public <T> ResponseEntity<T> ejecutar(String usuario, String metodo, String ruta, String idempotencyKey,
                                          Object cuerpo, Supplier<ResponseEntity<T>> operacion) {
        if (idempotencyKey == null || idempotencyKey.isBlank()) {
            return operacion.get();
        }

        limpiarCaducadas();
        Clave clave = new Clave(usuario, metodo, ruta, idempotencyKey);
        String hash = hash(cuerpo);
        while (true) {
            Entrada actual = respuestas.get(clave);
            if (actual == null) {
                Entrada nueva = new Entrada(hash);
                actual = respuestas.putIfAbsent(clave, nueva);
                if (actual == null) {
                    return ejecutarUnaVez(clave, nueva, idempotencyKey, operacion);
                }
            }
            if (!actual.hashCuerpo.equals(hash)) {
                throw new IdempotenciaEnConflictoException();
            }
            try {
                return convertir(actual.respuesta.join(), true);
            } catch (CompletionException e) {
                Throwable causa = e.getCause();
                if (causa instanceof RuntimeException runtime) {
                    throw runtime;
                }
                if (causa instanceof Error error) {
                    throw error;
                }
                throw e;
            }
        }
    }

    public String claveActual() {
        return claveActual.get();
    }

    private <T> ResponseEntity<T> ejecutarUnaVez(Clave clave, Entrada entrada, String idempotencyKey,
                                                  Supplier<ResponseEntity<T>> operacion) {
        String clavePrevia = claveActual.get();
        claveActual.set(idempotencyKey);
        try {
            ResponseEntity<T> response = operacion.get();
            HttpHeaders headers = new HttpHeaders();
            headers.putAll(response.getHeaders());
            entrada.expira = clock.instant().plus(ventana);
            entrada.respuesta.complete(new Respuesta(response.getStatusCode().value(), headers, response.getBody()));
            return response;
        } catch (RuntimeException | Error e) {
            respuestas.remove(clave, entrada);
            entrada.respuesta.completeExceptionally(e);
            throw e;
        } finally {
            if (clavePrevia == null) {
                claveActual.remove();
            } else {
                claveActual.set(clavePrevia);
            }
        }
    }

    private void limpiarCaducadas() {
        Instant ahora = clock.instant();
        respuestas.entrySet().removeIf(e -> e.getValue().respuesta.isDone()
                && !e.getValue().respuesta.isCompletedExceptionally()
                && !ahora.isBefore(e.getValue().expira));
    }

    private String hash(Object cuerpo) {
        try {
            byte[] bytes = mapper.writeValueAsBytes(cuerpo);
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (JsonProcessingException | NoSuchAlgorithmException e) {
            throw new IllegalStateException("No se pudo calcular el hash de la petición", e);
        }
    }

    @SuppressWarnings("unchecked")
    private static <T> ResponseEntity<T> convertir(Respuesta respuesta, boolean replay) {
        HttpHeaders headers = new HttpHeaders();
        headers.putAll(respuesta.headers());
        if (replay) {
            headers.set("Idempotent-Replayed", "true");
        }
        return (ResponseEntity<T>) ResponseEntity.status(respuesta.status()).headers(headers).body(respuesta.body());
    }
}
