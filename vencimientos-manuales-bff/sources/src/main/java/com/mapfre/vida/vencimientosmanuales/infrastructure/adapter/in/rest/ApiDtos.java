package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public final class ApiDtos {
    private ApiDtos() {}

    public record Expediente(String anio, String numero, String ramo, String anioPoliza,
                             String numeroPoliza, String subpoliza, String certificado, String nif,
                             String situacion, BigDecimal importeCapital, BigDecimal beneficios,
                             BigDecimal anticipo, BigDecimal interesesPendientes, LocalDate fechaEfecto,
                             List<Coaseguradora> coaseguradoras) {
        public Expediente { coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras); }
    }

    public record BusquedaExpedientes(String anio, String numero, String ramo, String anioPoliza,
                                      String numeroPoliza, String subpoliza, String certificado, String nif,
                                      int page, int size) {}
    public record PaginaExpedientes(List<Expediente> content, int page, int size, long totalElements) {
        public PaginaExpedientes { content = List.copyOf(content); }
    }

    public record ExpedienteMutation(@NotBlank @Pattern(regexp = "\\d{4}") String anio,
                                     @NotBlank @Size(max = 10) String numero,
                                     @Size(max = 3) String ramo, @Size(max = 4) String anioPoliza,
                                     @Size(max = 10) String numeroPoliza, @Size(max = 4) String subpoliza,
                                     @Size(max = 6) String certificado, @Size(max = 10) String nif,
                                     @Size(max = 2) String situacion,
                                     BigDecimal importeCapital, BigDecimal beneficios, BigDecimal anticipo,
                                     BigDecimal interesesPendientes, LocalDate fechaEfecto,
                                     @Size(max = 6) List<@Valid Coaseguradora> coaseguradoras) {
        public ExpedienteMutation {
            coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras);
        }
    }

    public record Coaseguradora(@NotBlank @Size(max = 7) String codigo,
                                @NotNull @DecimalMin("0") @DecimalMax("100") BigDecimal porcentaje) {}
    public record CoaseguroRequest(@NotEmpty @Size(max = 6) List<@Valid Coaseguradora> coaseguradoras) {}
    public record Coaseguro(List<Coaseguradora> coaseguradoras) {
        public Coaseguro { coaseguradoras = List.copyOf(coaseguradoras); }
    }

    public record Variable(@NotBlank String codigo, @NotBlank String valor) {}
    public record VariablesRequest(List<@Valid Variable> variables) {
        public VariablesRequest { variables = variables == null ? List.of() : List.copyOf(variables); }
    }
    public record Variables(List<Variable> variables) {
        public Variables { variables = List.copyOf(variables); }
    }

    public record EmisionRequest(@NotBlank @Pattern(regexp = "\\d{4}") String anio,
                                 @NotBlank String expedienteDesde, @NotBlank String expedienteHasta,
                                 LocalDate fechaEmision, String tipoEmision, String lugarEnvio) {}
    public record InformeRequest(String tipoEmision, String anioDesde, String anioHasta,
                                 String expedienteDesde, String expedienteHasta,
                                 LocalDate fechaEmisionDesde, LocalDate fechaEmisionHasta,
                                 LocalDate fechaPagoDesde, LocalDate fechaPagoHasta) {}
    public record BdgiRequest(@NotNull @Min(1900) @Max(2200) Integer anioEjercicio,
                              @NotNull @Min(1) @Max(12) Integer mesEjercicio,
                              @NotNull LocalDate fechaInicial, @NotNull LocalDate fechaFinal) {}
    public record CargaRequest(@NotBlank @Size(max = 2) String tipoEmision) {}
    public record Persona(String nombre, String apellidos, String nif, String domicilio,
                          String codigoPostal, String poblacion) {}
    public record Cartera(String ramo, String anioPoliza, String numeroPoliza,
                          String subpoliza, String modalidad, String situacion) {}
    public record PaginaCarteras(List<Cartera> content, int page, int size, long totalElements) {
        public PaginaCarteras { content = List.copyOf(content); }
    }
    public record DatosFiscales(String tipoImpuesto, BigDecimal porcentajeRetencion,
                                String nif, String codigoPostal) {}

    public record FiscalInput(BigDecimal importe, BigDecimal rtoIntegro, BigDecimal reduccionPrimas,
                              BigDecimal reduccionTransitoria, BigDecimal porcentajeRetencion,
                              String tipoImpuesto, String codigoPostal) {}
    public record LiquidationRequest(@Valid FiscalInput capital, @Valid FiscalInput prima,
                                     @Valid FiscalInput complementario, BigDecimal importeCapital,
                                     BigDecimal beneficios, BigDecimal anticipo, BigDecimal interesesPendientes,
                                     @Size(max = 6) List<@Valid Coaseguradora> coaseguradoras) {}
    public record Liquidacion(ImporteCalculado capital, ImporteCalculado prima, ImporteCalculado complementario,
                              BigDecimal liquidoCapital, List<BigDecimal> importesCoasegurados) {
        public Liquidacion { importesCoasegurados = List.copyOf(importesCoasegurados); }
    }
    public record ImporteCalculado(BigDecimal importe, BigDecimal rtoNeto, BigDecimal retencion,
                                   BigDecimal liquido) {}
}
