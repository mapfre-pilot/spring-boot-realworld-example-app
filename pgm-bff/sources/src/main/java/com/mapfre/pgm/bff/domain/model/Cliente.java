package com.mapfre.pgm.bff.domain.model;

import java.time.LocalDate;
import java.util.List;

/** Visión 360 nivel 1 del cliente (ficha PGM). */
public record Cliente(
        String id,
        String nombre,
        String apellidos,
        String tipoDocumento,
        String documento,
        LocalDate fechaNacimiento,
        String nacionalidad,
        Tipologia tipologia,
        EstadoCliente estado,
        boolean vip,
        boolean robinson,
        boolean exclusivoCorredor,
        Direccion direccion,
        String telefono,
        String email,
        String oficinaGestora,
        String gestorAsignado,
        Palancas palancas,
        List<Alerta> alertas,
        List<MiembroFamilia> familia,
        String posicionBancaria,
        Integer descuentoVinculacion) {

    public String nombreCompleto() {
        return (nombre + " " + apellidos).trim();
    }
}
