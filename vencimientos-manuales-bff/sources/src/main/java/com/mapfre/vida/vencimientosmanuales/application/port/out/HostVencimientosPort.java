package com.mapfre.vida.vencimientosmanuales.application.port.out;

import java.util.Map;

public interface HostVencimientosPort {
    HostResponse execute(Operacion operacion, Map<String, Object> camposXml);

    /** B372VT01 / transacción 3701; las claves del mapa conservan la nomenclatura XML. */
    default HostResponse gestionarExpediente(Vt01Request request) {
        return execute(Operacion.VT01, request.camposXml());
    }
    /** B372VT02; campos de entrada y salida de gestión de variables. */
    default HostResponse gestionarVariables(Vt02Request request) {
        return execute(Operacion.VT02, request.camposXml());
    }
    /** B372VT03; consulta provisional de contratos de cartera. */
    default HostResponse gestionarCarteras(Vt03Request request) {
        return execute(Operacion.VT03, request.camposXml());
    }
    /** B372VT04 / transacción 3704; búsqueda paginada de expedientes. */
    default HostResponse buscarExpedientes(Vt04Request request) {
        return execute(Operacion.VT04, request.camposXml());
    }
    /** B372VT05; listado provisional de contratos de cartera. */
    default HostResponse listarCarteras(Vt05Request request) {
        return execute(Operacion.VT05, request.camposXml());
    }
    /** B372VT06; petición del proceso BDGI. */
    default HostResponse solicitarBdgi(Vt06Request request) {
        return execute(Operacion.VT06, request.camposXml());
    }
    /** B372VT07; carga de fichero. */
    default HostResponse cargarFichero(Vt07Request request) {
        return execute(Operacion.VT07, request.camposXml());
    }
    /** B372VT08; datos adicionales de búsqueda. */
    default HostResponse buscarDatosAdicionales(Vt08Request request) {
        return execute(Operacion.VT08, request.camposXml());
    }
    /** B372VT09; emisión de finiquitos (transacción 3709). */
    default HostResponse emitirFiniquitos(Vt09Request request) {
        return execute(Operacion.VT09, request.camposXml());
    }
    /** B372VT10; impresión de informes (transacción 3710). */
    default HostResponse imprimirInformes(Vt10Request request) {
        return execute(Operacion.VT10, request.camposXml());
    }
    /** B372VT11; datos de personas (transacción 3711). */
    default HostResponse gestionarPersonas(Vt11Request request) {
        return execute(Operacion.VT11, request.camposXml());
    }
    /** B372VT12 / transacción 3612; cuadro de coaseguro. */
    default HostResponse gestionarCoaseguro(Vt12Request request) {
        return execute(Operacion.VT12, request.camposXml());
    }
    /** B372VT19 / transacción 3719; consulta de cartera de póliza. */
    default HostResponse consultarCartera(Vt19Request request) {
        return execute(Operacion.VT19, request.camposXml());
    }

    enum Operacion { VT01, VT02, VT03, VT04, VT05, VT06, VT07, VT08, VT09, VT10, VT11, VT12, VT19 }

    record HostResponse(Map<String, Object> campos) {
        public HostResponse {
            campos = Map.copyOf(campos);
        }
    }

    /** Campos XML de B372VT01: OPERACION-E, ANIO-E, KEXPEDIENTE-E y campos de expediente. */
    record Vt01Request(Map<String, Object> camposXml) { public Vt01Request { camposXml = Map.copyOf(camposXml); } }
    record Vt02Request(Map<String, Object> camposXml) { public Vt02Request { camposXml = Map.copyOf(camposXml); } }
    record Vt03Request(Map<String, Object> camposXml) { public Vt03Request { camposXml = Map.copyOf(camposXml); } }
    /** Campos XML de B372VT04: criterios de expediente/póliza/persona y claves de paginación. */
    record Vt04Request(Map<String, Object> camposXml) { public Vt04Request { camposXml = Map.copyOf(camposXml); } }
    record Vt05Request(Map<String, Object> camposXml) { public Vt05Request { camposXml = Map.copyOf(camposXml); } }
    record Vt06Request(Map<String, Object> camposXml) { public Vt06Request { camposXml = Map.copyOf(camposXml); } }
    record Vt07Request(Map<String, Object> camposXml) { public Vt07Request { camposXml = Map.copyOf(camposXml); } }
    record Vt08Request(Map<String, Object> camposXml) { public Vt08Request { camposXml = Map.copyOf(camposXml); } }
    record Vt09Request(Map<String, Object> camposXml) { public Vt09Request { camposXml = Map.copyOf(camposXml); } }
    record Vt10Request(Map<String, Object> camposXml) { public Vt10Request { camposXml = Map.copyOf(camposXml); } }
    record Vt11Request(Map<String, Object> camposXml) { public Vt11Request { camposXml = Map.copyOf(camposXml); } }
    /** B372VT12 devuelve CUADRO-COASEGURO-S; los campos de escritura requieren confirmar el XML. */
    record Vt12Request(Map<String, Object> camposXml) { public Vt12Request { camposXml = Map.copyOf(camposXml); } }
    record Vt19Request(Map<String, Object> camposXml) { public Vt19Request { camposXml = Map.copyOf(camposXml); } }
}
