package com.mapfre.vida.vencimientosmanuales.domain;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class LiquidationCalculatorTest {
    private final LiquidationCalculator calculator = new LiquidationCalculator();

    @Test
    void calculaNetoRetencionYLiquidoConRedondeoHalfUp() {
        var amount = calculator.calculateAmount(new LiquidationCalculator.FiscalInput(
                bd("985.00"), bd("1000"), bd("10"), bd("5"), bd("10"), "0", "28001"));
        assertEquals(bd("985.00"), amount.rtoNeto());
        assertEquals(bd("98.50"), amount.retencion());
        assertEquals(bd("886.50"), amount.liquido());
        assertEquals(bd("1.01"), amount.rtoNeto().multiply(bd("0.001025")).setScale(2,
                java.math.RoundingMode.HALF_UP));
    }

    @Test
    void usaRentaNetaEnProvinciasEspecialesYBrutaEnOtrasParaTipoUno() {
        var special = calculator.calculateAmount(new LiquidationCalculator.FiscalInput(
                bd("985"), bd("1000"), bd("10"), bd("5"), bd("10"), "1", "01001"));
        var other = calculator.calculateAmount(new LiquidationCalculator.FiscalInput(
                bd("985"), bd("1000"), bd("10"), bd("5"), bd("10"), "1", "28001"));
        assertEquals(bd("98.50"), special.retencion());
        assertEquals(bd("100.00"), other.retencion());
    }

    @Test
    void redondeaValoresParcialesYLimitaRetencionNegativaACero() {
        var empty = calculator.calculateAmount(new LiquidationCalculator.FiscalInput(
                null, null, null, null, null, null, null));
        var negative = calculator.calculateAmount(new LiquidationCalculator.FiscalInput(
                bd("0"), bd("-50"), null, null, bd("20"), "0", null));
        assertEquals(bd("0.00"), empty.rtoNeto());
        assertEquals(bd("0.00"), negative.retencion());
        assertEquals(bd("-50.00"), negative.rtoNeto());
    }

    @Test
    void distribuyeImporteEntreSeisCoaseguradorasYConservaTotal() {
        List<BigDecimal> shares = List.of(bd("16.666667"), bd("16.666667"), bd("16.666667"),
                bd("16.666667"), bd("16.666666"), bd("16.666666"));
        List<BigDecimal> amounts = calculator.repartir(bd("120.01"), shares);
        assertEquals(6, amounts.size());
        assertEquals(bd("120.01"), amounts.stream().reduce(BigDecimal.ZERO, BigDecimal::add));
    }

    @Test
    void rechazaSumaDistintaDeCienOMasDeSeisEntidades() {
        assertThrows(IllegalArgumentException.class, () -> calculator.repartir(bd("10"), List.of(bd("99"))));
        assertThrows(IllegalArgumentException.class,
                () -> calculator.repartir(bd("10"), List.of(bd("100"), bd("0"), bd("0"), bd("0"), bd("0"), bd("0"), bd("0"))));
    }

    private static BigDecimal bd(String value) { return new BigDecimal(value); }
}
