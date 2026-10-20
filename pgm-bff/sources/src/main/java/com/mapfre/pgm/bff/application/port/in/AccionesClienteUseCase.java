package com.mapfre.pgm.bff.application.port.in;

import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import java.util.List;

/** Menú ACCIONES de la cabecera de la ficha (PGM_Header_AccionesCliente) y acciones de las palancas. */
public interface AccionesClienteUseCase {
    MasDatos masDatos(String clienteId, String usuario);
    MasDatos actualizarContacto(String clienteId, ContactoActualizado contacto, String usuario);
    Comunicaciones comunicaciones(String clienteId, String periodo, String usuario);
    List<DocumentoCliente> documentos(String clienteId, String tipo, String usuario);
    ResultadoAccion solicitarDigitalizacionDni(String clienteId, String canal, String usuario);
    FirmaRgpd metodosFirmaRgpd(String clienteId, String usuario);
    ResultadoAccion firmarRgpd(String clienteId, String metodo, String usuario);
    ResultadoAccion altaAci(String clienteId, String usuario);
    ClienteTotal clienteTotal(String clienteId, String usuario);
    ClienteTotal anadirEmpresaVinculada(String clienteId, EmpresaVinculada empresa, String usuario);
    PlanPagos planPagos(String clienteId, String usuario);
    SimulacionPlanPagos simularPlanPagos(String clienteId, String tipo, String usuario);
    ResultadoAccion inducir(String clienteId, String canal, String usuario);
}
