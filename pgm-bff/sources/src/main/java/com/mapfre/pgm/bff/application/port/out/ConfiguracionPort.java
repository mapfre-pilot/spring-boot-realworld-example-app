package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.Configuracion;
import java.util.Map;
import java.util.Optional;

/** Almacén de configuración: JSON para lo no secreto y secretos cifrados aparte (fichero/volumen en local; Config Server/Vault en MAPFRE). */
public interface ConfiguracionPort {
    Optional<Configuracion> leer();
    void escribir(Configuracion configuracion);
    /** Secretos por ámbito (clave de servicio, `appian`, `entraid`) y nombre: devuelve solo si están informados. */
    Map<String, String> secretos(String ambito);
    void guardarSecreto(String ambito, String nombre, String valor);
    void borrarSecreto(String ambito, String nombre);
    String origenSecretos();

    /** Cambia con cada escritura; permite a los consumidores cachear la lectura sin quedarse obsoletos. */
    default long version() {
        return 0L;
    }
}
