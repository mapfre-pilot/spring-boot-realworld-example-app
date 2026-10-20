package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/** Modelos del menú ACCIONES de la cabecera de PGM (Más datos, Centro de comunicaciones, CDD, DNI, RGPD, ACI, Plan de pagos, Cliente Total). */
public final class AccionesCliente {
    private AccionesCliente() {}

    /** «Más datos cliente»: pestañas Más datos / Datos de contacto / Origen de los datos. */
    public record MasDatos(String nacionalidad, String idioma, LocalDate fechaNacimiento, Integer edad, String sexo,
                           Integer numeroHijos, String tipoPersona, String estadoCivil, boolean empleadoMapfre, String profesion,
                           List<Telefono> telefonos, List<String> emails, Map<String, String> origenDatos, List<String> avisos) {}
    public record Telefono(String tipo, String motivo, String prefijo, String numero) {}
    public record ContactoActualizado(List<Telefono> telefonos, List<String> emails) {}

    /** «Centro de comunicaciones»: Alertas / Interacciones / Reclamaciones con filtro 30 días / 12 meses / 3 años. */
    public record Comunicaciones(List<Alerta> alertas, List<Interaccion> interacciones, List<Interaccion> reclamaciones, String periodo) {}
    public record Interaccion(String id, LocalDateTime fecha, String canal, String motivo, String descripcion, String estado) {}

    /** CDD «Consulta y descarga de documentación». */
    public record DocumentoCliente(String id, String tipoDocumento, String codificacion, String nombre, LocalDate fechaAlta,
                                   LocalDate fechaVigencia, String nivelLopd, String clasificacion, String contrato, String clausula) {}

    /** Firma RGPD (CMP_PM_FIRMA_RGPD_COMPLETO): métodos y disponibilidad según móvil/email. */
    public record FirmaRgpd(List<MetodoFirma> metodos, String estado) {}
    public record MetodoFirma(String codigo, String nombre, boolean disponible) {}
    public record SolicitudFirma(String metodo) {}
    public record ResultadoAccion(String estado, String mensaje, String referencia) {}

    /** «Alta Cliente Total»: datos del cliente y empresas vinculadas. */
    public record ClienteTotal(String nif, String nombre, String clasificacionActual, String nuevaClasificacion,
                               List<EmpresaVinculada> empresas, boolean puedeFirmar) {}
    public record EmpresaVinculada(String cif, String razonSocial, String actividad, String segmento, String clasificacion,
                                   String cargo, String estado) {}

    /** «Plan de pagos › Simular» (DPVE). */
    public record PlanPagos(boolean susceptible, boolean individualDisponible, boolean familiarDisponible, String mensaje) {}
    public record SimulacionPlanPagos(String tipo, java.math.BigDecimal cuotaMensual, int numeroCuotas, List<String> productosIncluidos) {}
}
