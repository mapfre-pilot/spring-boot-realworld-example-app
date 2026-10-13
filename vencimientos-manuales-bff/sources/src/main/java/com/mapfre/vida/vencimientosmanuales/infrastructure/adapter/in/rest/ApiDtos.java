package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.util.List;

public final class ApiDtos {
    private ApiDtos() {}

    public record ExpedienteMutation(@NotBlank @Pattern(regexp = "\\d{4}") String anio,
                                     @NotBlank @Size(max = 10) String numero,
                                     @Size(max = 3) String ramo,
                                     @Size(max = 10) String numeroPoliza,
                                     @Size(max = 4) String subpoliza,
                                     @Size(max = 6) String certificado,
                                     @Size(max = 10) String nif,
                                     BigDecimal importeCapital,
                                     BigDecimal beneficios,
                                     BigDecimal anticipo,
                                     BigDecimal interesesPendientes) {}

    public record Coaseguradora(@NotBlank @Size(max = 7) String codigo,
                                @NotNull @DecimalMin("0") @DecimalMax("100") BigDecimal porcentaje) {}
    public record CoaseguroRequest(@NotEmpty @Size(max = 6) List<@Valid Coaseguradora> coaseguradoras) {}
    public record EmisionRequest(@NotBlank @Pattern(regexp = "\\d{4}") String anio,
                                 @NotBlank String expedienteDesde,
                                 @NotBlank String expedienteHasta,
                                 String fechaEmision, String tipoEmision, String lugarEnvio) {}
    public record InformeRequest(String tipoEmision, String anioDesde, String anioHasta,
                                 String expedienteDesde, String expedienteHasta,
                                 String fechaEmisionDesde, String fechaEmisionHasta,
                                 String fechaPagoDesde, String fechaPagoHasta) {}
    public record BdgiRequest(@NotNull @Min(1900) @Max(2200) Integer anioEjercicio,
                              @NotNull @Min(1) @Max(12) Integer mesEjercicio,
                              @NotBlank String fechaInicial, @NotBlank String fechaFinal) {}
    public record CargaRequest(@NotBlank @Size(max = 2) String tipoEmision) {}
    public record FiscalInput(BigDecimal importe, BigDecimal rtoIntegro,
                              BigDecimal reduccionPrimas, BigDecimal reduccionTransitoria,
                              BigDecimal porcentajeRetencion, String tipoImpuesto, String codigoPostal) {}
    public record LiquidationRequest(@Valid FiscalInput capital, @Valid FiscalInput prima,
                                     @Valid FiscalInput complementario, BigDecimal importeCapital,
                                     BigDecimal beneficios, BigDecimal anticipo,
                                     BigDecimal interesesPendientes,
                                     @Size(max = 6) List<@Valid Coaseguradora> coaseguradoras) {}
}
