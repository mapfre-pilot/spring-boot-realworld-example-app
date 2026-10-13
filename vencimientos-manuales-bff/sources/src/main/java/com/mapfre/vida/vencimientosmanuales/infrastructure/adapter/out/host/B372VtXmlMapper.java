package com.mapfre.vida.vencimientosmanuales.infrastructure.adapter.out.host;

import com.mapfre.vida.vencimientosmanuales.application.port.out.HostVencimientosPort.*;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Component
public class B372VtXmlMapper {
    public Map<String, Object> toXmlFields(VtRequest request) {
        Map<String, Object> fields = new LinkedHashMap<>();
        if (request instanceof Vt01Request value) {
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "ANIO-E", value.anio());
            add(fields, "KEXPEDIENTE-E", value.numero());
            add(fields, "KRAMO-E", value.ramo());
            add(fields, "ANIOPOL-E", value.anioPoliza());
            add(fields, "KPOLIZA-E", value.numeroPoliza());
            add(fields, "NSUBPOLIZA-E", value.subpoliza());
            add(fields, "KCERTIFICADO-E", value.certificado());
            add(fields, "NIF1-E", value.nif());
            add(fields, "STIPSITUACION-E", value.situacion());
            add(fields, "IMPCAPITAL-E", value.importeCapital());
            add(fields, "IMPBENEFICIOS-E", value.beneficios());
            add(fields, "IMPANTICIPO-E", value.anticipo());
            add(fields, "IMPINTEPEND-E", value.interesesPendientes());
            addDate(fields, "FECEFECTO-E", value.fechaEfecto());
            fields.put("COASEGUROS-OCCURS-E", value.coaseguradoras().size());
            if (!value.coaseguradoras().isEmpty()) {
                fields.put("COASEGUROS-E", value.coaseguradoras().stream().map(item -> {
                    Map<String, Object> share = new LinkedHashMap<>();
                    add(share, "CODCOA-E", item.codigo());
                    add(share, "PORCOA-E", item.porcentaje());
                    add(share, "IMPCOA-E", item.importe());
                    add(share, "IMPRTOINTEGRCOA-E", item.importeRentaIntegra());
                    return Map.copyOf(share);
                }).toList());
            }
        } else if (request instanceof Vt02Request value) {
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "TABLA-E", value.tabla());
            add(fields, "ANIO-E", value.anio());
            add(fields, "EXPEDIENTE-E", value.numero());
        } else if (request instanceof Vt03Request value) {
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "KMODALIDAD-E", value.modalidad());
            addDate(fields, "FEFECTODESDE-E", value.fechaDesde());
            addDate(fields, "FEFECTOHASTA-E", value.fechaHasta());
            add(fields, "CCARTERA-E", value.cartera());
            add(fields, "CENTIDAD-E", value.entidad());
            add(fields, "TIPOPERACION-E", value.tipoOperacion());
        } else if (request instanceof Vt04Request value) {
            BusquedaExpedientes search = value.busqueda();
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "ANIO-E", search.anio());
            add(fields, "KEXPEDIENTE-E", search.numero());
            add(fields, "KPOLIZA-E", search.numeroPoliza());
            add(fields, "NSUBPOLIZA-E", search.subpoliza());
            add(fields, "KCERTIFICADO-E", search.certificado());
            add(fields, "NIF-E", search.nif());
        } else if (request instanceof Vt05Request value) {
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "KMODALIDAD-E", value.modalidad());
            addDate(fields, "FEFECTODESDE-E", value.fechaDesde());
            addDate(fields, "FEFECTOHASTA-E", value.fechaHasta());
            add(fields, "ANT-KMODALIDAD-E", value.anteriorModalidad());
            addDate(fields, "ANT-FEFECTODESDE-E", value.anteriorFechaDesde());
            addDate(fields, "ANT-FEFECTOHASTA-E", value.anteriorFechaHasta());
        } else if (request instanceof Vt06Request value) {
            add(fields, "ANIOEJER-E", value.anioEjercicio());
            add(fields, "MESEJER-E", value.mesEjercicio());
            addDate(fields, "FECHAINICIAL-BDGI-E", value.fechaInicial());
            addDate(fields, "FECHAFINAL-BDGI-E", value.fechaFinal());
        } else if (request instanceof Vt07Request value) {
            add(fields, "TIPOEMI-E", value.tipoEmision());
        } else if (request instanceof Vt08Request value) {
            add(fields, "ANIO-E", value.anio());
            add(fields, "KEXPEDIENTE-E", value.numero());
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "ANT-ANIO-E", value.anteriorAnio());
            add(fields, "ANT-KEXPEDIENTE-E", value.anteriorNumero());
        } else if (request instanceof Vt09Request value) {
            add(fields, "ANIO-E", value.anio());
            add(fields, "EXPEDIDESDE-E", value.expedienteDesde());
            add(fields, "EXPEDIHASTA-E", value.expedienteHasta());
            addDate(fields, "FEMISION-E", value.fechaEmision());
            add(fields, "TIPOEMI-E", value.tipoEmision());
            add(fields, "LUGARENVIO-E", value.lugarEnvio());
        } else if (request instanceof Vt10Request value) {
            add(fields, "TIPOEMI-E", value.tipoEmision());
            add(fields, "ANIODESDE-E", value.anioDesde());
            add(fields, "ANIOHASTA-E", value.anioHasta());
            add(fields, "EXPEDIDESDE-E", value.expedienteDesde());
            add(fields, "EXPEDIHASTA-E", value.expedienteHasta());
            addDate(fields, "FECEMIDESDE-E", value.fechaEmisionDesde());
            addDate(fields, "FECEMIHASTA-E", value.fechaEmisionHasta());
            addDate(fields, "FECPAGDESDE-E", value.fechaPagoDesde());
            addDate(fields, "FECPAGHASTA-E", value.fechaPagoHasta());
        } else if (request instanceof Vt11Request value) {
            add(fields, "KPERSONA1-E", value.personaId());
            add(fields, "KDOMICILIO1-E", value.domicilioId());
            add(fields, "KPERSONA2-E", value.persona2Id());
            add(fields, "KDOMICILIO2-E", value.domicilio2Id());
            addDate(fields, "FMODIFICACION-E", value.fechaModificacion());
        } else if (request instanceof Vt12Request value) {
            add(fields, "OPERACION-E", value.operacion());
            add(fields, "POLIZA-E", value.numeroPoliza());
            add(fields, "SUBPOLIZA-E", value.subpoliza());
        } else if (request instanceof Vt19Request value) {
            add(fields, "POLIZA-E", value.numeroPoliza());
            add(fields, "SUBPOLIZA-E", value.subpoliza());
            add(fields, "CERTIFICADO-E", value.certificado());
        }
        return Map.copyOf(fields);
    }

    public Map<String, Object> toExpedienteXmlFields(Expediente expediente) {
        Map<String, Object> fields = new LinkedHashMap<>(toXmlFields(new Vt01Request("M1",
                expediente.anio(), expediente.numero(), expediente.ramo(), expediente.anioPoliza(),
                expediente.numeroPoliza(), expediente.subpoliza(), expediente.certificado(), expediente.nif(),
                expediente.situacion(),
                expediente.importeCapital(), expediente.beneficios(), expediente.anticipo(),
                expediente.interesesPendientes(), expediente.fechaEfecto(), expediente.coaseguradoras())));
        return Map.copyOf(fields);
    }

    @SuppressWarnings("unchecked")
    public Expediente fromExpedienteXmlFields(Map<String, Object> fields) {
        List<Coaseguradora> shares = new ArrayList<>();
        Object rawShares = fields.get("COASEGUROS-E");
        if (rawShares instanceof List<?> values) {
            for (Object raw : values) {
                Map<String, Object> share = (Map<String, Object>) raw;
                shares.add(new Coaseguradora(String.valueOf(share.get("CODCOA-E")),
                        decimal(share.get("PORCOA-E")), decimal(share.get("IMPCOA-E")),
                        decimal(share.get("IMPRTOINTEGRCOA-E"))));
            }
        }
        return new Expediente(text(fields, "ANIO-E"), text(fields, "KEXPEDIENTE-E"),
                text(fields, "KRAMO-E"), text(fields, "ANIOPOL-E"), text(fields, "KPOLIZA-E"),
                text(fields, "NSUBPOLIZA-E"), text(fields, "KCERTIFICADO-E"), text(fields, "NIF1-E"),
                text(fields, "STIPSITUACION-E"), decimal(fields.get("IMPCAPITAL-E")),
                decimal(fields.get("IMPBENEFICIOS-E")), decimal(fields.get("IMPANTICIPO-E")),
                decimal(fields.get("IMPINTEPEND-E")), date(fields.get("FECEFECTO-E")), shares);
    }

    @SuppressWarnings("unchecked")
    public Vt12Response fromVt12XmlFields(Map<String, Object> fields) {
        List<Coaseguradora> shares = new ArrayList<>();
        Object rawShares = fields.get("CUADRO-COASEGURO-S");
        if (rawShares instanceof List<?> values) {
            for (Object raw : values) {
                Map<String, Object> share = (Map<String, Object>) raw;
                shares.add(new Coaseguradora(text(share, "CODCOA-S"), decimal(share.get("PORCOA-S")),
                        null, null));
            }
        }
        return new Vt12Response(shares, text(fields, "CRETORNO-S"), text(fields, "GERROR-S"));
    }

    private void addDate(Map<String, Object> fields, String key, LocalDate value) {
        if (value != null) fields.put(key, value.format(DateTimeFormatter.BASIC_ISO_DATE));
    }
    private void add(Map<String, Object> fields, String key, Object value) {
        if (value != null) fields.put(key, value);
    }
    private String text(Map<String, Object> fields, String key) {
        Object value = fields.get(key);
        return value == null ? null : value.toString();
    }
    private BigDecimal decimal(Object value) {
        return value == null ? null : value instanceof BigDecimal decimal ? decimal : new BigDecimal(value.toString());
    }
    private LocalDate date(Object value) {
        if (value == null) return null;
        String text = value.toString();
        return text.length() == 8 ? LocalDate.parse(text, DateTimeFormatter.BASIC_ISO_DATE) : LocalDate.parse(text);
    }
}
