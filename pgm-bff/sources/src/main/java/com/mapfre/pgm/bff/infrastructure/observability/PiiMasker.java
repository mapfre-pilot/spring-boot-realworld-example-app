package com.mapfre.pgm.bff.infrastructure.observability;

import java.util.regex.Pattern;

/** Enmascara PII antes de escribir logs: DNI/NIE/CIF, IBAN, e-mail, teléfonos y tarjetas sanitarias. */
public final class PiiMasker {
    private PiiMasker() {}

    private static final Pattern DNI = Pattern.compile("\\b[0-9XYZxyz][0-9]{7}[A-Za-z]\\b");
    private static final Pattern CIF = Pattern.compile("\\b[A-HJ-NP-SUVWa-hj-np-suvw][0-9]{7}[0-9A-Ja-j]\\b");
    private static final Pattern IBAN = Pattern.compile("\\b[A-Z]{2}[0-9]{2}(?:\\s?[0-9A-Z]{4}){4,7}\\b");
    private static final Pattern EMAIL = Pattern.compile("[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}");
    private static final Pattern TELEFONO = Pattern.compile("(?<![0-9])(?:\\+34\\s?)?[6789][0-9]{2}\\s?[0-9]{3}\\s?[0-9]{3}(?![0-9])");
    private static final Pattern TARJETA_SANITARIA = Pattern.compile("\\b[0-9]{16,20}\\b");

    public static String mask(String text) {
        if (text == null || text.isEmpty()) {
            return text;
        }
        String out = IBAN.matcher(text).replaceAll("IBAN****");
        out = EMAIL.matcher(out).replaceAll("***@***");
        out = DNI.matcher(out).replaceAll("*****");
        out = CIF.matcher(out).replaceAll("*****");
        out = TARJETA_SANITARIA.matcher(out).replaceAll("****");
        out = TELEFONO.matcher(out).replaceAll("***");
        return out;
    }
}
