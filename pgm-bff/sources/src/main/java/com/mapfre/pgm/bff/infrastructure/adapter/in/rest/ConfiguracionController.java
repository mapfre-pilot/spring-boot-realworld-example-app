package com.mapfre.pgm.bff.infrastructure.adapter.in.rest;

import com.mapfre.pgm.bff.application.port.in.ConfiguracionUseCase;
import com.mapfre.pgm.bff.domain.model.Configuracion;
import com.mapfre.pgm.bff.domain.model.Configuracion.ResultadoPrueba;
import com.mapfre.pgm.bff.domain.model.Configuracion.ValorSecreto;
import org.springframework.web.bind.annotation.*;

/** Pestaña «Configuración» (solo PGM_ADMINISTRADOR). Los secretos solo se escriben; nunca se devuelven en claro. */
@RestController
@RequestMapping(path = "/api/v1/configuracion", produces = "application/json")
public class ConfiguracionController {

    private final ConfiguracionUseCase configuracion;

    public ConfiguracionController(ConfiguracionUseCase configuracion) {
        this.configuracion = configuracion;
    }

    @GetMapping
    public Configuracion obtener(UsuarioActual usuario) {
        return configuracion.obtener(usuario.id(), usuario.perfiles());
    }

    @PutMapping(consumes = "application/json")
    public Configuracion guardar(@RequestBody Configuracion nueva, UsuarioActual usuario) {
        return configuracion.guardar(nueva, usuario.id(), usuario.perfiles());
    }

    @PutMapping(path = "/secretos/{ambito}/{nombre}", consumes = "application/json")
    public Configuracion guardarSecreto(@PathVariable String ambito, @PathVariable String nombre,
                                        @RequestBody ValorSecreto valor, UsuarioActual usuario) {
        return configuracion.guardarSecreto(ambito, nombre, valor == null ? null : valor.valor(), usuario.id(), usuario.perfiles());
    }

    @DeleteMapping("/secretos/{ambito}/{nombre}")
    public Configuracion borrarSecreto(@PathVariable String ambito, @PathVariable String nombre, UsuarioActual usuario) {
        return configuracion.borrarSecreto(ambito, nombre, usuario.id(), usuario.perfiles());
    }

    @PostMapping("/servicios/{clave}/prueba")
    public ResultadoPrueba probar(@PathVariable String clave, UsuarioActual usuario) {
        return configuracion.probarServicio(clave, usuario.id(), usuario.perfiles());
    }

    @PostMapping("/restaurar")
    public Configuracion restaurar(UsuarioActual usuario) {
        return configuracion.restaurarPorDefecto(usuario.id(), usuario.perfiles());
    }
}
