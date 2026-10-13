package com.mapfre.vida.vencimientosmanuales.application.port.out;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface HostVencimientosPort {
    VtResponse execute(Operacion operacion, VtRequest request);

    enum Operacion { VT01, VT02, VT03, VT04, VT05, VT06, VT07, VT08, VT09, VT10, VT11, VT12, VT19 }

    sealed interface VtRequest permits Vt01Request, Vt02Request, Vt03Request, Vt04Request,
            Vt05Request, Vt06Request, Vt07Request, Vt08Request, Vt09Request, Vt10Request,
            Vt11Request, Vt12Request, Vt19Request {}

    /** B372VT01 / 3701: gestión de expediente y operaciones A1, M1, C1, M3. */
    record Vt01Request(String operacion, String anio, String numero, String ramo, String anioPoliza,
                       String numeroPoliza, String subpoliza, String certificado, String nif, String situacion,
                       BigDecimal importeCapital, BigDecimal beneficios, BigDecimal anticipo,
                       BigDecimal interesesPendientes, LocalDate fechaEfecto,
                       List<Coaseguradora> coaseguradoras) implements VtRequest {
        public Vt01Request {
            coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras);
        }
    }
    /** B372VT02: consulta y mantenimiento de variables por expediente y tabla. */
    record Vt02Request(String operacion, String anio, String numero, String tabla,
                       List<Variable> variables) implements VtRequest {
        public Vt02Request { variables = variables == null ? List.of() : List.copyOf(variables); }
    }
    /** B372VT03: consulta provisional de contratos de cartera. */
    record Vt03Request(String operacion, String modalidad, LocalDate fechaDesde, LocalDate fechaHasta,
                       String cartera, String entidad, String tipoOperacion) implements VtRequest {}
    /** B372VT04 / 3704: búsqueda paginada por expediente, póliza o NIF. */
    record Vt04Request(String operacion, BusquedaExpedientes busqueda) implements VtRequest {}
    /** B372VT05: listado paginado provisional de contratos de cartera. */
    record Vt05Request(String operacion, String modalidad, LocalDate fechaDesde, LocalDate fechaHasta,
                       String anteriorModalidad, LocalDate anteriorFechaDesde, LocalDate anteriorFechaHasta,
                       int page, int size) implements VtRequest {}
    /** B372VT06: solicitud BDGI por ejercicio y periodo. */
    record Vt06Request(int anioEjercicio, int mesEjercicio, LocalDate fechaInicial,
                       LocalDate fechaFinal) implements VtRequest {}
    /** B372VT07: carga de fichero de emisión. */
    record Vt07Request(String tipoEmision) implements VtRequest {}
    /** B372VT08: paginación/cursor de datos adicionales de búsqueda. */
    record Vt08Request(String anio, String numero, String operacion, String anteriorAnio,
                       String anteriorNumero) implements VtRequest {}
    /** B372VT09 / 3709: emisión de finiquitos. */
    record Vt09Request(String anio, String expedienteDesde, String expedienteHasta,
                       LocalDate fechaEmision, String tipoEmision, String lugarEnvio) implements VtRequest {}
    /** B372VT10 / 3710: generación de informes. */
    record Vt10Request(String tipoEmision, String anioDesde, String anioHasta,
                       String expedienteDesde, String expedienteHasta, LocalDate fechaEmisionDesde,
                       LocalDate fechaEmisionHasta, LocalDate fechaPagoDesde, LocalDate fechaPagoHasta) implements VtRequest {}
    /** B372VT11 / 3711: datos de persona por claves de persona y domicilio del XML. */
    record Vt11Request(String nif, String personaId, String domicilioId, String persona2Id,
                       String domicilio2Id, LocalDate fechaModificacion) implements VtRequest {}
    /** B372VT12 / 3612: lectura del cuadro de hasta seis coaseguradoras. */
    record Vt12Request(String operacion, String numeroPoliza, String subpoliza) implements VtRequest {}
    /** B372VT19 / 3719: consulta de cartera de póliza. */
    record Vt19Request(String numeroPoliza, String subpoliza, String certificado) implements VtRequest {}

    sealed interface VtResponse permits Vt01Response, Vt02Response, Vt03Response, Vt04Response,
            Vt05Response, Vt06Response, Vt07Response, Vt08Response, Vt09Response, Vt10Response,
            Vt11Response, Vt12Response, Vt19Response {}
    record Vt01Response(Expediente expediente, String estado, String mensaje) implements VtResponse {}
    record Vt02Response(List<Variable> variables, String estado, String mensaje) implements VtResponse {
        public Vt02Response { variables = variables == null ? List.of() : List.copyOf(variables); }
    }
    record Vt03Response(List<Cartera> carteras, String estado, String mensaje) implements VtResponse {
        public Vt03Response { carteras = carteras == null ? List.of() : List.copyOf(carteras); }
    }
    record Vt04Response(List<Expediente> expedientes, int page, int size, long totalElements,
                        String estado, String mensaje) implements VtResponse {
        public Vt04Response { expedientes = expedientes == null ? List.of() : List.copyOf(expedientes); }
    }
    record Vt05Response(List<Cartera> carteras, int page, int size, long totalElements,
                        String estado, String mensaje) implements VtResponse {
        public Vt05Response { carteras = carteras == null ? List.of() : List.copyOf(carteras); }
    }
    record Vt06Response(String solicitudId, String estado, String mensaje) implements VtResponse {}
    record Vt07Response(String cargaId, String estado, String mensaje) implements VtResponse {}
    record Vt08Response(List<Expediente> expedientes, String estado, String mensaje) implements VtResponse {
        public Vt08Response { expedientes = expedientes == null ? List.of() : List.copyOf(expedientes); }
    }
    record Vt09Response(String estado, String mensaje) implements VtResponse {}
    record Vt10Response(String estado, String mensaje) implements VtResponse {}
    record Vt11Response(Persona persona, String estado, String mensaje) implements VtResponse {}
    record Vt12Response(List<Coaseguradora> coaseguradoras, String estado, String mensaje) implements VtResponse {
        public Vt12Response { coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras); }
    }
    record Vt19Response(Cartera cartera, String estado, String mensaje) implements VtResponse {}

    record BusquedaExpedientes(String anio, String numero, String ramo, String anioPoliza,
                               String numeroPoliza, String subpoliza, String certificado,
                               String nif, int page, int size) {}
    record Expediente(String anio, String numero, String ramo, String anioPoliza, String numeroPoliza,
                      String subpoliza, String certificado, String nif, String situacion,
                      BigDecimal importeCapital, BigDecimal beneficios, BigDecimal anticipo,
                      BigDecimal interesesPendientes, LocalDate fechaEfecto, List<Coaseguradora> coaseguradoras) {
        public Expediente { coaseguradoras = coaseguradoras == null ? List.of() : List.copyOf(coaseguradoras); }
    }
    record Coaseguradora(String codigo, BigDecimal porcentaje, BigDecimal importe,
                         BigDecimal importeRentaIntegra) {}
    record Variable(String codigo, String valor) {}
    record Cartera(String ramo, String anioPoliza, String numeroPoliza, String subpoliza,
                   String modalidad, String situacion) {}
    record Persona(String nombre, String apellidos, String nif, String domicilio,
                   String codigoPostal, String poblacion) {}
}
