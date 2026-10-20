package com.mapfre.pgm.bff.application.port.out;

import com.mapfre.pgm.bff.domain.model.AccionesCliente.*;
import java.util.List;
import java.util.Optional;

/** Acciones de cabecera de la ficha: API Canal Clientes (contactMethods, totalClient, digitizedDocument) + legacy Client API/EDGE, ACI y firma vía Gateway. */
public interface AccionesClientePort {
    Optional<MasDatos> masDatos(String clienteId);
    MasDatos actualizarContacto(String clienteId, ContactoActualizado contacto, String usuario);
    Comunicaciones comunicaciones(String clienteId, String periodo);
    List<DocumentoCliente> documentos(String clienteId, String tipo);
    ResultadoAccion solicitarDigitalizacionDni(String clienteId, String canal, String usuario);
    FirmaRgpd metodosFirmaRgpd(String clienteId);
    ResultadoAccion firmarRgpd(String clienteId, String metodo, String usuario);
    ResultadoAccion altaAci(String clienteId, String usuario);
    Optional<ClienteTotal> clienteTotal(String clienteId);
    ClienteTotal anadirEmpresaVinculada(String clienteId, EmpresaVinculada empresa, String usuario);
    PlanPagos planPagos(String clienteId);
    SimulacionPlanPagos simularPlanPagos(String clienteId, String tipo, String usuario);
    ResultadoAccion inducir(String clienteId, String canal, String usuario);
}
