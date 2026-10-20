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
}

export const PGM_REPOSITORY = new InjectionToken<PgmRepository>('PGM_REPOSITORY');
