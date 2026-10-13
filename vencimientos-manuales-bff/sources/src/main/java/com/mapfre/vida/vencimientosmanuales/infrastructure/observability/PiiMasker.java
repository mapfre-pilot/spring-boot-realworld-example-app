package com.mapfre.vida.vencimientosmanuales.infrastructure.observability;

import java.util.regex.Pattern;

public final class PiiMasker {
    private static final Pattern NIF = Pattern.compile("\\b[0-9XYZ]\\d{7}[A-Z]\\b", Pattern.CASE_INSENSITIVE);
    private static final Pattern IBAN = Pattern.compile("\\b[A-Z]{2}\\d{2}(?: ?[A-Z0-9]){11,30}\\b",
            Pattern.CASE_INSENSITIVE);

    private PiiMasker() {}

    public static String mask(String value) {
        if (value == null) return null;
        String masked = NIF.matcher(value).replaceAll("*********");
        return IBAN.matcher(masked).replaceAll(match -> {
            String iban = match.group().replace(" ", "");
            return iban.substring(0, 4) + "********";
        });
    }
}
