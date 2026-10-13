package com.mapfre.vida.vencimientosmanuales.domain;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class LiquidationCalculator {
    private static final BigDecimal ONE_HUNDRED = new BigDecimal("100");
    private static final BigDecimal ZERO = BigDecimal.ZERO;

    public Result calculate(Input input) {
        Amount capital = calculateAmount(input.capital());
        Amount prima = calculateAmount(input.prima());
        Amount complementario = calculateAmount(input.complementario());

        BigDecimal liquidCapital = money(value(input.importeCapital())
                .add(value(input.beneficios()))
                .subtract(capital.retencion())
                .subtract(value(input.anticipo()))
                .subtract(value(input.interesesPendientes())));
        BigDecimal baseCoaseguro = money(value(input.importeCapital())
                .add(value(input.beneficios()))
                .add(prima.importe())
                .add(complementario.importe()));
        List<BigDecimal> reparto = repartir(baseCoaseguro, input.coaseguradoras());
        return new Result(capital, prima, complementario, liquidCapital, reparto);
    }

    public Amount calculateAmount(FiscalInput input) {
        BigDecimal bruto = value(input.rtoIntegro());
        BigDecimal neto = money(bruto.subtract(value(input.reduccionPrimas()))
                .subtract(value(input.reduccionTransitoria())));
        String provincia = input.codigoPostal() == null || input.codigoPostal().length() < 2
                ? "" : input.codigoPostal().substring(0, 2);
        boolean usaIntegro = "1".equals(input.tipoImpuesto())
                && !List.of("01", "20", "31", "48").contains(provincia);
        BigDecimal baseRetencion = usaIntegro ? bruto : neto;
        BigDecimal retencion = money(baseRetencion.multiply(value(input.porcentajeRetencion()))
                .divide(ONE_HUNDRED, 8, RoundingMode.HALF_UP).max(ZERO));
        BigDecimal liquido = money(value(input.importe()).subtract(retencion));
        return new Amount(money(value(input.importe())), neto, retencion, liquido);
    }

    public List<BigDecimal> repartir(BigDecimal total, List<BigDecimal> porcentajes) {
        Objects.requireNonNull(porcentajes, "porcentajes");
        if (porcentajes.size() > 6) {
            throw new IllegalArgumentException("El coaseguro admite como máximo seis entidades");
        }
        BigDecimal suma = porcentajes.stream().map(LiquidationCalculator::value)
                .reduce(ZERO, BigDecimal::add);
        if (!porcentajes.isEmpty() && suma.compareTo(ONE_HUNDRED) != 0) {
            throw new IllegalArgumentException("Los porcentajes de coaseguro deben sumar 100");
        }
        if (porcentajes.isEmpty()) {
            return List.of();
        }
        List<BigDecimal> importes = new ArrayList<>();
        BigDecimal acumulado = ZERO;
        for (int i = 0; i < porcentajes.size(); i++) {
            BigDecimal importe = i == porcentajes.size() - 1
                    ? money(total.subtract(acumulado))
                    : money(total.multiply(value(porcentajes.get(i)))
                            .divide(ONE_HUNDRED, 8, RoundingMode.HALF_UP));
            importes.add(importe);
            acumulado = acumulado.add(importe);
        }
        return List.copyOf(importes);
    }

    private static BigDecimal money(BigDecimal value) {
        return value.setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal value(BigDecimal value) {
        return value == null ? ZERO : value;
    }

    public record FiscalInput(BigDecimal importe, BigDecimal rtoIntegro,
                              BigDecimal reduccionPrimas, BigDecimal reduccionTransitoria,
                              BigDecimal porcentajeRetencion, String tipoImpuesto,
                              String codigoPostal) {}

    public record Input(FiscalInput capital, FiscalInput prima, FiscalInput complementario,
                        BigDecimal importeCapital, BigDecimal beneficios,
                        BigDecimal anticipo, BigDecimal interesesPendientes,
                        List<BigDecimal> coaseguradoras) {
        public Input {
            capital = capital == null ? new FiscalInput(null, null, null, null, null, null, null) : capital;
            prima = prima == null ? new FiscalInput(null, null, null, null, null, null, null) : prima;
            complementario = complementario == null
                    ? new FiscalInput(null, null, null, null, null, null, null) : complementario;
            coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras);
        }
    }

    public record Amount(BigDecimal importe, BigDecimal rtoNeto, BigDecimal retencion,
                         BigDecimal liquido) {}
    public record Result(Amount capital, Amount prima, Amount complementario,
                         BigDecimal liquidoCapital, List<BigDecimal> importesCoasegurados) {}
}
