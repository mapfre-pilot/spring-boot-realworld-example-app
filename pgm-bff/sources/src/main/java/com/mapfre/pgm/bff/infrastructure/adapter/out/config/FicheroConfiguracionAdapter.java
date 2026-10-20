package com.mapfre.pgm.bff.infrastructure.adapter.out.config;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.ConfiguracionPort;
import com.mapfre.pgm.bff.domain.model.Configuracion;
import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicLong;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Almacén en fichero (`PGM_CONFIG_DIR`, por defecto ./config; en compose un volumen): `configuracion.json` (sin secretos) y
 * `secretos.enc` cifrado AES-256-GCM con la clave de `PGM_CONFIG_KEY` (base64, 32 bytes) o, si no existe, una clave generada
 * y guardada en `config.key` con permisos 600 (solo entornos locales). En MAPFRE la fuente debe ser Config Server/Vault.
 */
@Component
public class FicheroConfiguracionAdapter implements ConfiguracionPort {

    private final AtomicLong version = new AtomicLong();

    private static final Logger log = LoggerFactory.getLogger(FicheroConfiguracionAdapter.class);
    private final ObjectMapper mapper;
    private final Path dir;
    private final String claveEnv;
    private final Object lock = new Object();

    public FicheroConfiguracionAdapter(ObjectMapper mapper, @Value("${PGM_CONFIG_DIR:./config}") String dir,
                                       @Value("${PGM_CONFIG_KEY:}") String claveEnv) {
        this.mapper = mapper;
        this.dir = Path.of(dir);
        this.claveEnv = claveEnv;
    }

    @Override
    public Optional<Configuracion> leer() {
        Path f = dir.resolve("configuracion.json");
        if (!Files.exists(f)) return Optional.empty();
        try {
            return Optional.of(mapper.readValue(Files.readAllBytes(f), Configuracion.class));
        } catch (IOException e) {
            log.warn("Configuración ilegible en {}: {}", f, e.getMessage());
            return Optional.empty();
        }
    }

    @Override
    public void escribir(Configuracion configuracion) {
        version.incrementAndGet();
        synchronized (lock) {
            try {
                Files.createDirectories(dir);
                Files.write(dir.resolve("configuracion.json"), mapper.writerWithDefaultPrettyPrinter().writeValueAsBytes(configuracion));
            } catch (IOException e) {
                throw new UncheckedIOException(e);
            }
        }
    }

    @Override
    public Map<String, String> secretos(String ambito) {
        Map<String, String> todos = leerSecretos();
        Map<String, String> r = new LinkedHashMap<>();
        String prefijo = ambito + "/";
        todos.forEach((k, v) -> { if (k.startsWith(prefijo) && v != null && !v.isBlank()) r.put(k.substring(prefijo.length()), v); });
        return r;
    }

    @Override
    public void guardarSecreto(String ambito, String nombre, String valor) {
        version.incrementAndGet();
        synchronized (lock) {
            Map<String, String> todos = new HashMap<>(leerSecretos());
            todos.put(ambito + "/" + nombre, valor);
            escribirSecretos(todos);
        }
    }

    @Override
    public void borrarSecreto(String ambito, String nombre) {
        version.incrementAndGet();
        synchronized (lock) {
            Map<String, String> todos = new HashMap<>(leerSecretos());
            todos.remove(ambito + "/" + nombre);
            escribirSecretos(todos);
        }
    }

    @Override
    public String origenSecretos() {
        return claveEnv.isBlank() ? "FICHERO_CIFRADO (clave local config.key)" : "FICHERO_CIFRADO (clave PGM_CONFIG_KEY)";
    }

    private Map<String, String> leerSecretos() {
        Path f = dir.resolve("secretos.enc");
        if (!Files.exists(f)) return Map.of();
        try {
            byte[] datos = Base64.getDecoder().decode(Files.readString(f).trim());
            byte[] iv = new byte[12];
            System.arraycopy(datos, 0, iv, 0, 12);
            Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
            c.init(Cipher.DECRYPT_MODE, clave(), new GCMParameterSpec(128, iv));
            byte[] claro = c.doFinal(datos, 12, datos.length - 12);
            return mapper.readValue(claro, new TypeReference<Map<String, String>>() {});
        } catch (IOException | GeneralSecurityException e) {
            log.warn("Secretos ilegibles ({}); se tratan como vacíos", e.getMessage());
            return Map.of();
        }
    }

    private void escribirSecretos(Map<String, String> secretos) {
        try {
            Files.createDirectories(dir);
            byte[] iv = new byte[12];
            new SecureRandom().nextBytes(iv);
            Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
            c.init(Cipher.ENCRYPT_MODE, clave(), new GCMParameterSpec(128, iv));
            byte[] cifrado = c.doFinal(mapper.writeValueAsBytes(secretos));
            byte[] salida = new byte[12 + cifrado.length];
            System.arraycopy(iv, 0, salida, 0, 12);
            System.arraycopy(cifrado, 0, salida, 12, cifrado.length);
            Files.writeString(dir.resolve("secretos.enc"), Base64.getEncoder().encodeToString(salida));
        } catch (IOException | GeneralSecurityException e) {
            throw new IllegalStateException("No se pudo cifrar la configuración de secretos", e);
        }
    }

    private SecretKey clave() throws IOException, GeneralSecurityException {
        if (!claveEnv.isBlank()) {
            return new SecretKeySpec(Base64.getDecoder().decode(claveEnv), "AES");
        }
        Path k = dir.resolve("config.key");
        if (Files.exists(k)) {
            return new SecretKeySpec(Base64.getDecoder().decode(Files.readString(k).trim()), "AES");
        }
        KeyGenerator gen = KeyGenerator.getInstance("AES");
        gen.init(256);
        SecretKey nueva = gen.generateKey();
        Files.createDirectories(dir);
        Files.writeString(k, Base64.getEncoder().encodeToString(nueva.getEncoded()));
        try {
            Files.setPosixFilePermissions(k, java.nio.file.attribute.PosixFilePermissions.fromString("rw-------"));
        } catch (UnsupportedOperationException | IOException ignored) {
            log.debug("No se pudieron fijar permisos POSIX en {}", k);
        }
        log.warn("Clave de cifrado de configuración generada en {} (solo para entornos locales; en MAPFRE usar PGM_CONFIG_KEY/Vault)", k);
        return nueva;
    }

    @Override
    public long version() {
        return version.get();
    }
}
