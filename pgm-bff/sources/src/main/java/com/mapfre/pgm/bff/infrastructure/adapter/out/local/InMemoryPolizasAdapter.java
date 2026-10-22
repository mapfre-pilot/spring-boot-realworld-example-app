package com.mapfre.pgm.bff.infrastructure.adapter.out.local;

import org.springframework.beans.factory.annotation.Value;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;
import com.mapfre.pgm.bff.domain.model.Ramo;
import com.mapfre.pgm.bff.domain.model.PosicionCliente.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapfre.pgm.bff.application.port.out.PolizasPort;
import com.mapfre.pgm.bff.domain.model.Poliza;
import java.util.List;
import java.util.Optional;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("local")
public class InMemoryPolizasAdapter implements PolizasPort {

    private final List<Poliza> polizas;

    /** Dominio de las apps legacy de PRE observado en TEST (apps.pre.mapfre.net); por entorno vía PGM_URL_APPS. */
    private final String urlApps;

    public InMemoryPolizasAdapter(ObjectMapper mapper, @Value("${PGM_URL_APPS:https://apps.pre.mapfre.net}") String urlApps) {
        this.urlApps = urlApps;
        this.polizas = LocalDataLoader.load(mapper, "polizas.json", new TypeReference<>() {});
    }

    @Override
    public List<Poliza> porCliente(String clienteId) {
        return polizas.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId)).toList();
    }

    @Override
    public Optional<Poliza> detalle(String numeroPoliza) {
        return polizas.stream().filter(p -> p.numero().equalsIgnoreCase(numeroPoliza)).findFirst();
    }

    /** Catálogo WLCatalog observado en TEST (área B): 9 cards Autos, 3 Vida; resto ramos: consulta + documentación + SGO. */
    @Override
    public List<AccionPoliza> accionesPoliza(String numeroPoliza) {
        Poliza p = detalle(numeroPoliza).orElse(null);
        if (p == null) return List.of();
        String n = p.numero();
        String sca = urlApps + "/PCA_FRONTFWEB/app/lanzar_decision.jsf?modo=G&numPoliza=" + n + "&origen=FDC&lineaNegocio=1";
        String doc = "DOCUMENTACION_EMISION";
        return switch (p.ramo()) {
            case AUTOS -> List.of(
                    new AccionPoliza("AVISO_RENOVACION", "Aviso Renovación", "Consutron", urlApps + "/consutron/ext/polizas/situacion/avisoRenovacion.do?numPoliza=" + n, false, true),
                    new AccionPoliza("LISTA_SUPLEMENTOS", "Lista de Suplementos", "Consutron", urlApps + "/consutron/ext/polizas/situacion/lista.do?numPoliza=" + n, false, true),
                    new AccionPoliza("CONSULTA", "Consulta", "Consutron", urlApps + "/consutron/ext/polizas/situacion/resumen.do?numPoliza=" + n, false, true),
                    new AccionPoliza("LISTA_RECIBOS", "Lista recibos", "Consutron", urlApps + "/consutron/ext/recibos/listado.do?numPoliza=" + n, false, true),
                    new AccionPoliza("SCA", "SCA", "SCA", sca, false, true),
                    new AccionPoliza("EMISION", "Emisión", "WAUTEMISDIST", urlApps + "/administracion/ForwardTo.do?url=http://app.es.mapfre.net/wautemisdist/wautemisdist.asp&pn=" + n + "&origen=RCCM", false, true),
                    new AccionPoliza("SINIESTROS", "Siniestros", "ATENAUS", "https://watenaus.pre.mapfre.net/atenaus/indexatenaus.asp", false, true),
                    new AccionPoliza("SGO", "SGO", "SGO", "/sgo/solicitud/nueva?poliza=" + n, true, false),
                    new AccionPoliza(doc, "Documentación de emisión", "CDD", null, false, false));
            case VIDA, AHORRO, RIESGO -> List.of(
                    new AccionPoliza("CONSULTA_INDIVIDUAL", "Consulta individual", "WEBVIDA", urlApps + "/webvida/consulta/individual?numPoliza=" + n, false, true),
                    new AccionPoliza("SCA", "SCA", "SCA", sca, false, true),
                    new AccionPoliza(doc, "Documentación de emisión", "CDD", null, false, false));
            default -> List.of(
                    new AccionPoliza("CONSULTA", "Consulta", "Consutron", urlApps + "/consutron/ext/polizas/situacion/resumen.do?numPoliza=" + n, false, true),
                    new AccionPoliza(doc, "Documentación de emisión", "CDD", null, false, false),
                    new AccionPoliza("SGO", "SGO", "SGO", "/sgo/solicitud/nueva?poliza=" + n, true, false));
        };
    }

    @Override
    public List<DocumentoPoliza> documentosPoliza(String numeroPoliza) {
        Poliza p = detalle(numeroPoliza).orElse(null);
        if (p == null) return List.of();
        return List.of(
                new DocumentoPoliza(numeroPoliza + "-CP", "CONDICIONES_PARTICULARES", "Condiciones particulares", p.fechaEfecto(), "PDF"),
                new DocumentoPoliza(numeroPoliza + "-CG", "CONDICIONES_GENERALES", "Condiciones generales", p.fechaEfecto(), "PDF"),
                new DocumentoPoliza(numeroPoliza + "-CS", "CERTIFICADO", "Certificado de seguro", p.fechaEfecto().plusDays(1), "PDF"));
    }

    @Override
    public Optional<DetallePolizaRamo> detalleRamo(Poliza p) {
        return Optional.ofNullable(p).map(poliza -> {
            Poliza.TipoDetalle tipo = tipoDetalle(poliza);
            if (tipo == Poliza.TipoDetalle.GENERICA
                    || (tipo == Poliza.TipoDetalle.VIDA && poliza.numero().length() >= 11)) {
                return new DetallePolizaRamo(poliza.numero(), poliza.ramo(), tipo, null, false,
                        List.of("idPoliza"), Map.of(), List.of(), List.of(),
                        List.of(new DisponibilidadPorOrigen("detalle por ramo", "LOCAL", false,
                                "El dispatcher de PGM no solicita detalle para este ramo o longitud de póliza.")));
            }
            return switch (tipo) {
            case VIDA -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), true, List.of(),
                    Map.of(
                            "Datos del tomador", campos("El Tomador es asegurado", "False", "Nombre y apellidos", "María López García", "NIF/CIF", "12345678Z", "Profesión", "Ingeniera", "F. Nacimiento", "14/03/1985", "Tlfn. Particular", "915550101", "Tlfn. Móvil", "600123456", "Preguntas", "Información declarada", "¿Tiene establecida su residencia habitual en España?", "Sí", "¿Es o ha sido persona de responsabilidad pública, familiar en primer grado o allegado a ésta por relación personal o empresarial?", "No", "¿Es residente fiscal en terceros países?", "No", "Domicilio", "Calle Mayor 10", "Fiscal", "Calle Mayor 10", "Cobro", "Calle Mayor 10", "Prestación", "Calle Mayor 10", "Comunicación", "maria@example.test"),
                            "Datos del asegurado", campos("Nombre y apellidos", "María López García", "NIF/CIF", "12345678Z", "Profesión", "Ingeniera", "F. Nacimiento", "14/03/1985", "Sexo", "Mujer"),
                            "Estructura comercial", campos("Intervinientes", "Agente 0042", "Aport.", "100 %", "Clave productor", "0042", "TP", "Mediador", "O.D.", "01", "F. inicio", "01/01/2025", "Nombre", "Ana Mediadora", "Año 1", "100 %", "Año 2", "100 %", "Nº Sucesivos", "0", "Sucesivos (%)", "0 %"),
                            "Primas", campos("Prima única", "0,00 €", "Prima periódica", "720,00 €", "Importe aportación", "60,00 €", "Periodicidad aportación", "Mensual", "Tipo Revalorizacíon", "IPC", "% Revalorización", "2 %", "Día de cobro", "5"),
                            "Garantía FALL", campos("Prima neta anual", "24,50 €", "Fondo", "MAPFRE Vida", "%", "100 %", "Títulos", "120", "Importe", "12.000,00 €", "VLP", "100,00 €", "Fecha VLP", "01/01/2025"),
                            "Garantía IPA", campos("Prima neta anual", "11,20 €", "Fondo", "MAPFRE Vida", "%", "100 %", "Títulos", "120", "Importe", "12.000,00 €", "VLP", "100,00 €", "Fecha VLP", "01/01/2025")),
                    List.of(new Garantia("FALL", "Fallecimiento", new BigDecimal("60000.00"), null),
                            new Garantia("IPA", "Invalidez permanente absoluta", new BigDecimal("60000.00"), null)),
                    List.of(new Beneficiario("Beneficiario designado (demo)", "***", "Cónyuge", new BigDecimal("100"))),
                    List.of(new DisponibilidadPorOrigen("Datos del contrato", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case AUTOS -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Vehículo", campos("Marca", "SEAT", "Matrícula", "0000 ZZZ", "Modelo", "León 1.5 TSI",
                                    "Número de bastidor", "VSSZZZ5FZGR123456", "Color", "Gris", "Código vehículo", "AUT-01",
                                    "Tipo de vehículo", "Turismo", "Referencia vehículo", "REF-000100",
                                    "Información detallada del vehículo", poliza.riesgo(), "Número de puertas", "5",
                                    "Número de caballos", "130 CV", "Combustible", "Gasolina", "Cilindrada", "1.498 cc",
                                    "Tipo de cambio", "Manual", "Precio de venta", "24.500,00 €"),
                            "Datos del tomador", campos("Nombre", "Carlos Martín Ruiz", "NIF/CIF", "12345678Z", "Genero", "Hombre",
                                    "F. Nacimiento", "12/06/1980", "Email", "carlos@example.test", "Tlfn. Móvil", "600123456", "Dirección", "Calle Mayor 10, Madrid"),
                            "Interviniente 1", campos("Nombre", "Carlos Martín Ruiz", "Tipo de Documento", "NIF", "Nº Documento", "12345678Z", "Fecha Nacimiento", "12/06/1980", "Figura", "Tomador")),
                    List.of(new Garantia("RC", "Responsabilidad civil", new BigDecimal("50000000.00"), null),
                            new Garantia("DP", "Daños propios", new BigDecimal("24500.00"), "300 €")), List.of(),
                    List.of(new DisponibilidadPorOrigen("Vehículo", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case HOGAR -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Vivienda", Map.of("Dirección", poliza.riesgo(), "Tipo", "Piso", "Metros", "95 m²", "Continente", "150.000 €", "Contenido", "30.000 €")),
                    List.of(new Garantia("INC", "Incendio", null, null), new Garantia("AGUA", "Daños por agua", null, null)), List.of(),
                    List.of(new DisponibilidadPorOrigen("Vivienda", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case SALUD -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Datos del tomador", campos("Nº Documento", "12345678Z", "Dirección", "Calle Mayor 10, Madrid",
                                    "Estado Civil", "Casada", "Sexo", "Mujer", "Fecha de nacimiento", "14/03/1985",
                                    "Número de teléfono personal", "915550101"),
                            "Interviniente 1", campos("Nombre", "María López García", "Tipo de Documento", "NIF", "Nº Documento", "12345678Z", "Fecha Nacimiento", "14/03/1985", "Figura", "Titular"),
                            "Garantía SALUD", campos("Cobertura", "Asistencia sanitaria completa", "Obligatoria", "Sí", "Contratada", "Sí")),
                    List.of(new Garantia("SALUD", "Asistencia sanitaria", new BigDecimal("250000.00"), null)), List.of(),
                    List.of(new DisponibilidadPorOrigen("Datos del tomador", "LOCAL", true,
                            "Datos sintéticos del perfil local.")));
            case GENERICA -> sintetico(poliza, "Resumen", Map.of("Producto", poliza.producto(), "Descripción del riesgo", poliza.riesgo()));
            };
        });
    }

    private static DetallePolizaRamo sintetico(Poliza poliza, String bloque, Map<String, String> campos) {
        return new DetallePolizaRamo(poliza.numero(), poliza.ramo(), tipoDetalle(poliza), poliza.numero(), false,
                List.of(), Map.of(bloque, campos), List.of(), List.of(),
                List.of(new DisponibilidadPorOrigen(bloque, "LOCAL", true, "Datos sintéticos del perfil local.")));
    }

    private static Map<String, String> campos(String... pares) {
        Map<String, String> resultado = new java.util.LinkedHashMap<>();
        for (int i = 0; i < pares.length; i += 2) resultado.put(pares[i], pares[i + 1]);
        return resultado;
    }

    private static Poliza.TipoDetalle tipoDetalle(Poliza p) {
        return Poliza.clasificarTipoDetalle(p.ramo(), p.numero());
    }

    @Override
    public List<EstadoAnterior> estadosAnteriores(String clienteId) {
        return polizas.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId) && p.estado() != Poliza.EstadoPoliza.EN_VIGOR)
                .map(p -> new EstadoAnterior(p.numero(), p.ramo(), p.producto(), p.estado(), p.fechaEfecto(), p.fechaVencimiento(),
                        p.estado() == Poliza.EstadoPoliza.ANULADA ? "Anulación a petición del tomador" : "Suspensión por impago"))
                .toList();
    }
}
