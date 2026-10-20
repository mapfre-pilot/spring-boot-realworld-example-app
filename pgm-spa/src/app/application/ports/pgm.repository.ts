import { InjectionToken } from '@angular/core';
import { Observable } from 'rxjs';
import {
  ActividadComercial,
  AltaActividad,
  AltaOportunidad,
  AuditoriaRequest,
  BorradorResumen,
  CatalogoComercial,
  Cliente,
  ClienteResumen,
  ContextoUsuario,
  AccionPoliza,
  DocumentoPoliza,
  DetallePolizaRamo,
  EstadoAnterior,
  ReciboDetalle,
  AccionRecibo,
  DuplicadoRecibo,
  PrestacionDetalle,
  MasDatos,
  ContactoActualizado,
  Comunicaciones,
  PeriodoComunicaciones,
  DocumentoCliente,
  FirmaRgpd,
  ResultadoAccion,
  ClienteTotal,
  EmpresaVinculada,
  PlanPagos,
  SimulacionPlanPagos,
  CriteriosBusqueda,
  DocumentoAdjunto,
  FiltroActividad,
  FiltroOportunidades,
  GestionComercial,
  GestionDetalle,
  Kpi,
  Lanzadera,
  Lista,
  Observacion,
  Oportunidad,
  OportunidadDetalle,
  Poliza,
  Prestacion,
  Presupuesto,
  Ramo,
  Recibo,
  ResumenOportunidades,
  SolicitudSgo,
  SolicitudSgoDetalle,
  TipoCatalogoComercial,
  TarificacionResultado,
  TarificacionSolicitud,
} from '../../domain/models/api.models';

/** Puerto de salida de la SPA: toda la información llega del BFF, nunca de API Canal ni de plataformas directamente. */
export interface PgmRepository {
  contexto(): Observable<ContextoUsuario>;
  buscarClientes(criterios: CriteriosBusqueda): Observable<Lista<ClienteResumen>>;
  fichaCliente(id: string): Observable<Cliente>;
  productos(clienteId: string, estado?: string): Observable<Lista<Poliza>>;
  recibosCliente(clienteId: string): Observable<Lista<Recibo>>;
  prestacionesCliente(clienteId: string): Observable<Lista<Prestacion>>;
  presupuestos(clienteId: string): Observable<Lista<Presupuesto>>;
  oportunidades(clienteId: string, filtro?: FiltroOportunidades): Observable<Lista<Oportunidad>>;
  resumenOportunidades(clienteId: string): Observable<ResumenOportunidades>;
  oportunidad(id: string): Observable<OportunidadDetalle>;
  crearOportunidad(clienteId: string, alta: AltaOportunidad): Observable<Oportunidad>;
  observarOportunidad(id: string, texto: string): Observable<Observacion>;
  eliminarObservacionOportunidad(id: string, obsId: string): Observable<void>;
  actividadComercial(
    clienteId: string,
    filtro?: FiltroActividad,
  ): Observable<Lista<ActividadComercial>>;
  crearActividad(clienteId: string, alta: AltaActividad): Observable<ActividadComercial>;
  catalogoComercial(tipo: TipoCatalogoComercial): Observable<CatalogoComercial>;
  gestiones(clienteId: string): Observable<Lista<GestionComercial>>;
  gestion(id: string): Observable<GestionDetalle>;
  cerrarGestion(id: string, resultado: 'POSITIVA' | 'NEGATIVA'): Observable<GestionComercial>;
  reabrirGestion(id: string): Observable<GestionComercial>;
  observarGestion(id: string, texto: string): Observable<Observacion>;
  solicitudesSgo(clienteId: string): Observable<Lista<SolicitudSgo>>;
  solicitudSgo(id: string): Observable<SolicitudSgoDetalle>;
  documentosSgo(id: string): Observable<Lista<DocumentoAdjunto>>;
  poliza(numero: string): Observable<Poliza>;
  recibosPoliza(numero: string): Observable<Lista<Recibo>>;
  recibo(numero: string): Observable<Recibo>;
  lanzaderas(ramo?: Ramo): Observable<Lista<Lanzadera>>;
  kpis(): Observable<Lista<Kpi>>;
  tarificarSalud(solicitud: TarificacionSolicitud): Observable<TarificacionResultado>;
  guardarBorradorSalud(solicitud: TarificacionSolicitud): Observable<{ id: string }>;
  borradorSalud(id: string): Observable<TarificacionSolicitud>;
  borradoresSalud(): Observable<Lista<BorradorResumen>>;
  eliminarBorradorSalud(id: string): Observable<void>;
  llamar(clienteId: string, telefono: string): Observable<{ idLlamada: string }>;
  auditar(registro: AuditoriaRequest): Observable<void>;

  // ---- Menú ACCIONES y palancas de la cabecera ----
  masDatos(clienteId: string): Observable<MasDatos>;
  actualizarContacto(clienteId: string, contacto: ContactoActualizado): Observable<MasDatos>;
  comunicaciones(clienteId: string, periodo: PeriodoComunicaciones): Observable<Comunicaciones>;
  documentosCliente(clienteId: string, tipo?: string): Observable<Lista<DocumentoCliente>>;
  solicitarDigitalizacionDni(clienteId: string, canal: string): Observable<ResultadoAccion>;
  metodosFirmaRgpd(clienteId: string): Observable<FirmaRgpd>;
  firmarRgpd(clienteId: string, metodo: string): Observable<ResultadoAccion>;
  solicitarAltaAci(clienteId: string): Observable<ResultadoAccion>;
  clienteTotal(clienteId: string): Observable<ClienteTotal>;
  anadirEmpresaVinculada(clienteId: string, empresa: EmpresaVinculada): Observable<ClienteTotal>;
  planPagos(clienteId: string): Observable<PlanPagos>;
  simularPlanPagos(
    clienteId: string,
    tipo: 'INDIVIDUAL' | 'FAMILIAR',
  ): Observable<SimulacionPlanPagos>;
  inducir(clienteId: string, canal: string): Observable<ResultadoAccion>;

  // ---- Posición del cliente (área B) ----
  fichaPoliza(numero: string): Observable<Poliza>;
  accionesPoliza(numero: string): Observable<Lista<AccionPoliza>>;
  documentosPoliza(numero: string): Observable<Lista<DocumentoPoliza>>;
  detallePolizaRamo(numero: string): Observable<DetallePolizaRamo>;
  estadosAnteriores(clienteId: string): Observable<Lista<EstadoAnterior>>;
  accionesRecibo(numero: string): Observable<Lista<AccionRecibo>>;
  detalleRecibo(numero: string): Observable<ReciboDetalle>;
  duplicadoRecibo(numero: string): Observable<DuplicadoRecibo>;
  detallePrestacion(numero: string): Observable<PrestacionDetalle>;
}

export const PGM_REPOSITORY = new InjectionToken<PgmRepository>('PGM_REPOSITORY');
