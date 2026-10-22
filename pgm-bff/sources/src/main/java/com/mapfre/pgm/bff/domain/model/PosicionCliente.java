package com.mapfre.pgm.bff.domain.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/** Modelos de la posición del cliente observados en PGM (área B): acciones/documentos/detalle de póliza, estados anteriores, recibo completo. */
public final class PosicionCliente {
    private PosicionCliente() {}

    /** Catálogo dinámico de acciones de póliza por compañía+ramo (WLCatalog): diálogo «Acciones» → IR. */
    public record AccionPoliza(String codigo, String nombre, String destino, String url, boolean requiereNuuma, boolean externa) {}

    /** «Documentación de emisión» → CONSULTA DESCARGA DOCUMENTOS de la póliza. */
    public record DocumentoPoliza(String id, String tipo, String nombre, LocalDate fecha, String formato) {}

    /** Bloques específicos por ramo de la ficha de póliza (Vida/Ahorro: garantías y beneficiarios; Autos: vehículo/conductores; Hogar: vivienda). */
    public record DetallePolizaRamo(String numero, Ramo ramo, Poliza.TipoDetalle tipoDetalle, String idPoliza,
                                    boolean primasPeriodicas, List<String> noDisponiblePorOrigen, Map<String, Map<String, String>> bloques,
                                    List<Garantia> garantias, List<Beneficiario> beneficiarios,
                                    List<DisponibilidadPorOrigen> disponibilidadPorOrigen) {
        public DetallePolizaRamo(String numero, Ramo ramo, Poliza.TipoDetalle tipoDetalle, String idPoliza,
                                 boolean primasPeriodicas, List<String> noDisponiblePorOrigen,
                                 Map<String, Map<String, String>> bloques, List<Garantia> garantias,
                                 List<Beneficiario> beneficiarios) {
            this(numero, ramo, tipoDetalle, idPoliza, primasPeriodicas, noDisponiblePorOrigen, bloques, garantias,
                    beneficiarios, List.of());
        }
    }
    public record DisponibilidadPorOrigen(String dato, String origen, boolean disponible, String motivo) {}
    public record Garantia(String codigo, String nombre, BigDecimal capital, String franquicia) {}
    public record Beneficiario(String nombre, String documento, String parentesco, BigDecimal porcentaje) {}

    /** Posición › Estados anteriores (pólizas anuladas/históricas con fecha y motivo de baja). */
    public record EstadoAnterior(String polizaNumero, Ramo ramo, String producto, Poliza.EstadoPoliza estado, LocalDate fechaEfecto,
                                 LocalDate fechaBaja, String motivoBaja) {}

    /** Detalle interno de recibo (PGM_Detalle_Recibos*, visible si PGM_visualizacionRecibos). */
    public record ReciboDetalle(Recibo recibo, String producto, String riesgo, String metodoPagoLiteral, String pagador,
                                String estructuraComercial, BigDecimal cuota, BigDecimal comisiones, List<String> gestiones,
                                List<DisponibilidadPorOrigen> disponibilidadPagador) {
        public ReciboDetalle(Recibo recibo, String producto, String riesgo, String metodoPagoLiteral, String pagador,
                             String estructuraComercial, BigDecimal cuota, BigDecimal comisiones, List<String> gestiones) {
            this(recibo, producto, riesgo, metodoPagoLiteral, pagador, estructuraComercial, cuota, comisiones, gestiones,
                    List.of());
        }
    }

    /** Menú ⋮ del recibo: Consulta Recibos (ConsuWeb, externo), Visualizar duplicado, Detalle (si flag). */
    public record AccionRecibo(String codigo, String nombre, String tipo, String url) {}

    /** Duplicado del recibo (GESYC imprimirRecibo): fichero en base64. */
    public record DuplicadoRecibo(String numeroRecibo, String nombreFichero, String tipoMime, String contenidoBase64) {}

    /** Detalle de prestación/siniestro (METS), visible si PGM_CONS_VER_DETALLE_PRESTACIONES. */
    public record PrestacionDetalle(Prestacion prestacion, BigDecimal importeEstimado, BigDecimal importePagado, String codigoRamo,
                                    List<String> hitos, String oficinaTramitadora) {}
}
