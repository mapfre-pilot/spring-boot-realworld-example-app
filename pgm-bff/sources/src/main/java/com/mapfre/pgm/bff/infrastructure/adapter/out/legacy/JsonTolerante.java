package com.mapfre.pgm.bff.infrastructure.adapter.out.legacy;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

/**
 * Lectura tolerante de respuestas legacy cuyo contrato detallado no está publicado en el grafo KDD (área E): se prueban varios
 * nombres de campo habituales en los servicios EDGE/apisb de PGM. Cuando llegue el contrato definitivo se sustituye por DTOs tipados.
 */
final class JsonTolerante {
    private final Map<String, Object> m;

    JsonTolerante(Map<String, Object> m) {
        this.m = m == null ? Map.of() : m;
    }

    static JsonTolerante de(Object o) {
        if (o instanceof Map<?, ?> map) {
            @SuppressWarnings("unchecked") Map<String, Object> mm = (Map<String, Object>) map;
            return new JsonTolerante(mm);
        }
        return new JsonTolerante(Map.of());
    }

    @SuppressWarnings("unchecked")
    static List<Map<String, Object>> lista(Object cuerpo, String... claves) {
        if (cuerpo instanceof List<?> l) {
            return (List<Map<String, Object>>) l;
        }
        if (cuerpo instanceof Map<?, ?> map) {
            for (String k : claves) {
                Object v = map.get(k);
                if (v instanceof List<?> l) {
                    return (List<Map<String, Object>>) l;
                }
            }
            for (Object v : map.values()) {
                if (v instanceof List<?> l) {
                    return (List<Map<String, Object>>) l;
                }
            }
        }
        return List.of();
    }

    Object raw(String... claves) {
        for (String k : claves) {
            Object v = m.get(k);
            if (v != null) {
                return v;
            }
        }
        return null;
    }

    String texto(String... claves) {
        Object v = raw(claves);
        return v == null ? null : v.toString();
    }

    JsonTolerante objeto(String... claves) {
        return de(raw(claves));
    }

    Integer entero(String... claves) {
        Object v = raw(claves);
        if (v instanceof Number n) {
            return n.intValue();
        }
        try {
            return v == null ? null : Integer.valueOf(v.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    BigDecimal decimal(String... claves) {
        Object v = raw(claves);
        if (v instanceof Number n) {
            return new BigDecimal(n.toString());
        }
        try {
            return v == null ? null : new BigDecimal(v.toString().trim().replace(",", "."));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    boolean bool(String... claves) {
        Object v = raw(claves);
        return v instanceof Boolean b ? b : v != null && List.of("S", "SI", "Y", "YES", "TRUE", "1").contains(v.toString().trim().toUpperCase());
    }

    LocalDate fecha(String... claves) {
        String v = texto(claves);
        if (v == null || v.isBlank()) {
            return null;
        }
        try {
            return v.length() > 10 ? OffsetDateTime.parse(v).toLocalDate() : LocalDate.parse(v.substring(0, 10));
        } catch (DateTimeParseException e) {
            try {
                String[] p = v.split("[/-]");
                return p.length == 3 && p[2].length() == 4 ? LocalDate.of(Integer.parseInt(p[2]), Integer.parseInt(p[1]), Integer.parseInt(p[0])) : null;
            } catch (RuntimeException ex) {
                return null;
            }
        }
    }

    boolean vacio() {
        return m.isEmpty();
    }
}
