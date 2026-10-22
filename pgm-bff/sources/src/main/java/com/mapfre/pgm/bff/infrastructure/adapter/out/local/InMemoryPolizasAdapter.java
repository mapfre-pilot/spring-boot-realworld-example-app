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
                            "Datos del tomador", Map.of("Nombre y apellidos", "", "NIF/CIF", "", "Profesión", "",
                                    "F. Nacimiento", "", "Tlfn. Particular", "", "Tlfn. Móvil", ""),
                            "Datos del asegurado", Map.of("Nombre y apellidos", "", "NIF/CIF", "", "Profesión", "",
                                    "F. Nacimiento", "", "Sexo", ""),
                            "Estructura comercial", campos("Intervinientes", "", "Aport.", "", "Clave productor", "",
                                    "TP", "", "O.D.", "", "F. inicio", "", "Nombre", "", "Año 1", "", "Año 2", "",
                                    "Nº Sucesivos", "", "Sucesivos (%)", ""),
                            "Primas", Map.of("Prima única", "", "Prima periódica", "", "Importe aportación", "",
                                    "Periodicidad aportación", "", "Tipo Revalorizacíon", "", "% Revalorización", "",
                                    "Día de cobro", "")),
                    List.of(new Garantia("FALL", "Fallecimiento", new BigDecimal("60000.00"), null),
                            new Garantia("IPA", "Invalidez permanente absoluta", new BigDecimal("60000.00"), null)),
                    List.of(new Beneficiario("Beneficiario designado (demo)", "***", "Cónyuge", new BigDecimal("100"))),
                    List.of(new DisponibilidadPorOrigen("Datos del contrato", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case AUTOS -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Vehículo", campos("Marca", "", "Matrícula", "", "Modelo", poliza.riesgo(),
                                    "Número de bastidor", "", "Color", "", "Código vehículo", "",
                                    "Tipo de vehículo", "", "Referencia vehículo", "",
                                    "Información detallada del vehículo", "", "Número de puertas", "",
                                    "Número de caballos", "", "Combustible", "", "Cilindrada", "",
                                    "Tipo de cambio", "", "Precio de venta", ""),
                            "Datos del tomador", campos("Nombre", "", "NIF/CIF", "", "Genero", "",
                                    "F. Nacimiento", "", "Email", "", "Tlfn. Móvil", "", "Dirección", "")),
                    List.of(new Garantia("RC", "Responsabilidad civil", null, null),
                            new Garantia("DP", "Daños propios", null, "300 €")), List.of(),
                    List.of(new DisponibilidadPorOrigen("Vehículo", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case HOGAR -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Vivienda", Map.of("Dirección", poliza.riesgo(), "Tipo", "Piso", "Metros", "95 m²", "Continente", "150.000 €", "Contenido", "30.000 €")),
                    List.of(new Garantia("INC", "Incendio", null, null), new Garantia("AGUA", "Daños por agua", null, null)), List.of(),
                    List.of(new DisponibilidadPorOrigen("Vivienda", "LOCAL", true, "Datos sintéticos del perfil local.")));
            case SALUD -> new DetallePolizaRamo(poliza.numero(), poliza.ramo(),
                    tipoDetalle(poliza), poliza.numero(), false, List.of(),
                    Map.of("Datos del tomador", Map.of("Nº Documento", "", "Dirección", "",
                                    "Estado Civil", "", "Sexo", "", "Fecha de nacimiento", "",
                                    "Número de teléfono personal", ""),
                            "Intervinientes", Map.of()),
                    List.of(new Garantia("SALUD", "Asistencia sanitaria", null, null)), List.of(),
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
