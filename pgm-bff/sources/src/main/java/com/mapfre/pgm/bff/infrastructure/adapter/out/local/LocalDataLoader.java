package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import org.springframework.core.io.ClassPathResource;

/** Carga los datos sintéticos del perfil local (classpath:local-data/*.json). */
final class LocalDataLoader {
    private LocalDataLoader() {}

    static <T> T load(ObjectMapper mapper, String fichero, TypeReference<T> tipo) {
        try (InputStream in = new ClassPathResource("local-data/" + fichero).getInputStream()) {
            return mapper.readValue(in, tipo);
        } catch (IOException e) {
            throw new UncheckedIOException("No se pudo cargar local-data/" + fichero, e);
        }
    }
}
