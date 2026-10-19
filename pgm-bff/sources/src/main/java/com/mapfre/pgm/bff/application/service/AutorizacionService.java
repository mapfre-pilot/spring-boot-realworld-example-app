package com.mapfre.pgm.bff.application.service;

import com.mapfre.pgm.bff.application.port.in.ContextoUsuarioUseCase;
import com.mapfre.pgm.bff.application.port.out.GestionComercialPort;
import com.mapfre.pgm.bff.domain.exception.AccesoNoAutorizadoException;
import com.mapfre.pgm.bff.domain.model.ContextoUsuario;
import com.mapfre.pgm.bff.domain.model.EstructuraComercial;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Service;

/**
 * Modelo de autorización de PGM: grupo Entra ID (perfil) × estructura comercial (NUUMA, iMediador) × feature flags.
 * Reproduce las reglas observadas en Appian: los grupos gobiernan tarjetas/accesos; Gestión comercial exige
 * además perfil SGC 3.0 y estructura NUUMA.
 */
@Service
public class AutorizacionService implements ContextoUsuarioUseCase {

    private final GestionComercialPort gestionComercialPort;
    private final FeatureFlags flags;

    public AutorizacionService(GestionComercialPort gestionComercialPort, FeatureFlags flags) {
        this.gestionComercialPort = gestionComercialPort;
        this.flags = flags;
    }

    @Override
    public ContextoUsuario contexto(String usuario, String nombre, List<String> perfiles) {
        EstructuraComercial estructura = gestionComercialPort.estructuraDe(usuario).orElse(null);
        String perfilSgc30 = gestionComercialPort.perfilSgc30De(usuario).orElse(null);
        boolean esUsuario = perfiles.contains(Perfiles.USUARIO) || perfiles.contains(Perfiles.ADMINISTRADOR)
                || perfiles.contains(Perfiles.ASESOR_COMERCIAL);
        boolean asesor = perfiles.contains(Perfiles.ASESOR_COMERCIAL) || perfiles.contains(Perfiles.ADMINISTRADOR);
        boolean tieneEstructura = estructura != null && estructura.nuuma() != null && !estructura.nuuma().isBlank();
        boolean comercialCompleto = asesor && tieneEstructura && perfilSgc30 != null && flags.gestionComercial();

        Map<String, Boolean> v = new LinkedHashMap<>();
        v.put(Visibilidades.INICIO, esUsuario);
        v.put(Visibilidades.FICHA_CLIENTE, esUsuario);
        v.put(Visibilidades.NUEVA_PRODUCCION, esUsuario);
        v.put(Visibilidades.GESTION_CARTERA, esUsuario);
        v.put(Visibilidades.RECIBOS, esUsuario);
        v.put(Visibilidades.PRESTACIONES, esUsuario);
        v.put(Visibilidades.UTILIDADES, esUsuario);
        v.put(Visibilidades.GESTION_COMERCIAL, asesor && flags.gestionComercial());
        v.put(Visibilidades.GESTIONES_SGC30, comercialCompleto);
        v.put(Visibilidades.ACTIVIDAD_COMERCIAL, comercialCompleto);
        v.put(Visibilidades.ANADIR_VENCIMIENTO, comercialCompleto);
        v.put(Visibilidades.CUADRO_MANDO, flags.cuadroMando()
                && (perfiles.contains(Perfiles.VISUALIZAR_CDM) || perfiles.contains(Perfiles.ADMINISTRADOR)));
        v.put(Visibilidades.TARIFICACION_SALUD, esUsuario && flags.tarificacionSalud());
        return new ContextoUsuario(usuario, nombre, List.copyOf(perfiles), perfilSgc30, estructura, Map.copyOf(v));
    }

    public void exigir(ContextoUsuario ctx, String visibilidad) {
        if (!Boolean.TRUE.equals(ctx.visibilidades().get(visibilidad))) {
            throw new AccesoNoAutorizadoException("El usuario no tiene acceso a '" + visibilidad + "'");
        }
    }
}
