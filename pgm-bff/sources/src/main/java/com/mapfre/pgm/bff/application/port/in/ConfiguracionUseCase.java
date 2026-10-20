package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.Configuracion;
import com.mapfre.pgm.bff.domain.model.Configuracion.ResultadoPrueba;
import java.util.List;

public interface ConfiguracionUseCase {
    Configuracion obtener(String usuario, List<String> perfiles);
    Configuracion guardar(Configuracion nueva, String usuario, List<String> perfiles);
    Configuracion guardarSecreto(String ambito, String nombre, String valor, String usuario, List<String> perfiles);
    Configuracion borrarSecreto(String ambito, String nombre, String usuario, List<String> perfiles);
    ResultadoPrueba probarServicio(String clave, String usuario, List<String> perfiles);
    /** Sin autorización: solo datos públicos (entorno, Entra ID sin secretos, origen de datos). */
    Configuracion.Publica publica();

    Configuracion restaurarPorDefecto(String usuario, List<String> perfiles);
}
