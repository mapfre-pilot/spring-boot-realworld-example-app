package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.HostResponse;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.application.port.out.ImpresionPort;
import com.mapfre.vida.vencimientosmanuales.application.port.in.VencimientosUseCase;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

import static com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest.ApiDtos.*;

@Validated
@RestController
@RequestMapping("/api/v1")
public class VencimientosController {
    private final VencimientosUseCase service;
    private final ImpresionPort impresion;

    public VencimientosController(VencimientosUseCase service, ImpresionPort impresion) {
        this.service = service;
        this.impresion = impresion;
    }

    @GetMapping("/expedientes")
    public Map<String, Object> buscarExpedientes(
            @RequestParam(required = false) String anio, @RequestParam(required = false) String numero,
            @RequestParam(required = false) String ramo, @RequestParam(required = false) String anioPoliza,
            @RequestParam(required = false) String numeroPoliza, @RequestParam(required = false) String subpoliza,
            @RequestParam(required = false) String certificado, @RequestParam(required = false) String nif,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        boolean expediente = anio != null && numero != null;
        boolean poliza = ramo != null && anioPoliza != null && numeroPoliza != null;
        boolean persona = nif != null && !nif.isBlank();
        int criteria = (expediente ? 1 : 0) + (poliza ? 1 : 0) + (persona ? 1 : 0);
        if (criteria != 1 || page < 0 || size < 1 || size > 100) {
            throw new IllegalArgumentException("Indique un criterio completo de búsqueda y paginación válida");
        }
        Map<String, Object> fields = fields("ANIO-E", anio, "KEXPEDIENTE-E", numero,
                "KRAMO-E", ramo, "ANIOPOL-E", anioPoliza, "KPOLIZA-E", numeroPoliza,
                "NSUBPOLIZA-E", subpoliza, "KCERTIFICADO-E", certificado, "NIF-E", nif,
                "page", page, "size", size);
        return service.execute(Operacion.VT04, fields).campos();
    }

    @GetMapping("/expedientes/{anio}/{numero}")
    public Map<String, Object> obtenerExpediente(@PathVariable String anio, @PathVariable String numero) {
        return service.execute(Operacion.VT01, fields("OPERACION-E", "C1", "ANIO-E", anio,
                "KEXPEDIENTE-E", numero)).campos();
    }

    @PostMapping("/expedientes")
    public ResponseEntity<Map<String, Object>> altaExpediente(
            @RequestHeader("Idempotency-Key") @NotBlank String key, @Valid @RequestBody ExpedienteMutation body) {
        Map<String, Object> result = service.execute(Operacion.VT01, expedienteFields("A1", body)).campos();
        return ResponseEntity.status(HttpStatus.CREATED).body(result);
    }

    @PutMapping("/expedientes/{anio}/{numero}")
    public Map<String, Object> modificarExpediente(@PathVariable String anio, @PathVariable String numero,
            @Valid @RequestBody ExpedienteMutation body) {
        return service.execute(Operacion.VT01, expedienteFields("M1", body)).campos();
    }

    @PostMapping("/expedientes/{anio}/{numero}/anulacion")
    public Map<String, Object> anularExpediente(@PathVariable String anio, @PathVariable String numero,
            @RequestHeader("Idempotency-Key") @NotBlank String key) {
        return service.execute(Operacion.VT01, fields("ANIO-E", anio, "KEXPEDIENTE-E", numero,
                "FANULACION-E", java.time.LocalDate.now().toString())).campos();
    }

    @PostMapping("/expedientes/{anio}/{numero}/reaseguro")
    public Map<String, Object> gestionarReaseguro(@PathVariable String anio, @PathVariable String numero,
            @RequestHeader("Idempotency-Key") @NotBlank String key) {
        return service.execute(Operacion.VT01, fields("OPERACION-E", "M3", "ANIO-E", anio,
                "KEXPEDIENTE-E", numero)).campos();
    }

    @GetMapping("/expedientes/{anio}/{numero}/variables")
    public Map<String, Object> consultarVariables(@PathVariable String anio, @PathVariable String numero) {
        return service.execute(Operacion.VT02, fields("ANIO-E", anio, "KEXPEDIENTE-E", numero)).campos();
    }

    @PutMapping("/expedientes/{anio}/{numero}/variables")
    public Map<String, Object> modificarVariables(@PathVariable String anio, @PathVariable String numero,
            @RequestBody Map<String, String> body) {
        return service.execute(Operacion.VT02, fields("ANIO-E", anio, "KEXPEDIENTE-E", numero,
                "valores", body)).campos();
    }

    @GetMapping("/expedientes/{anio}/{numero}/coaseguro")
    public Map<String, Object> consultarCoaseguro(@PathVariable String anio, @PathVariable String numero) {
        return service.execute(Operacion.VT12, fields("ANIO-E", anio, "KEXPEDIENTE-E", numero)).campos();
    }

    @PutMapping("/expedientes/{anio}/{numero}/coaseguro")
    public Map<String, Object> modificarCoaseguro(@PathVariable String anio, @PathVariable String numero,
            @Valid @RequestBody CoaseguroRequest body) {
        BigDecimal sum = body.coaseguradoras().stream().map(Coaseguradora::porcentaje)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (sum.compareTo(new BigDecimal("100")) != 0) {
            throw new IllegalArgumentException("Los porcentajes de coaseguro deben sumar 100");
        }
        return service.execute(Operacion.VT12, fields("ANIO-E", anio, "KEXPEDIENTE-E", numero,
                "CUADRO-COASEGURO-E", body.coaseguradoras())).campos();
    }

    @GetMapping("/expedientes/{anio}/{numero}/fiscalidad")
    public Map<String, Object> fiscalidad(@PathVariable String anio, @PathVariable String numero) {
        return service.execute(Operacion.VT01, fields("OPERACION-E", "C1", "ANIO-E", anio,
                "KEXPEDIENTE-E", numero, "modo", "fiscalidad")).campos();
    }

    @GetMapping("/personas")
    public Map<String, Object> persona(@RequestParam @NotBlank @Size(min = 8, max = 10) String nif) {
        return service.execute(Operacion.VT11, fields("nif", nif)).campos();
    }

    @GetMapping("/polizas/{ramo}/{anio}/{numero}/cartera")
    public Map<String, Object> carteraPoliza(@PathVariable String ramo, @PathVariable String anio,
            @PathVariable String numero, @RequestParam(required = false) String subpoliza,
            @RequestParam(required = false) String certificado) {
        return service.execute(Operacion.VT19, fields("RAMO-E", ramo, "ANIOPOL-E", anio, "POLIZA-E", numero,
                "NSUBPOLIZA-E", subpoliza, "KCERTIFICADO-E", certificado)).campos();
    }

    @GetMapping("/carteras")
    public Map<String, Object> carteras() {
        return service.execute(Operacion.VT03, Map.of()).campos();
    }

    @GetMapping("/carteras/listado")
    public Map<String, Object> listadoCarteras(@RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        if (page < 0 || size < 1 || size > 100) throw new IllegalArgumentException("Paginación no válida");
        return service.execute(Operacion.VT05, fields("page", page, "size", size)).campos();
    }

    @PostMapping("/finiquitos/emisiones")
    public ResponseEntity<ImpresionPort.PrintJob> emitir(@RequestHeader("Idempotency-Key") @NotBlank String key,
            @Valid @RequestBody EmisionRequest body) {
        service.execute(Operacion.VT09, fields("ANIO-E", body.anio(), "EXPEDIENTE-DESDE-E",
                body.expedienteDesde(), "EXPEDIENTE-HASTA-E", body.expedienteHasta()));
        return ResponseEntity.accepted().body(impresion.submit("finiquitos", key));
    }

    @PostMapping("/informes")
    public ResponseEntity<ImpresionPort.PrintJob> informe(@RequestHeader("Idempotency-Key") @NotBlank String key,
            @Valid @RequestBody InformeRequest body) {
        service.execute(Operacion.VT10, fields("TIPO-EMISION-E", body.tipoEmision(),
                "ANIO-DESDE-E", body.anioDesde(), "ANIO-HASTA-E", body.anioHasta()));
        return ResponseEntity.accepted().body(impresion.submit("informe", key));
    }

    @PostMapping("/peticiones-bdgi")
    public ResponseEntity<Map<String, Object>> bdgi(@RequestHeader("Idempotency-Key") @NotBlank String key,
            @Valid @RequestBody BdgiRequest body) {
        return ResponseEntity.accepted().body(service.execute(Operacion.VT06, fields(
                "ANIO-E", body.anioEjercicio(), "MES-E", body.mesEjercicio(),
                "FECHA-INICIAL-E", body.fechaInicial(), "FECHA-FINAL-E", body.fechaFinal())).campos());
    }

    @PostMapping("/cargas-fichero")
    public ResponseEntity<Map<String, Object>> cargar(@RequestHeader("Idempotency-Key") @NotBlank String key,
            @Valid @RequestBody CargaRequest body) {
        return ResponseEntity.accepted().body(service.execute(Operacion.VT07,
                fields("TIPO-EMISION-E", body.tipoEmision())).campos());
    }

    @PostMapping("/calculos/liquidacion")
    public LiquidationCalculator.Result liquidacion(@Valid @RequestBody LiquidationRequest body) {
        List<BigDecimal> percentages = body.coaseguradoras() == null ? List.of()
                : body.coaseguradoras().stream().map(Coaseguradora::porcentaje).collect(Collectors.toList());
        return service.calculate(new LiquidationCalculator.Input(fiscal(body.capital()), fiscal(body.prima()),
                fiscal(body.complementario()), body.importeCapital(), body.beneficios(), body.anticipo(),
                body.interesesPendientes(), percentages));
    }

    private LiquidationCalculator.FiscalInput fiscal(FiscalInput input) {
        return input == null ? null : new LiquidationCalculator.FiscalInput(input.importe(), input.rtoIntegro(),
                input.reduccionPrimas(), input.reduccionTransitoria(), input.porcentajeRetencion(),
                input.tipoImpuesto(), input.codigoPostal());
    }

    private Map<String, Object> expedienteFields(String operation, ExpedienteMutation body) {
        return fields("OPERACION-E", operation, "ANIO-E", body.anio(), "KEXPEDIENTE-E", body.numero(),
                "KRAMO-E", body.ramo(), "KPOLIZA-E", body.numeroPoliza(), "NSUBPOLIZA-E", body.subpoliza(),
                "KCERTIFICADO-E", body.certificado(), "NIF-E", body.nif(), "IMPCAPITAL-E", body.importeCapital(),
                "BENEFICIOS-E", body.beneficios(), "ANTICIPO-E", body.anticipo(),
                "INTERESES-PENDIENTES-E", body.interesesPendientes());
    }

    private Map<String, Object> fields(Object... keyValues) {
        Map<String, Object> result = new LinkedHashMap<>();
        for (int i = 0; i < keyValues.length; i += 2) {
            if (keyValues[i + 1] != null) result.put(String.valueOf(keyValues[i]), keyValues[i + 1]);
        }
        return result;
    }
}
