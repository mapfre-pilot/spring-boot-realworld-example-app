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
            case VIDA, AHORRO -> List.of(
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
    public Optional<DetallePolizaRamo> detalleRamo(String numeroPoliza) {
        return detalle(numeroPoliza).map(p -> switch (p.ramo()) {
            case VIDA, AHORRO -> new DetallePolizaRamo(p.numero(), p.ramo(),
                    Map.of("Datos del contrato", Map.of("Modalidad", p.producto(), "Duración", "Anual renovable", "Capital asegurado", "60.000,00 €")),
                    List.of(new Garantia("FALL", "Fallecimiento", new BigDecimal("60000.00"), null),
                            new Garantia("IPA", "Invalidez permanente absoluta", new BigDecimal("60000.00"), null)),
                    List.of(new Beneficiario("Beneficiario designado (demo)", "***", "Cónyuge", new BigDecimal("100"))));
            case AUTOS -> new DetallePolizaRamo(p.numero(), p.ramo(),
                    Map.of("Vehículo", Map.of("Descripción", p.riesgo(), "Uso", "Particular", "Garaje", "Sí"),
                           "Conductores", Map.of("Habitual", "Tomador", "Antigüedad carné", "> 10 años")),
                    List.of(new Garantia("RC", "Responsabilidad civil", null, null),
                            new Garantia("DP", "Daños propios", null, "300 €")), List.of());
            case HOGAR -> new DetallePolizaRamo(p.numero(), p.ramo(),
                    Map.of("Vivienda", Map.of("Dirección", p.riesgo(), "Tipo", "Piso", "Metros", "95 m²", "Continente", "150.000 €", "Contenido", "30.000 €")),
                    List.of(new Garantia("INC", "Incendio", null, null), new Garantia("AGUA", "Daños por agua", null, null)), List.of());
            default -> new DetallePolizaRamo(p.numero(), p.ramo(), Map.of("Producto", Map.of("Descripción", p.producto(), "Riesgo", p.riesgo())), List.of(), List.of());
        });
    }

    @Override
    public List<EstadoAnterior> estadosAnteriores(String clienteId) {
        return polizas.stream().filter(p -> p.clienteId().equalsIgnoreCase(clienteId) && p.estado() != Poliza.EstadoPoliza.EN_VIGOR)
                .map(p -> new EstadoAnterior(p.numero(), p.ramo(), p.producto(), p.estado(), p.fechaEfecto(), p.fechaVencimiento(),
                        p.estado() == Poliza.EstadoPoliza.ANULADA ? "Anulación a petición del tomador" : "Suspensión por impago"))
                .toList();
    }
}
