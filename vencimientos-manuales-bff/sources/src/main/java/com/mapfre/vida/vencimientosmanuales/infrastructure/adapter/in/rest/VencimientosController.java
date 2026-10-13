package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.in.rest;

import com.mapfre.vida.vencimientosmanuales.application.port.in.VencimientosUseCase;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Operacion;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt01Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt01Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt02Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt02Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt03Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt03Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt04Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt04Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt05Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt05Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt06Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt06Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt07Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt07Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt09Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt10Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt11Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt11Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt12Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt12Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt19Response;
import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.Vt19Request;
import com.mapfre.vida.vencimientosmanuales.application.port.out.ImpresionPort;
import com.mapfre.vida.vencimientosmanuales.domain.LiquidationCalculator;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
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
    public PaginaExpedientes buscarExpedientes(
            @RequestParam(required = false) String anio, @RequestParam(required = false) String numero,
            @RequestParam(required = false) String ramo, @RequestParam(required = false) String anioPoliza,
            @RequestParam(required = false) String numeroPoliza, @RequestParam(required = false) String subpoliza,
            @RequestParam(required = false) String certificado, @RequestParam(required = false) String nif,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        boolean expediente = anio != null && numero != null;
        boolean poliza = ramo != null && anioPoliza != null && numeroPoliza != null;
        boolean persona = nif != null && !nif.isBlank();
        if ((expediente ? 1 : 0) + (poliza ? 1 : 0) + (persona ? 1 : 0) != 1
                || page < 0 || size < 1 || size > 100) {
            throw new IllegalArgumentException("Indique un criterio completo de búsqueda y paginación válida");
        }
        HostVencimientosPort.BusquedaExpedientes criteria = new HostVencimientosPort.BusquedaExpedientes(
                anio, numero, ramo, anioPoliza, numeroPoliza, subpoliza, certificado, nif, page, size);
        Vt04Response response = (Vt04Response) service.execute(Operacion.VT04, new Vt04Request("C1", criteria));
        return new PaginaExpedientes(response.expedientes().stream().map(this::toApi).toList(),
                response.page(), response.size(), response.totalElements());
    }

    @GetMapping("/expedientes/{anio}/{numero}")
    public Expediente obtenerExpediente(@PathVariable String anio, @PathVariable String numero) {
        Vt01Response response = (Vt01Response) service.execute(Operacion.VT01,
                new Vt01Request("C1", anio, numero, null, null, null, null, null, null,
                        null, null, null, null, null, null, List.of()));
        return toApi(response.expediente());
    }

    @PostMapping("/expedientes")
    public ResponseEntity<Expediente> altaExpediente(
            @RequestHeader("Idempotency-Key") @NotBlank String key, @Valid @RequestBody ExpedienteMutation body) {
        validateCoaseguro(body.coaseguradoras());
        Vt01Response response = (Vt01Response) service.execute(Operacion.VT01, request("A1", body));
        return ResponseEntity.status(HttpStatus.CREATED).body(toApi(response.expediente()));
    }

    @PutMapping("/expedientes/{anio}/{numero}")
    public Expediente modificarExpediente(@PathVariable String anio, @PathVariable String numero,
                                          @Valid @RequestBody ExpedienteMutation body) {
        validateCoaseguro(body.coaseguradoras());
        Vt01Response response = (Vt01Response) service.execute(Operacion.VT01,
                request("M1", withKeys(anio, numero, body)));
        return toApi(response.expediente());
    }

    @PostMapping("/expedientes/{anio}/{numero}/anulacion")
    public ResponseEntity<Void> anularExpediente(@PathVariable String anio, @PathVariable String numero,
                                                 @RequestHeader("Idempotency-Key") @NotBlank String key) {
        service.execute(Operacion.VT01, new Vt01Request("A2", anio, numero, null, null, null,
                null, null, null, null, null, null, null, null, java.time.LocalDate.now(), List.of()));
        return ResponseEntity.ok().build();
    }

    @PostMapping("/expedientes/{anio}/{numero}/reaseguro")
    public ResponseEntity<Void> gestionarReaseguro(@PathVariable String anio, @PathVariable String numero,
                                                   @RequestHeader("Idempotency-Key") @NotBlank String key) {
        service.execute(Operacion.VT01, new Vt01Request("M3", anio, numero, null, null, null,
                null, null, null, null, null, null, null, null, null, List.of()));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/expedientes/{anio}/{numero}/variables")
    public Variables consultarVariables(@PathVariable String anio, @PathVariable String numero) {
        Vt02Response response = (Vt02Response) service.execute(Operacion.VT02,
                new Vt02Request("C", anio, numero, null, List.of()));
        return new Variables(response.variables().stream().map(v -> new Variable(v.codigo(), v.valor())).toList());
    }

    @PutMapping("/expedientes/{anio}/{numero}/variables")
    public Variables modificarVariables(@PathVariable String anio, @PathVariable String numero,
                                        @Valid @RequestBody VariablesRequest body) {
        var values = body.variables().stream()
                .map(value -> new HostVencimientosPort.Variable(value.codigo(), value.valor())).toList();
        Vt02Response response = (Vt02Response) service.execute(Operacion.VT02,
                new Vt02Request("M", anio, numero, null, values));
        return new Variables(response.variables().stream().map(v -> new Variable(v.codigo(), v.valor())).toList());
    }

    @GetMapping("/expedientes/{anio}/{numero}/coaseguro")
    public Coaseguro consultarCoaseguro(@PathVariable String anio, @PathVariable String numero) {
        Vt12Response response = (Vt12Response) service.execute(Operacion.VT12,
                new Vt12Request("C1", null, null));
        return toCoaseguro(response.coaseguradoras());
    }

    @PutMapping("/expedientes/{anio}/{numero}/coaseguro")
    public Coaseguro modificarCoaseguro(@PathVariable String anio, @PathVariable String numero,
                                        @Valid @RequestBody CoaseguroRequest body) {
        BigDecimal sum = body.coaseguradoras().stream().map(Coaseguradora::porcentaje)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        if (sum.compareTo(new BigDecimal("100")) != 0) {
            throw new IllegalArgumentException("Los porcentajes de coaseguro deben sumar 100");
        }
        Expediente current = obtenerExpediente(anio, numero);
        var shares = body.coaseguradoras().stream()
                .map(value -> new HostVencimientosPort.Coaseguradora(value.codigo(), value.porcentaje(),
                        null, null)).toList();
        Vt01Response response = (Vt01Response) service.execute(Operacion.VT01, new Vt01Request("M1",
                current.anio(), current.numero(), current.ramo(), current.anioPoliza(), current.numeroPoliza(),
                current.subpoliza(), current.certificado(), current.nif(), current.situacion(), current.importeCapital(),
                current.beneficios(), current.anticipo(), current.interesesPendientes(), current.fechaEfecto(), shares));
        return toCoaseguro(response.expediente().coaseguradoras());
    }

    @GetMapping("/expedientes/{anio}/{numero}/fiscalidad")
    public DatosFiscales fiscalidad(@PathVariable String anio, @PathVariable String numero) {
        Expediente value = obtenerExpediente(anio, numero);
        return new DatosFiscales(null, null, value.nif(), null);
    }

    @GetMapping("/personas")
    public Persona persona(@RequestParam @NotBlank @Size(min = 8, max = 10) String nif) {
        Vt11Response response = (Vt11Response) service.execute(Operacion.VT11,
                new Vt11Request(nif, null, null, null, null, null));
        var value = response.persona();
        return new Persona(value.nombre(), value.apellidos(), value.nif(), value.domicilio(),
                value.codigoPostal(), value.poblacion());
    }

    @GetMapping("/polizas/{ramo}/{anio}/{numero}/cartera")
    public Cartera carteraPoliza(@PathVariable String ramo, @PathVariable String anio,
                                 @PathVariable String numero, @RequestParam(required = false) String subpoliza,
                                 @RequestParam(required = false) String certificado) {
        Vt19Response response = (Vt19Response) service.execute(Operacion.VT19,
                new Vt19Request(numero, subpoliza, certificado));
        return toApi(response.cartera());
    }

    @GetMapping("/carteras")
    public PaginaCarteras carteras() {
        Vt03Response response = (Vt03Response) service.execute(Operacion.VT03, new Vt03Request("C", null, null,
                null, null, null, null));
        return new PaginaCarteras(response.carteras().stream().map(this::toApi).toList(),
                0, Math.max(1, response.carteras().size()), response.carteras().size());
    }

    @GetMapping("/carteras/listado")
    public PaginaCarteras listadoCarteras(@RequestParam(defaultValue = "0") int page,
                                          @RequestParam(defaultValue = "20") int size) {
        if (page < 0 || size < 1 || size > 100) throw new IllegalArgumentException("Paginación no válida");
        Vt05Response response = (Vt05Response) service.execute(Operacion.VT05,
                new Vt05Request("C", null, null, null, null, null, null, page, size));
        return new PaginaCarteras(response.carteras().stream().map(this::toApi).toList(),
                response.page(), response.size(), response.totalElements());
    }

    @PostMapping("/finiquitos/emisiones")
    public ResponseEntity<ImpresionPort.PrintJob> emitir(@RequestHeader("Idempotency-Key") @NotBlank String key,
                                                         @Valid @RequestBody EmisionRequest body) {
        service.execute(Operacion.VT09, new Vt09Request(body.anio(), body.expedienteDesde(),
                body.expedienteHasta(), body.fechaEmision(), body.tipoEmision(), body.lugarEnvio()));
        return ResponseEntity.accepted().body(impresion.submit("finiquitos", key));
    }

    @PostMapping("/informes")
    public ResponseEntity<ImpresionPort.PrintJob> informe(@RequestHeader("Idempotency-Key") @NotBlank String key,
                                                          @Valid @RequestBody InformeRequest body) {
        service.execute(Operacion.VT10, new Vt10Request(body.tipoEmision(), body.anioDesde(), body.anioHasta(),
                body.expedienteDesde(), body.expedienteHasta(), body.fechaEmisionDesde(),
                body.fechaEmisionHasta(), body.fechaPagoDesde(), body.fechaPagoHasta()));
        return ResponseEntity.accepted().body(impresion.submit("informe", key));
    }

    @PostMapping("/peticiones-bdgi")
    public ResponseEntity<Vt06Response> bdgi(@RequestHeader("Idempotency-Key") @NotBlank String key,
                                             @Valid @RequestBody BdgiRequest body) {
        return ResponseEntity.accepted().body((Vt06Response) service.execute(Operacion.VT06, new Vt06Request(
                body.anioEjercicio(), body.mesEjercicio(), body.fechaInicial(), body.fechaFinal())));
    }

    @PostMapping("/cargas-fichero")
    public ResponseEntity<Vt07Response> cargar(@RequestHeader("Idempotency-Key") @NotBlank String key,
                                               @Valid @RequestBody CargaRequest body) {
        return ResponseEntity.accepted().body((Vt07Response) service.execute(
                Operacion.VT07, new Vt07Request(body.tipoEmision())));
    }

    @PostMapping("/calculos/liquidacion")
    public Liquidacion liquidacion(@Valid @RequestBody LiquidationRequest body) {
        List<BigDecimal> percentages = body.coaseguradoras() == null ? List.of()
                : body.coaseguradoras().stream().map(Coaseguradora::porcentaje).collect(Collectors.toList());
        var result = service.calculate(new LiquidationCalculator.Input(fiscal(body.capital()), fiscal(body.prima()),
                fiscal(body.complementario()), body.importeCapital(), body.beneficios(), body.anticipo(),
                body.interesesPendientes(), percentages));
        return new Liquidacion(amount(result.capital()), amount(result.prima()), amount(result.complementario()),
                result.liquidoCapital(), result.importesCoasegurados());
    }

    private Vt01Request request(String operation, ExpedienteMutation body) {
        return new Vt01Request(operation, body.anio(), body.numero(), body.ramo(), body.anioPoliza(),
                body.numeroPoliza(), body.subpoliza(), body.certificado(), body.nif(), body.situacion(),
                body.importeCapital(),
                body.beneficios(), body.anticipo(), body.interesesPendientes(), body.fechaEfecto(),
                body.coaseguradoras().stream().map(value ->
                        new HostVencimientosPort.Coaseguradora(value.codigo(), value.porcentaje(), null, null)).toList());
    }

    private ExpedienteMutation withKeys(String anio, String numero, ExpedienteMutation body) {
        return new ExpedienteMutation(anio, numero, body.ramo(), body.anioPoliza(), body.numeroPoliza(),
                body.subpoliza(), body.certificado(), body.nif(), body.situacion(), body.importeCapital(), body.beneficios(),
                body.anticipo(), body.interesesPendientes(), body.fechaEfecto(), body.coaseguradoras());
    }

    private Expediente toApi(HostVencimientosPort.Expediente value) {
        return new Expediente(value.anio(), value.numero(), value.ramo(), value.anioPoliza(),
                value.numeroPoliza(), value.subpoliza(), value.certificado(), value.nif(), value.situacion(),
                value.importeCapital(), value.beneficios(), value.anticipo(), value.interesesPendientes(),
                value.fechaEfecto(), value.coaseguradoras().stream()
                .map(item -> new Coaseguradora(item.codigo(), item.porcentaje())).toList());
    }

    private Coaseguro toCoaseguro(List<HostVencimientosPort.Coaseguradora> values) {
        return new Coaseguro(values.stream().map(item -> new Coaseguradora(item.codigo(), item.porcentaje())).toList());
    }

    private Cartera toApi(HostVencimientosPort.Cartera value) {
        return new Cartera(value.ramo(), value.anioPoliza(), value.numeroPoliza(),
                value.subpoliza(), value.modalidad(), value.situacion());
    }

    private LiquidationCalculator.FiscalInput fiscal(FiscalInput input) {
        return input == null ? null : new LiquidationCalculator.FiscalInput(input.importe(), input.rtoIntegro(),
                input.reduccionPrimas(), input.reduccionTransitoria(), input.porcentajeRetencion(),
                input.tipoImpuesto(), input.codigoPostal());
    }

    private void validateCoaseguro(List<Coaseguradora> values) {
        if (!values.isEmpty()) {
            BigDecimal sum = values.stream().map(Coaseguradora::porcentaje)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            if (sum.compareTo(new BigDecimal("100")) != 0) {
                throw new IllegalArgumentException("Los porcentajes de coaseguro deben sumar 100");
            }
        }
    }

    private ImporteCalculado amount(LiquidationCalculator.Amount value) {
        return new ImporteCalculado(value.importe(), value.rtoNeto(), value.retencion(), value.liquido());
    }
}
