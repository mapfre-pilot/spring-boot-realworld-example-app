package com.mapfre.pgm.bff.domain.model;

public record ClienteResumen(
        String id,
        String nombre,
        String apellidos,
        String tipoDocumento,
        String documento,
        Tipologia tipologia,
        EstadoCliente estado,
        String telefono,
        String email,
        String localidad,
        int numeroPolizasEnVigor,
        java.time.LocalDate fechaNacimiento,
        String domicilio,
        String codigoPostal,
        boolean robinson) {
}
